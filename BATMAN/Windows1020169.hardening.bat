:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script Name	: Windows1020169.hardening.bat
:: Description	: This is a Windows 10, 2016, and 2019 hardening script. It was designed to help security professionals implement very strong security standers into there clients systems. This is in no way a final script, just a starting point for most professionals.
:: Users section: The ":Users" section of this script is made for CyberPatiot 2015-2022.
:: Helpers      : Tavin Turner, Abhinav Vemulapalli
:: Author      	: Ian Boraks
:: StackOverflow: https://stackoverflow.com/users/11013589/cutwow475
:: GitHub       : https://github.com/Cutwow
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
color 1f
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
CHOICE /M "Do you want Echo OFF?"
if %ERRORLEVEL% EQU 1 @echo off
if %ERRORLEVEL% EQU 2 @echo on

CHOICE /M "Do you want Breaks OFF?"
if %ERRORLEVEL% EQU 1 set Breaks=N
if %ERRORLEVEL% EQU 2 set Breaks=Y

setlocal enabledelayedexpansion

:: Check for admin rights
echo Checking if script contains Administrative rights...
net sessions
if %errorlevel%==0 (
	echo Success!
	cls
) else (
	cls
	echo You are not an admin, please run with Administrative rights if you want to the script to work!
	pause
  cls
  echo You have chose to run the script without Aministrative Rights, "Good Luck!"
	pause
)

:: Setting some stuff up
MKDIR %USERPROFILE%\desktop\output

:: Copying things from Meta to make the GUIs work
xcopy %~dp0\Meta\dialogboxes\InputBox.exe %windir%\system32 /h /Y
xcopy %~dp0\Meta\dialogboxes\InputBox.cs %windir%\system32 /h /Y
xcopy %~dp0\Meta\dialogboxes\MultipleChoiceBox.exe %windir%\system32 /h /Y
xcopy %~dp0\Meta\dialogboxes\MultipleChoiceBox.cs %windir%\system32 /h /Y
xcopy %~dp0\Meta\ntright.exe %windir%\system32 /h /Y
xcopy %~dp0\Software\PatchMyPc.exe %windir%\system32 /h /Y
for %%S in ("Adobe","Google","Microsoft","Office 2013","Office 2016","OneDrive For Business","OneDrive NextGen") do (
	xcopy /s %~dp0\Meta\Perfect\"ADMX Templates"\%%S %windir%\PolicyDefinitions /h /Y
)

:: Operating System (thank you to, Compo [user:6738015], user on stackoverflow)
Set "_P="
For /F "EOL=P Tokens=*" %%A In ('"WMIC OS Get ProductType,Version 2>Nul"'
) Do For /F "Tokens=1-3 Delims=. " %%B In ("%%A") Do Set /A _P=%%B,_V=%%C%%D
if Not Defined _P Exit /B
if %_V% Lss 62 Exit /B
if %_P% Equ 1 (if %_V% Equ 62 Set "OS=Windows8"
    if %_V% Equ 63 Set "OS=Windows81"
    if %_V% Equ 100 Set "OS=Windows10"
) Else if %_V% Equ 100 (
	Set "OS=Server2016"
	cls
	CHOICE /M "Are you running 2016?"
	if %ERRORLEVEL% EQU 1 set server69=Y
	if %ERRORLEVEL% EQU 2 set server69=N
) Else Exit /B
if /I %Breaks% EQU "Y" timeout /T 40

:: Operating System "bit" (thank you to, Iridium [user:381588], user on stackoverflow)
if "%PROCESSOR_ARCHITECTURE%" EQU "x86" (
    if "%PROCESSOR_ARCHITEW6432%" EQU "AMD64" (
        :: 64 bit OS, but running a 32 bit command prompt
        set bit=64
    ) else (
        :: 32 bit OS
        set bit=32
    )
) else (
    :: 64 bit OS
    set bit=64
)
if /I %Breaks% EQU "Y" timeout /T 40

:options

::MultipleChoiceBox runs (This add-on was made and distrubuted by Rob van der Woude [https://www.robvanderwoude.com/])
MultipleChoiceBox.exe "Disable_RDP;Disable_SMB;Delete_File_Shares;Firefox_Settings;Update_Software_with_PatchMyPc;Users;Disable_features;Firewall_Settings;Run_Everything.exe" "What do you want?" "Batman" /C:2 > temp.txt

::Parsing MultipleChoiceBox
for %%S in (Disable_RDP,Disable_SMB,Delete_File_Shares,Firefox_Settings,Update_Software_with_PatchMyPc,Users,Disable_features,Firewall_Settings,Run_Everything.exe) do (
  set %%S = N
  FINDSTR /C:%%S temp.txt && if NOT ERRORLEVEL 1 set %%S=Y
)

del temp.txt
if /I %Breaks% EQU "Y" timeout /T 40
cls
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MENU
color f0
echo Choose An option:
:: For this to show properly use encoding [Windows 1252] it will show as "I" when you do this. if you don't and then save+run it will break!
echo ษออออออออออออออออออออออออป
echo บ  1. Does everything    บ
echo บ  2. Policies           บ
echo บ  3. Users              บ
echo บ  4. Software           บ
echo บ  5. Kill Sus. Services บ
echo บ  6. Input              บ
echo ฬออออออออออออออออออออออออสออออออออออออออออป
echo บ Current options: Current OS = %OS%
echo บ Disable Disable_RDP = %Disable_RDP%
echo บ Disable SMB = %Disable_SMB%
echo บ Delete File Shares = %Delete_File_Shares%
echo บ Run Users script = %Users%
echo บ Run Firefox script = %Firefox_Settings%
echo บ Update Software = %Update_Software_with_PatchMyPc%
echo บ Firewall Settings = %Firewall_Settings%
echo บ Disable Weak Services = %Disable_features%
echo บ Run Everything.exe = %Run_Everything.exe%
echo ศอออออออออออออออออออออออออออออออออออออออออผ

:: Fetch option
CHOICE /C 123456 /M "Enter your choice:"
if %ERRORLEVEL% EQU 6 goto :Input
if %ERRORLEVEL% EQU 5 goto :TaskKill
if %ERRORLEVEL% EQU 4 goto :Software
if %ERRORLEVEL% EQU 3 goto :Users
if %ERRORLEVEL% EQU 2 goto :policies
if %ERRORLEVEL% EQU 1 goto :Everything

:Input
set /p Loc="Enter Location: "
echo %Loc%, good?
pause
goto %Loc%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Everything

:Wmic_Info
:: This simple script was made by Ruben Boonen (also known to some as b33f), and modified for use in this script.
:: You can find this one and more like it at https://www.fuzzysecurity.com/index.html
call %~dp0\Meta\Sub_Scripts\wmic_info.bat

:Auditpol
::Dose audit categorys
auditpol /set /category:* /success:enable
auditpol /set /category:* /failure:enable

:FirefoxSettings

if /I "%Firefox_Settings%" EQU "Y" (
	taskkill /IM firefox.exe /F
	cd %appdata%\Mozilla\Firefox\Profiles
	:: Below: this selects the next folder in the DIR [you have to do this becuase the folder you need to get into is generated at random]
	for /d %%F in (*) do cd "%%F" & goto :break
	:break
	copy /y /v %~dp0\Meta\Perfect\prefs.js %cd%
	cls
	echo. & echo You should be good!
	start firefox about:config
	timeout /T 20
	taskkill /IM firefox.exe /F
)

:share
if /I "%Delete_File_Shares%" EQU "Y" wmic path Win32_Share delete

:InternetExp
dism /online /enable-feature:"Internet-Explorer-Optional-amd64"
"c:\program files\Mozilla Firefox\firefox.exe" -silent -nosplash -setDefaultBrowser

:registry
:: Shows all files even if Super Hidden
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V Hidden /T REG_DWORD /D 1 /F
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V HideFileExt /T REG_DWORD /D 0 /F
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V ShowSuperHidden /T REG_DWORD /D 1 /F

:: Windows Update
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V AUOptions /T REG_DWORD /D 4 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V ElevateNonAdmins /T REG_DWORD /D 1 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V IncludeRecommendedUpdates /T REG_DWORD /D 1 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V ScheduledInstallTime /T REG_DWORD /D 22 /F
sc config wuauserv start= auto
net start wuauserv

:: Netowrking/Miscellaneous
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cdrom" /V AutoRun /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application" /V RestrictGuestAcess /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\System" /V RestrictGuestAcess /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Security" /V RestrictGuestAcess /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V SynAttackProtect /T REG_DWORD /D 2 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V EnableDeadGWDetect /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V EnableICMPRedirect /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V DisableIPSourceRouting /T REG_DWORD /D 2 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V KeepAliveTime /T REG_DWORD /D 300000 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V NoNameReleaseOnDemand /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V TcpMaxConnectResponseRetransmissions /T REG_DWORD /D 2 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V TcpMaxDataRetransmissions /T REG_DWORD /D 3 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /V TcpMaxPortsExhausted /T REG_DWORD /D 5 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /V NoDriveTypeAutorun /T REG_DWORD /D 255 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters" /V LogLevel /T REG_DWORD /D 1 /F

:: Security - Disable Autorun.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoAutorun" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDriveTypeAutoRun" /t REG_DWORD /d 255 /f

:: Privacy/Security - Only download Windows Updates from LAN peers, and Microsoft servers.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 1 /f

::Configuring UAC
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V PromptOnSecureDesktop /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V ConsentPromptBehaviorAdmin /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V ConsentPromptBehaviorUser /T REG_DWORD /D 0 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V FilterAdministratorToken /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableInstallerDetection /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableLUA /T REG_DWORD /D 1 /F >> nul 2>&1
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableVirtualization /T REG_DWORD /D 1 /F

if /I %Breaks% EQU "Y" timeout /T 40
:SMB
:: https://www.alibabacloud.com/help/faq-detail/57499.htm
Dism /online /Get-Features /format:table | find "SMB1Protocol"
if /I "%Disable_SMB%" EQU "N" (
  :: Disable SMB1
  sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi
  sc.exe config mrxsmb10 start= disabled
  :: Enable SMB2/3
  sc.exe config lanmanworkstation depend= bowser/mrxsmb10/mrxsmb20/nsi
  sc.exe config mrxsmb20 start= auto
) else (
  :: Disables SMB1
  sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi
  sc.exe config mrxsmb10 start= disabled
  :: Disables SMB2/3
  sc.exe config lanmanworkstation depend= bowser/mrxsmb10/nsi
  sc.exe config mrxsmb20 start= disabled
)

if /I %Breaks% EQU "Y" timeout /T 40
:Disable_RDP
if /I "%Disable_RDP%" EQU "Y" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V fDenyTSConnections /T REG_DWORD /D 1 /F
	sc config iphlpsvc start= disabled
	sc stop iphlpsvc
	sc config umrdpservice start= disabled
	sc stop umrdpservice
	sc config termservice start= disabled
	sc stop termservice
) else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V fDenyTSConnections /T REG_DWORD /D 0 /F
  reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /V UserAuthentication /T REG_DWORD /D 1 /F
)

:: Regardless, set these keys
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V CreateEncryptedOnlyTickets /T REG_DWORD /D 1 /F
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /V fDisableEncryption /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V fAllowFullControl /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V fAllowToGetHelp /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V AllowRemoteRPC /T REG_DWORD /D 0 /F

if /I %Breaks% EQU "Y" timeout /T 40
:miscellaneous
:: Security - Do not hide extensions for know file types.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt" /v "CheckedValue" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f


:firewall
if /I "%Firewall_Settings%" EQU "Y" start %~dp0\Meta\Sub_Scripts\Firewall.bat
if /I %Breaks% EQU "Y" timeout /T 40

:weak
:: Weak services
if /I "%Disable_features%" EQU "Y" start %~dp0\Meta\Sub_Scripts\Features.bat
if /I %Breaks% EQU "Y" timeout /T 40

:NoLoad
:: Privacy - Stop unneeded services.
net stop DiagTrack
net stop dmwappushservice
net stop RemoteRegistry
net stop RetailDemo
if /I %OS% NEQ "Server2016" net stop WinRM
net stop WMPNetworkSvc

:: Privacy - Delete, or disable, unneeded services.
sc config RemoteRegistry start=disabled
sc config RetailDemo start=disabled
if /I %OS% NEQ "Server2016" sc config WinRM start=disabled
sc config WMPNetworkSvc start=disabled
sc delete DiagTrack
sc delete dmwappushservice

echo Done with SERVICES/Features simple

cls
echo. & echo Configuring services advanced

:: Services that should be burned at the stake.
for %%S in (tapisrv,bthserv,mcx2svc,remoteregistry,seclogon,telnet,tlntsvr,p2pimsvc,simptcp,fax,msftpsvc,nettcpportsharing,iphlpsvc,lfsvc,bthhfsrv,irmon,sharedaccess,xblauthmanager,xblgamesave,xboxnetapisvc) do (
	sc config %%S start= disabled
	sc stop %%S
)

:: Services that are an automatic start.
for %%S in (eventlog,mpssvc) do (
	sc config %%S start= auto
	sc start %%S
)

:: Services that are an automatic (delayed) start.
for %%S in (windefend,sppsvc,wuauserv) do (
	sc config %%S start= delayed-auto
	sc start %%S
)

:: Services that are a manual start.
for %%S in (wersvc,wecsvc) do (
	sc config %%S start= demand
)

echo. & echo Services configured.

if /I %Breaks% EQU "Y" timeout /T 40
cls

:Cleaning
echo. & echo Deleting things
del %APPDATA%\stasks.txt & del %APPDATA%\stasks2.txt

echo. & echo Cleaning startup files
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /VA /F
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce /VA /F
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /VA /F
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce /VA /F

dir /B "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\" >> %~dp0\Output\deletedfiles.txt
del /S "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*" /F /Q
dir /B "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\" >> %~dp0\Output\deletedfiles.txt
del /S "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\*" /F /Q
echo. & echo Startup files cleansed

if /I %Breaks% EQU "Y" timeout /T 40
cls

:Software
if /I "%Update_Software_with_PatchMyPc%" EQU "Y" PatchMyPc /s

:Files
if /I "%Run_Everything.exe%" EQU "Y" (
	start /wait %~dp0\Software\Everything-Setup.exe
)
if /I %Breaks% EQU "Y" timeout /T 40

:Users
if /I "%Users%" EQU "Y" (
	cls
	color 0D
	copy %~dp0\Meta\Sub_Scripts\users.ps1 %USERPROFILE%\desktop

	pause
	set PATH=%PATH%;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\
	powershell.exe -executionpolicy bypass -file %USERPROFILE%\desktop\users.ps1
	cd C:\Windows\System32
	set path=C:\Windows\System32
	del %USERPROFILE%\desktop\users.ps1
	color 1
	if exist C:\Windows\System32\ntrights.exe (
		echo Installation succeeded, managing user rights..
		set remove=("Backup Operators" "Everyone" "Power Users" "Users" "NETWORK SERVICE" "LOCAL SERVICE" "Remote Desktop User" "ANONOYMOUS LOGON" "Guest" "Performance Log Users")
		for %%a in (%remove%) do (
				ntrights -U %%a -R SeNetworkLogonRight
				ntrights -U %%a -R SeIncreaseQuotaPrivilege
				ntrights -U %%a -R SeInteractiveLogonRight
				ntrights -U %%a -R SeRemoteInteractiveLogonRight
				ntrights -U %%a -R SeSystemtimePrivilege
				ntrights -U %%a +R SeDenyNetworkLogonRight
				ntrights -U %%a +R SeDenyRemoteInteractiveLogonRight
				ntrights -U %%a -R SeProfileSingleProcessPrivilege
				ntrights -U %%a -R SeBatchLogonRight
				ntrights -U %%a -R SeUndockPrivilege
				ntrights -U %%a -R SeRestorePrivilege
				ntrights -U %%a -R SeShutdownPrivilege
			)
			ntrights -U "Administrators" -R SeImpersonatePrivilege
			ntrights -U "Administrator" -R SeImpersonatePrivilege
			ntrights -U "SERVICE" -R SeImpersonatePrivilege
			ntrights -U "LOCAL SERVICE" +R SeImpersonatePrivilege
			ntrights -U "NETWORK SERVICE" +R SeImpersonatePrivilege
			ntrights -U "Administrators" +R SeMachineAccountPrivilege
			ntrights -U "Administrator" +R SeMachineAccountPrivilege
			ntrights -U "Administrators" -R SeIncreaseQuotaPrivilege
			ntrights -U "Administrator" -R SeIncreaseQuotaPrivilege
			ntrights -U "Administrators" -R SeDebugPrivilege
			ntrights -U "Administrator" -R SeDebugPrivilege
			ntrights -U "Administrators" +R SeLockMemoryPrivilege
			ntrights -U "Administrator" +R SeLockMemoryPrivilege
			ntrights -U "Administrators" -R SeBatchLogonRight
			ntrights -U "Administrator" -R SeBatchLogonRight
			echo Managed User Rights
	)
)
if /I %Breaks% EQU "Y" timeout /T 40
cls

:flushDNS
echo Flushing DNS
ipconfig /flushdns
echo Flushed DNS
echo Clearing contents of: C:\Windows\System32\drivers\etc\hosts
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts
attrib +r +s C:\WINDOWS\system32\drivers\etc\hosts
echo Cleared hosts file








:policies
set regfiles[0] ="clearpagefile.reg"
set regfiles[1] ="Enable_Secure_Sign.reg"
set regfiles[2] ="Set_SmarScreen_to_Warn.reg"
:: set regfiles[3] =""
:: set regfiles[4] =""
:: set regfiles[5] =""

if "%OS%" EQU "Windows10" set Operating=true
if "%OS%" EQU "Windows81" set Operating=true
if "%OS%" EQU "Windows8" set Operating=true
if /I "%Operating%" EQU "true" (
  :: Windows 10 and Windows 8.1 and Windows8
  "%~dp0\Meta\LGPO.exe" /m "%~dp0\Meta\Perfect\GPOs_10\{C1E55664-D36A-4645-8CDB-6E6DA40EF7E9}\DomainSysvol\GPO\Machine\registry.pol"
  "%~dp0\Meta\LGPO.exe" /s "%~dp0\Meta\Perfect\GPOs_10\{C1E55664-D36A-4645-8CDB-6E6DA40EF7E9}\DomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf"
  "%~dp0\Meta\LGPO.exe" /ac "%~dp0\Meta\Perfect\GPOs_10\{C1E55664-D36A-4645-8CDB-6E6DA40EF7E9}\DomainSysvol\GPO\Machine\microsoft\windows nt\Audit\audit.csv"

  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /V DisableExceptionChainValidation /T REG_DWORD /D 0 /F
  reg add HKLM\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions /V value /T REG_DWORD /D 0 /F
  reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DownloadMode /T REG_DWORD /D 0 /F
  reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DODownloadMode /T REG_DWORD /D 0 /F

  :: They kept changing the value name for this, so I'm just doing all of them.
  reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /V AllowCortana /T REG_DWORD /D 0 /F
  reg add HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config /V AutoConnectAllowedOEM /T REG_DWORD /D 0 /F
  reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSyncNGSC /T REG_DWORD /D 1 /F
  reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSync /T REG_DWORD /D 1 /F

	if /I %Breaks% EQU "Y" timeout /T 40
	for /F "tokens=2 delims==" %%s in ('set regfiles[') do REGEDIT /S %~dp0\Meta\regfiles\%%s
	gpupdate /force
	goto AfterServerPol
)

:Server
if /I "%server69%" EQU "Y" (
  :: Windows Server 2016
  "%~dp0\Meta\LGPO.exe" /m "%~dp0\Meta\Perfect\GPOs_2016\{89ABC832-EBD7-423F-A345-0457D99EA329}\DomainSysvol\GPO\Machine\registry.pol"
  "%~dp0\Meta\LGPO.exe" /s "%~dp0\Meta\Perfect\GPOs_2016\{89ABC832-EBD7-423F-A345-0457D99EA329}\DomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf"
  "%~dp0\Meta\LGPO.exe" /ac "%~dp0\Meta\Perfect\GPOs_2016\{89ABC832-EBD7-423F-A345-0457D99EA329}\DomainSysvol\GPO\Machine\microsoft\windows nt\Audit\audit.csv"
	for /F "tokens=2 delims==" %%s in ('set regfiles[') do REGEDIT /S %~dp0\Meta\regfiles\%%s
	gpupdate /force
) else (
  :: Windows Server 2019
  "%~dp0\Meta\LGPO.exe" /m "%~dp0\Meta\Perfect\GPOs_2019\{E2BBA769-DA8E-4FD4-BFB3-F814034C83AA}\DomainSysvol\GPO\Machine\registry.pol"
  "%~dp0\Meta\LGPO.exe" /s "%~dp0\Meta\Perfect\GPOs_2019\{E2BBA769-DA8E-4FD4-BFB3-F814034C83AA}\DomainSysvol\GPO\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf"
  "%~dp0\Meta\LGPO.exe" /ac "%~dp0\Meta\Perfect\GPOs_2019\{E2BBA769-DA8E-4FD4-BFB3-F814034C83AA}\DomainSysvol\GPO\Machine\microsoft\windows nt\Audit\audit.csv"
	for /F "tokens=2 delims==" %%s in ('set regfiles[') do REGEDIT /S %~dp0\Meta\regfiles\%%s
	gpupdate /force
)
if /I %Breaks% EQU "Y" timeout /T 40
:AfterServerPol

echo. & echo done
pause
exit

:TaskKill
if /I "%TaskKill%" EQU "Y" (
	cls
	tasklist /SVC
	set /p kill="Enter PID of service you want DEAD: "
	taskkill /F /PID %kill%
	CHOICE /M "Any more services? (Y,N)"
	if %ERRORLEVEL% EQU 1 goto :TaskKill
	cls
	pause
	exit
)
