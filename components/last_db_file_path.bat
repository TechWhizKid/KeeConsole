@echo off
if not defined configdir ( exit /b )

:__main__
    set "lastpath=X"
    if exist "%configdir%\lastpath.ini" (
        for /f "usebackq delims=" %%L in ("%configdir%\lastpath.ini") do (
            set "%%~L"
        )
    )

    if exist "%lastpath%" (
        set "lastpath=O"
    ) else (
        set "lastpath=X"
    )

    if "%openkcdb%" == "1" (
        set "openkcdb=0"
        if "%lastpath%" == "X" (
            echo Set WshShell = WScript.CreateObject("WScript.Shell"^)>"%cachedir%\nolastpath.vbs"
            echo msgbox "Last accessed database path was not stored or found.",0+64,"*.kcdb not found">>"%cachedir%\nolastpath.vbs"
            "%cachedir%\nolastpath.vbs"
        ) else (
            call %scripts%\open_kc_database use_last_path
        )
    )
exit /b
