@echo off
SET errorlevel=0
setlocal enabledelayedexpansion

SET OPERATION="none"
SET OP_ARGS=
SET SCRIPT_DIR=%~dp0
SET WORKING_DIR=%cd%
SET IS_ADMIN=false
call:is_administrator

SET USER_FOLDER=%HOMEDRIVE%%HOMEPATH%
SET INSTALLATION_FOLDER=C:\Program Files\Cronux\
SET ROAMING_FOLDER=!USER_FOLDER!\AppData\Roaming\Cronux\
SET BACKUP_FOLDER=!ROAMING_FOLDER!backup\

REM Place the operation script in the block below
REM START_OFFSET_FOR_MERGE

REM P
REM Add right click context to a set of files that match the extra 
REM parameters/extension, When the file is right click the created 
REm shell command is listed 
REM 
REM 
REM ::
REM 	Usage: createcontext "Open Simple In Notepad++"  "C:\Program Files\Notepad++\notepad++.exe" sim swp six
REM 
REM 
REM the command above will create a right click context with the display 
REM **Open In Command Prompt** and when clicked open the windows command 
REM prompt then cd to the folder. Cool right yea. For the sake of verifying 
REM existence of the application you need to specify the full path not just the 
REM name of the app even if the app in in serch directories. If you want to 
REM find where an app is you can use the `where` command in windows e.g. to 
REM search for where **cmd.exe** is 
REM 
REM ::
REM 	where /r c:\Windows\ cmd.exe
REM 
REM you can execute `where /?` to get more info about the **where** command.
REM 
REM This command simply generates a Registry script that is then executed with 
REM request as admin to install the shell command.
REM 
REM For a more robust application to manage the Windows Explore 
REM right-click context download the EasyFileShift app from sourceforge 
REM https://sourceforge.net/projects/easy-file-shift/
REM 
REM 
REM **Parameters**:	
REM 	param1 : string
REM 		the name to show on the right-click context list
REM 	param2 : string
REM 		the full path to the application to execute when clicked
REM     params...: string (optional)
REM 		extra arguments to send to the command 

SET DISPLAY_NAME=%1
if "!DISPLAY_NAME!"=="" (
	call:display_error you need to specify the display name as first parameter
	SET errorlevel=677
	goto:eof
)
SET DISPLAY_NAME=!DISPLAY_NAME:~1,-1!
SET SHEL_NAME=!DISPLAY_NAME!
SET APPLICATION_PATH=%2
if "!APPLICATION_PATH!"=="" (
	call:display_error you need to specify the application to run as second parameter
	SET errorlevel=677
	goto:eof
)
SET APPLICATION_PATH=!APPLICATION_PATH:~1,-1!
SET REGISTRY_TMP_PATH=!ROAMING_FOLDER!registry\
SET EXTRA_PARAMS=
SET /a INDEX=0

if not exist "!REGISTRY_TMP_PATH!" (
	mkdir !REGISTRY_TMP_PATH!
)
if not exist "!REGISTRY_TMP_PATH!" (
	call:display_error unable to create the temp context folder '!REGISTRY_TMP_PATH!'
	SET errorlevel=677
	goto:eof
)

SET HOUR=%time:~0,2%
SET dtStamp9=%date:~-4%-%date:~3,2%-%date:~0,2%_0%time:~1,1%%time:~3,2%%time:~6,2%
SET dtStamp24=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
if "%HOUR:~0,1%" == " " (SET dtStamp=%dtStamp9%) else (SET dtStamp=%dtStamp24%)

SET REGISTRY_TMP_PATH=!REGISTRY_TMP_PATH!\RightClickContext.!dtStamp!.cronux.reg

for %%x in (%*) do (
	SET /a INDEX=!INDEX!+1
	if not !INDEX!==1 (
		if not !INDEX!==2 (
			if "!EXTRA_PARAMS!"=="" (
				SET EXTRA_PARAMS=System.FileName:\"*.%%x\"
			) else (
				SET EXTRA_PARAMS=!EXTRA_PARAMS! OR System.FileName:\"*.%%x\"
			)
		)
	)
)

SET "APPLICATION_PATH=!APPLICATION_PATH!" & set "APPLICATION_PATH=!APPLICATION_PATH:\=\\!"

if not exist "!APPLICATION_PATH!" (
	call:display_error the app '!APPLICATION_PATH!' does not exist
	SET errorlevel=677
	goto:eof
)

call:display Shell Name=!SHEL_NAME!
call:display Display Name=!DISPLAY_NAME!
call:display Application Path=!APPLICATION_PATH!
call:display Applies To=!EXTRA_PARAMS!

call:display creating the registry script at !REGISTRY_TMP_PATH!

echo Windows Registry Editor Version 5.00>!REGISTRY_TMP_PATH!
echo.>>!REGISTRY_TMP_PATH!
echo [HKEY_CLASSES_ROOT\*\shell\!SHEL_NAME!]>>!REGISTRY_TMP_PATH!
echo @="!DISPLAY_NAME!">>!REGISTRY_TMP_PATH!
echo "icon"="!APPLICATION_PATH!,0">>!REGISTRY_TMP_PATH!
echo "AppliesTo"=" !EXTRA_PARAMS! ">>!REGISTRY_TMP_PATH!
echo.>>!REGISTRY_TMP_PATH!
echo [HKEY_CLASSES_ROOT\*\shell\!SHEL_NAME!\command]>>!REGISTRY_TMP_PATH!
echo @="!APPLICATION_PATH! \"%%1\"">>!REGISTRY_TMP_PATH!
echo.>>!REGISTRY_TMP_PATH!

call:display preparing to install the shell script
!REGISTRY_TMP_PATH!

exit /b 0

REM END_OFFSET_FOR_MERGE
REM End of the actual operating script

:display
	echo [0;32mCronux.createdircontext:[0m %* 
	exit /b 0
	
:display_error
	echo [0;31mCronux.createdircontext:[0m %* 
	exit /b 0
	
:is_administrator
	SET is_administrator_var=
	for /F "tokens=* USEBACKQ" %%F in (`fsutil dirty query %systemdrive%`) do SET is_administrator_var=%%F
	if "x!is_administrator_var:denied=!"=="x!is_administrator_var!" ( SET IS_ADMIN=true) 
	exit /b 0
	
REM S
REM 	:copyright: 2019, Adewale Azeez
REM 	:copyright: The MIT License (c) 2019 Cronux
REM 	:author: Adewale Azeez <azeezadewale98@gmail.com>
REM 	:date: 18 November 2019
REM 	:time: 02:18 PM
REM 	:filename: createdircontext.bat
REM 
REM 
REM		.. _ALink: ./ALink.html