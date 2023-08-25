@echo off
if not defined configdir ( exit /b )

:__main__
    echo:
    copy "%filepath%" "%cachedir%">nul
    %pluginsdir%\speed-shrink -d "%cachedir%\%filename%">nul
    %pluginsdir%\pysqlite3dbee unlock-db "%cachedir%\%filename%" !db_passwd!>nul

    set "remove_an_entry=%~dp0\remove_an_entry.ps1"
    cls && %consoletitle% %name% - Password Manager && echo: && echo:
    %pluginsdir%\pysqlite3dbee search-td "%cachedir%\%filename%"
    echo: && echo:
    powershell -executionpolicy bypass -file "%remove_an_entry%" -Executable "%executable%" -FilePath "%dbfilepath%"

    %pluginsdir%\pysqlite3dbee lock-db "%cachedir%\%filename%" !db_passwd! !db_passwd!>nul
    %pluginsdir%\speed-shrink -c "%cachedir%\%filename%">nul
    copy "%cachedir%\%filename%" "%filepath%">nul
exit /b
