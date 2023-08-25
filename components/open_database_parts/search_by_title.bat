@echo off
if not defined configdir ( exit /b )

:__main__
    echo:
    copy "%filepath%" "%cachedir%">nul
    %pluginsdir%\speed-shrink -d "%cachedir%\%filename%">nul
    %pluginsdir%\pysqlite3dbee unlock-db "%cachedir%\%filename%" !db_passwd!>nul

    set "search_by_rows_title=%~dp0\search_by_rows_title.ps1"
    cls && %consoletitle% %name% - Password Manager && echo: && echo:
    powershell -executionpolicy bypass -file "%search_by_rows_title%" -Executable "%executable%" -FilePath "%dbfilepath%"

    %pluginsdir%\cache-cleaner.exe "%cachedir%" -c>nul 2>&1
    echo: && echo:
    echo ~~^>[Press any key to go back]^<~~
    pause >nul
exit /b
