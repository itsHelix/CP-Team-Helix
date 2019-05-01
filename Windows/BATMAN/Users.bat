@echo off
color 1f

copy %~dp0\Meta\users.ps1 %USERPROFILE%\desktop
MKDIR %USERPROFILE%\desktop\output

pause

set path=C:\Windows\System32

set /P choice=32 bit system? [Y/N]

if /I "%choice%" EQU "Y" (
	copy /Y %~dp0\Meta\Curlx86\Curl.exe C:\Windows\System32
) else (
	copy /Y %~dp0\Meta\Curlx64\Curl.exe C:\Windows\System32
) 

cd %USERPROFILE%\desktop
cls
echo Please paste in the readme url!
set /p url=
curl %url% > .\output\readme.txt

pause
set PATH=%PATH%;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\
powershell.exe -executionpolicy bypass -file %USERPROFILE%\desktop\users.ps1
cd C:\Windows\System32
set path=C:\Windows\System32
pause