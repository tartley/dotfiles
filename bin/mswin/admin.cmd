@echo off
::  This batch file starts a command shell under the current user account,
::  after temporarily adding that user to the local Administrators group.
::  Any program launched from that command shell will also run with
::  administrative privileges.
::
::  You will be prompted for two passwords in two separate command shells:
::  first, for the password of the local administrator account, and
::  second for the password of the account under which you are logged on.
::  (The reason for this is that you are creating a new logon session in
::  which the user will be a member of the Administrators group.)
::
::  CUSTOMIZATION:
::
::  _Prog_  : the program to run
::
::  _Admin_ : the name of the administrative account that can make changes
::              to local groups (usu. "Administrator" unless you renamed the
::              local administrator account).  The first password prompt
::              will be for this account.
::
::  _Group_ : the local group to temporarily add the user to (e.g.,
::              "Administrators").
::
::  _User_  : the account under which to run the new program.  The second
::              password prompt will be for this account.  Leave it as
::              %USERDOMAIN%\%USERNAME% in order to elevate the current user.

:: TODO:
:: o allow passing of parameter to specify what command to run? else open cmd?
:: o only pause if the window contains errors and is about to dissapear

setlocal
set _Admin_=%COMPUTERNAME%\Administrator
set _Group_=Administrators
set _Title_=%USERNAME% as member of %_Group_% 
set _Prog_="cmd.exe /k Title %_Title_% && cd %HOME% && color 4F"
set _User_=%USERDOMAIN%\%USERNAME%

:: This script re-invokes itself.
:: if this is the original invokation:
if "%1"=="" (

	:: bail if current user is already member of admin group.
	if /i %USERDOMAIN%==%COMPUTERNAME% (
		net localgroup %_Group_% | findstr /i /x "%USERNAME%" >nul
	) else (
		net localgroup %_Group_% | findstr /i /x "%_User_%" >nul
	)
	if NOT ERRORLEVEL 1 (
		echo "%_User_%" is already a member of "%_Group_%"
		pause
		goto :EOF
	)

	:: invoke this script a second time, as admin user
	runas /u:%_Admin_% /env "%~s0 %_User_%"
	if ERRORLEVEL 1 (
		echo. && pause
	) else (
		exit
	)

) else (

	echo Adding user %1 to group %_Group_%...
	net localgroup %_Group_% "%1" /ADD
	if ERRORLEVEL 1 echo. && pause
	echo.
	echo Starting: %_Prog_%
	runas /u:"%1" /savecred %_Prog_%
	if ERRORLEVEL 1 echo. && pause
	echo.
	echo Removing user %1 from group %_Group_%...
	net localgroup %_Group_% "%1" /DELETE
	if ERRORLEVEL 1 echo. && pause
)
endlocal

