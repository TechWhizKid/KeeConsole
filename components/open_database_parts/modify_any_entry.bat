@echo off
if not defined configdir ( exit /b )

:__main__
    echo:
    copy "%filepath%" "%cachedir%">nul
    %pluginsdir%\speed-shrink -d "%cachedir%\%filename%">nul
    %pluginsdir%\pysqlite3dbee unlock-db "%cachedir%\%filename%" !db_passwd!>nul

    set "get_modified_input=%~dp0\get_modified_input.ps1"
    cls && %consoletitle% %name% - Password Manager && echo: && echo:
    %pluginsdir%\pysqlite3dbee search-td "%cachedir%\%filename%"
    echo: && echo:
    powershell -executionpolicy bypass -file "%get_modified_input%" -Executable "%executable%" -FilePath "%dbfilepath%"

    %pluginsdir%\pysqlite3dbee lock-db "%cachedir%\%filename%" !db_passwd! !db_passwd!>nul
    %pluginsdir%\speed-shrink -c "%cachedir%\%filename%">nul
    copy "%cachedir%\%filename%" "%filepath%">nul
exit /b
