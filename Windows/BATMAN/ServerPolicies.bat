@echo off
color 1f

REM Check for admin rights
echo Checking if script contains Administrative rights...
net sessions
if %errorlevel%==0 (
	echo Success!
	cls
) else (
	cls
	echo No admin, please run with Administrative rights...
	pause
	exit
)

REM DOIng da policies
"%~dp0\Meta\LGPO.exe" /m "%~dp0\Meta\Perfect\ServerDomainSysvol\GPO\Machine\registry.pol"
"%~dp0\Meta\LGPO.exe" /u "%~dp0\Meta\Perfect\ServerDomainSysvol\GPO\User\registry.pol"
"%~dp0\Meta\LGPO.exe" /s "%~dp0\Meta\Perfect\ServerDomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf"
"%~dp0\Meta\LGPO.exe" /ac "%~dp0\Meta\Perfect\ServerDomainSysvol\GPO\Machine\microsoft\windows nt\Audit\audit.csv"

echo I have tried to do policies. plez check if i worked... by doing gpedit.msc and magic
