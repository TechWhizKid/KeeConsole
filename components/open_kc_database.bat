@echo off
if not defined configdir ( exit /b )

:__main__
    @REM Check if the script is called to use the last path
    if "%~1" == "use_last_path" (
        if exist "%configdir%\lastpath.ini" (
            for /f "usebackq delims=" %%L in ("%configdir%\lastpath.ini") do (
                set "line=%%L"
                for /f "tokens=2 delims==" %%A in ("!line!") do (
                    set "filepath=%%~A"
                )
            )
        )

        @REM Remove the trailing quote from the filepath
        set "filepath=!filepath:~0,-1!"
    )

    @REM Prompt to type passwd if filepath is provided as an argument
    if exist "%~1" (
        set "filepath=%~1"
        set "filepath=!filepath:"=!"
    )

    @REM Setting arg1 var so that we can change the value without calling the script again
    set "arg1=%~1"

    :get_file_path
    @REM Check if the script is called from the <main.bat> file
    if "%arg1%" == "ask_for_path" (
        cls && %consoletitle% %name% - Password Manager && echo: && echo:
        echo Please provide the file path, i.e. "D:\Personal files\passwords.kcdb"
        set /p "filepath=Enter the database file path: "
    )

    if not exist "%filepath%" (
        cls && %consoletitle% %name% - Password Manager && echo: && echo:
        echo Error: File not found.
        echo Please provide a valid file path.
        pause && set "arg1=ask_for_path"
        goto :get_file_path
    ) else (
        @REM Extract the filename from the filepath
        for %%F in ("%filepath%") do set "filename=%%~nxF"
    )

    if exist "%filepath%" (
        cls && %consoletitle% %name% - Password Manager && echo: && echo:
        @REM Ask for password using powershell's secure string
        for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%scripts%\get_secure_string.ps1" "Enter password "') do (
            set "db_passwd=%%a"
        )

        echo: && echo. Please wait, opening database . . .

        @REM Copy the database file into the cache folder for opening
        copy "%filepath%" "%cachedir%">nul

        @REM Generate a random filename with the password in it to find hash
        set /a "rand=(((%random% * 32768) + %random%) %% 990000) + 10000"
        echo !db_passwd!>%cachedir%\check_%rand%.tmp
        certutil -hashfile %cachedir%\check_%rand%.tmp SHA256 | findstr /v :>%cachedir%\hash_%rand%.tmp
        for /f "delims=" %%p in ( %cachedir%\hash_%rand%.tmp ) do set "db_passwd=%%p" >nul

        @REM Remove the contents of the temp files and remove value of the rand variable
        %pluginsdir%\cache-cleaner.exe "%cachedir%\check_%rand%.tmp">nul
        %pluginsdir%\cache-cleaner.exe "%cachedir%\hash_%rand%.tmp">nul && set "rand="

        @REM Decompress the compressed database file
        %pluginsdir%\speed-shrink -d "%cachedir%\%filename%">nul
        
        %pluginsdir%\pysqlite3dbee unlock-db "%cachedir%\%filename%" !db_passwd!>"%cachedir%\unlock_info.tmp"
        for /f "usebackq delims=" %%D in ("%cachedir%\unlock_info.tmp") do (
            set "file_data=%%D"
        )
    )

    @REM Check if the file was unlocked before trying to access
    if "%file_data%" NEQ "File '%cachedir%\%filename%' is unlocked and can now be read and modified." (
        cls && %consoletitle% %name% - Password Manager && echo: && echo:
            echo Incorrect database password or invalid database file.
            %pluginsdir%\cache-cleaner.exe "%cachedir%" -c>nul 2>&1
            echo Press any key to try again. . . && pause >nul
            set "arg1=ask_for_path"
            goto :get_file_path
    )

    echo. Almost done, just a bit longer . . .
    :handle_kcdb
    if exist "%filepath%" (
        @REM Copy the database file into the cache folder for opening
        copy "%filepath%" "%cachedir%">nul

        echo "lastpath=%filepath%">"%configdir%\lastpath.ini"
        %pluginsdir%\speed-shrink -d "%cachedir%\%filename%">nul
        %pluginsdir%\pysqlite3dbee unlock-db "%cachedir%\%filename%" !db_passwd!>nul
        cls && %consoletitle% %name% - Password Manager && echo: && echo:
        %pluginsdir%\pysqlite3dbee search-td "%cachedir%\%filename%"

        @REM Delete the files content after reading for security
        %pluginsdir%\cache-cleaner.exe "%cachedir%" -c>nul 2>&1
        echo: && echo:
    ) else (
        cls && %consoletitle% %name% - Password Manager && echo: && echo:
        echo Error: File not found.
        echo Please provide a valid file path.
        set "arg1=ask_for_path"
        pause && goto :get_file_path
    )

    echo Select any of the option by pressing the number key:
    echo:
    echo [1] Add a new entry      [2] Modify any entry
    echo [3] Search by Title      [4] Search by Username
    echo [5] Remove an entry      [6] Lock the database
    echo:
    choice /c:123456 /n /m "Press any key from 1-6 ~~>[1/2/3/4/5/6]<~~"
    set "clicked=%errorlevel%"
        goto :option_%clicked%
    goto :handle_kcdb

    :option_1
        set "dbfilepath=%cachedir%\%filename%"
        call :run_script "%open_scripts%\add_a_new_entry"
        goto :handle_kcdb
    :option_2
        set "dbfilepath=%cachedir%\%filename%"
        call :run_script "%open_scripts%\modify_any_entry"
        goto :handle_kcdb
    :option_3
        set "dbfilepath=%cachedir%\%filename%"
        call :run_script "%open_scripts%\search_by_title"
        goto :handle_kcdb
    :option_4
        set "dbfilepath=%cachedir%\%filename%"
        call :run_script "%open_scripts%\search_by_username"
        goto :handle_kcdb
    :option_5
        set "dbfilepath=%cachedir%\%filename%"
        call :run_script "%open_scripts%\remove_an_entry"
        goto :handle_kcdb
    :option_6
        set dbfilepath=
        set filepath=
        set filename=
        set db_passwd=
        set file_data=
        if exist "%cachedir%\*.*" ( del /q "%cachedir%\*.*">nul )
        call %app%

    :run_script
        @REM This subroutine runs the specified script
        call %~1
        goto :handle_kcdb

exit /b
