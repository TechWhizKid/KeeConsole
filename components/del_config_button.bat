@echo off
if not defined configdir ( exit /b )

:__main__
    set "delconfig=X"
    for %%F in ("%configdir%\*") do (
        set "delconfig=O"
    )

    if "%deletecfg%" == "1" (
        set "deletecfg=0"
        del /s /q "%configdir%\*.*"
        goto :__main__
    )
exit /b
