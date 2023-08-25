@echo off
if not defined configdir ( exit /b )

:__main__
    set "cmdcolor=0"
    if exist "%configdir%\cmdcolor.ini" (
        for /f "usebackq delims=" %%C in ("%configdir%\cmdcolor.ini") do set "%%C" >nul
    ) else ( 
        set "bgcolor=0" && set "fgcolor=7"
    )

    set "cmdcolor=%bgcolor%%fgcolor%"

    @REM Calculate the color used for the menu highlight
    set "menucolor=%bgcolor%%fgcolor%%fgcolor%%bgcolor%"

    @color %cmdcolor%

    if "%changecolor%" == "1" (
        set "changecolor=0"
        cls && %consoletitle% %name% - Password Manager
        echo: && echo Please select a valid background ^& foreground color. && echo:
            echo.    0 = Black       8 = Gray
            echo.    1 = Blue        9 = Light Blue
            echo.    2 = Green       A = Light Green
            echo.    3 = Aqua        B = Light Aqua
            echo.    4 = Red         C = Light Red
            echo.    5 = Purple      D = Light Purple
            echo.    6 = Yellow      E = Light Yellow
            echo.    7 = White       F = Bright White
        echo:
        :select_bgcolor
        set /p "bgcolor=Background color: "
        for %%A in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do (
            if /I "%bgcolor%"=="%%A" (
                goto :select_fgcolor
            )
        )
        echo Invalid color. Please select a valid background color.
        goto :select_bgcolor
        :select_fgcolor
        set /p "fgcolor=Foreground color: "
        for %%A in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do (
            if /I "%fgcolor%"=="%%A" (
                (
                    echo bgcolor=%bgcolor%
                    echo fgcolor=%fgcolor%
                ) > "%configdir%\cmdcolor.ini"
                goto :__main__
            )
        )
        echo Invalid color. Please select a valid foreground color.
        goto :select_fgcolor
    )
exit /b
