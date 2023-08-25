@echo off

@REM Change working directory to the current file path
cd /d %~dp0

@REM Setup console appearance and title
set name=%~n0
title %name% -Password Manager
setlocal enabledelayedexpansion

@REM Set up directory variables
set "app=%~dpnx0"
set "currentdir=%~dp0"
set "configdir=config"
set "cachedir=%temp%\kc.cache.dumps.tmp"
set "pluginsdir=plugins"
set "scripts=components"
set "open_scripts=components\open_database_parts"

@REM This variables will be used by add_a_new_entry.bat
set "executable=%currentdir%\%pluginsdir%\pysqlite3dbee.exe"

@REM Check and create config directory
if not exist %configdir% ( mkdir %configdir% )
if not exist %configdir% (
    echo Set WshShell = WScript.CreateObject("WScript.Shell"^)>%temp%\mkdir_error.vbs
    echo msgbox "Error: Cannot create folder to store settings. Try running %~n0 from a different folder or run as administrator.",0+16,"Error: failed to create folder">>%temp%\mkdir_error.vbs
    %temp%\mkdir_error.vbs && del %temp%\mkdir_error.vbs /q && exit /b )

@REM Check and create cache directory
if not exist "%cachedir%" ( mkdir "%cachedir%" )

@REM Set up additional tools and utilities
set "consoletitle=%pluginsdir%\console-title.exe"
set "cmdmenusel=%pluginsdir%\cmdmenusel.exe"

@REM Call scripts to configure the password manager
call %scripts%\set_console_color
call %scripts%\del_config_button
call %scripts%\last_db_file_path

@REM Open the database if a filepath is provided as an argument
if not [%~1] == [] ( if exist "%~1" ( call %scripts%\open_kc_database %~1 ) )

@REM Start the password manager UI
:__main__
    cls && %consoletitle% %name% - Password Manager
    echo: && echo: && echo: && echo: && echo:
    %cmdmenusel% %menucolor% " | Create new database" " | Open existing database" " | Open last database [%lastpath%]" " | Set window color [%cmdcolor%]" " | Delete config [%delconfig%]"
    if errorlevel == 5 set "deletecfg=1" && call %scripts%\del_config_button && call %scripts%\set_console_color && call %scripts%\last_db_file_path
    if errorlevel == 4 set "changecolor=1" && call %scripts%\set_console_color && call %scripts%\del_config_button
    if errorlevel == 3 set "openkcdb=1" && call %scripts%\last_db_file_path
    if errorlevel == 2 call %scripts%\open_kc_database ask_for_path
    if errorlevel == 1 call %scripts%\create_database
goto :__main__
