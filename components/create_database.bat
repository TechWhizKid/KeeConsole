@echo off
if not defined configdir ( exit /b )

:__main__
    set "password="
    cls && %consoletitle% %name% - Password Manager && echo: && echo:
    echo. Create a new master password known only to you that protects your database.
    for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%scripts%\get_secure_string.ps1" "Create password "') do (
        set "password=%%a"
    )

    if "%password%" == "" (
        echo:
        echo. WARNING: You have not set a password. Using a database without a password is strongly discouraged.
        echo: && echo. Are you sure you want to continue without a password? && echo:
        %cmdmenusel% %menucolor% " | Continue without password" " | Cancel and go back"
        if errorlevel == 2 goto :__main__
        if errorlevel == 1 set "password=default" && goto :create_db_file
    )

    for /f "delims=" %%a in ('powershell -ExecutionPolicy Bypass -File "%scripts%\get_secure_string.ps1" "Conform password"') do (
        set "conform=%%a"
    )

    set "password=!password: =!"
    set "conform=!conform: =!"
    if not %password% == %conform% (
        echo Set WshShell = WScript.CreateObject("WScript.Shell"^)>%cachedir%\passwd_missmatch.vbs
        echo msgbox "Passwords do not match, please try again.",0+16,"Password missmatch">>%cachedir%\passwd_missmatch.vbs
        "%cachedir%\passwd_missmatch.vbs" && goto :__main__
    )

    :check_passwd_strength
    @REM Create a vbs file to send keystrokes and type password
    set /a "rand=(((%random% * 32768) + %random%) %% 990000) + 10000"
    echo Set WshShell = WScript.CreateObject("WScript.Shell"^)>%cachedir%\check_%rand%.vbs
    echo WScript.sleep 10>>%cachedir%\check_%rand%.vbs
    echo wshshell.sendkeys "{ENTER}">>%cachedir%\check_%rand%.vbs
    echo wshshell.sendkeys "%password%">>%cachedir%\check_%rand%.vbs
    echo wshshell.sendkeys "{ENTER}">>%cachedir%\check_%rand%.vbs
    %cachedir%\check_%rand%.vbs

    %pluginsdir%\check-passwd.exe -i>"%cachedir%\check_result.tmp"
    type "%cachedir%\check_result.tmp" | findstr /v Enter>"%cachedir%\check_result.txt"

    @REM Show the password test result
    cls && %consoletitle% %name% - Password Manager && echo: && type "%cachedir%\check_result.txt"
    %pluginsdir%\cache-cleaner.exe "%cachedir%\check_result.tmp">nul
    %pluginsdir%\cache-cleaner.exe "%cachedir%\check_result.txt">nul
    %pluginsdir%\cache-cleaner.exe "%cachedir%\check_%rand%.vbs">nul && set "rand="
    echo: && echo: && echo. Are you sure you want to keep this password? && echo: && @color %cmdcolor%
    %cmdmenusel% %menucolor% " | Yes (use this)" " | No  (go back)"
    if errorlevel == 2 goto :__main__
    if errorlevel == 1 goto :create_db_file

    :create_db_file
    @REM Generate a random number for a random file name to store password temporarily
    set /a "rand=(((%random% * 32768) + %random%) %% 990000) + 10000"
    echo %password%>%cachedir%\check_%rand%.tmp

    @REM Hash the password file
    certutil -hashfile %cachedir%\check_%rand%.tmp SHA256 | findstr /v :>%cachedir%\hash_%rand%.tmp

    @REM Read the file hash from the cached file
    for /f "delims=" %%p in ( %cachedir%\hash_%rand%.tmp ) do set "password=%%p" >nul

    @REM Remove the contents of the temp files and clear value of the rand variable
    %pluginsdir%\cache-cleaner.exe "%cachedir%\check_%rand%.tmp">nul
    %pluginsdir%\cache-cleaner.exe "%cachedir%\hash_%rand%.tmp">nul && set "rand="
    cls && %consoletitle% %name% - Password Manager && echo: && echo:
    :get_database_file_name
    echo Type a name for your database file, i.e. passwords, database etc
    set /p "newname=Name: "

    @REM Check if the name has valid characters
    echo. && echo ValidNameCheck>"%cachedir%\%newname%"
    if exist "%cachedir%\%newname%" (
        %pluginsdir%\cache-cleaner.exe "%cachedir%\%newname%">nul 2>&1
        if exist "%newname%.kcdb" (
            echo: && echo. File ^(%newname%.kcdb^) already exists in current folder.
            echo: && goto :get_database_file_name
        ) else (
            @REM Create a SQL database
            %pluginsdir%\pysqlite3dbee make-db "%newname%.kcdb"
            %pluginsdir%\pysqlite3dbee insert-th "%newname%.kcdb" "No" "Title" "Username" "Password">nul
            %pluginsdir%\pysqlite3dbee lock-db "%newname%.kcdb" !password! !password!

            @REM Compress the database file to reduce space
            %pluginsdir%\speed-shrink -c "%newname%.kcdb"

            @REM Clear the password variable
            set "password="

            @REM Store the last created database location
            echo "lastpath=%currentdir%%newname%.kcdb">"%configdir%\lastpath.ini"
            call %scripts%\last_db_file_path
            call %scripts%\del_config_button
        )
    ) else (
        echo Oops It seems like there was an issue with the file name. Please make sure to avoid using any special characters or spaces. Try again with a file name consisting of letters, numbers, and underscores only.
        echo: && goto :get_database_file_name
    )
exit /b
