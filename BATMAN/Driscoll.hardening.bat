:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script Name	: Driscoll.hardening.bat
:: Description	: This is the second edition of a Windows 10, 2016, and 2019 hardening script. It was designed to help security professionals implement very strong security standers into there clients systems. This is in no way a final script, just a starting point for most professionals.
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

set Breaks=N
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
MKDIR %USERPROFILE%\desktop\output > nul 2>&1

:: Copying things from Meta to make the GUIs work
xcopy %~dp0\Meta\dialogboxes\InputBox.exe %windir%\system32 /h /Y > nul 2>&1
xcopy %~dp0\Meta\dialogboxes\InputBox.cs %windir%\system32 /h /Y > nul 2>&1
xcopy %~dp0\Meta\dialogboxes\MultipleChoiceBox.exe %windir%\system32 /h /Y > nul 2>&1
xcopy %~dp0\Meta\dialogboxes\MultipleChoiceBox.cs %windir%\system32 /h /Y > nul 2>&1
xcopy %~dp0\Meta\ntright.exe %windir%\system32 /h /Y > nul 2>&1
xcopy %~dp0\Software\PatchMyPc.exe %windir%\system32 /h /Y > nul 2>&1
xcopy %~dp0\Meta\LGPO.exe %windir%\system32 /h /Y > nul 2>&1
for %%S in ("Adobe","Google","Microsoft","Office 2013","Office 2016","OneDrive For Business","OneDrive NextGen") do (
	xcopy /s %~dp0\Meta\Perfect\"ADMX Templates"\%%S %windir%\PolicyDefinitions /h /Y > nul 2>&1
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
	set server69=Y
	cls
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

::MultipleChoiceBox runs (This add-on was made and distrubuted by Rob van der Woude [https://www.robvanderwoude.com/])
MultipleChoiceBox.exe "Disable_RDP;Disable_SMB;Delete_File_Shares;Firefox_Settings;Users;Disable_features;Firewall_Settings;Update_Policies;Install_IE" "What do you want?" "Batman" /C:2 > temp.txt

::Parsing MultipleChoiceBox
for %%S in (Disable_RDP,Disable_SMB,Delete_File_Shares,Firefox_Settings,Users,Disable_features,Firewall_Settings,Update_Policies,Install_IE) do (
  set %%S = N > nul 2>&1
  FINDSTR /C:%%S temp.txt && if NOT ERRORLEVEL 1 set %%S=Y
)

del temp.txt
if /I %Breaks% EQU "Y" timeout /T 40
cls
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MENU
cls
color f0
echo Choose An option:
:: For this to show properly use encoding [Windows 1252] it will show as "I" when you do this. if you don't and then save+run it will break!
echo ษออออออออออออออออออออออออป
echo บ  1. Does everything    บ
echo บ  2. Policies           บ
echo บ  3. Users              บ
echo บ  4. ________           บ
echo บ  5. Kill Sus. Services บ
echo บ  6. Input              บ
echo ฬออออออออออออออออออออออออสออออออออออออออออป
echo บ Current options: Current OS = %OS%
echo บ 	Disable Disable_RDP = %Disable_RDP%
echo บ 	Disable SMB = %Disable_SMB%
echo บ 	Delete File Shares = %Delete_File_Shares%
echo บ 	Run Users script = %Users%
echo บ 	Run Firefox script = %Firefox_Settings%
echo บ 	Firewall Settings = %Firewall_Settings%
echo บ 	Disable Weak Services = %Disable_features%
echo บ 	Update Policies = %Update_Policies%
echo บ 	Install Internet Explorer = %Install_IE%
echo ศอออออออออออออออออออออออออออออออออออออออออผ

:: Fetch option
CHOICE /C 123456 /M "Enter your choice:"
if %ERRORLEVEL% EQU 6 goto :Input
if %ERRORLEVEL% EQU 5 goto :Task_Kill
if %ERRORLEVEL% EQU 4 echo ERROR && goto :MENU
if %ERRORLEVEL% EQU 3 goto :User_Auditing
if %ERRORLEVEL% EQU 2 goto :Install_LGPO_STIG
if %ERRORLEVEL% EQU 1 goto :Everything

:Input
set /p Loc="Enter Location: "
echo %Loc%, good?
pause
goto %Loc%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Everything
if /I "Run Wmic.bat" EQU "Run Wmic.bat" CALL :Run_Wmic_Info
if /I "Set Auditpol" EQU "Set Auditpol" CALL :Set_Auditpol
if /I "%Firefox_Settings%" EQU "Y" CALL :Change_Firefox_Settings
if /I "%Delete_File_Shares%" EQU "Y" CALL :Delete_File_Shares
if /I "%Install_IE%" EQU "%Install_IE%" CALL :Install_InternetExp
if /I "%Update_Policies%" EQU "Y" CALL :Install_LGPO_STIG
if /I "%Update_Policies%" EQU "Y" CALL :Update_Registry
if /I "%Disable_SMB%" EQU "%Disable_SMB%" CALL :SMB
if /I "%Disable_RDP%" EQU "%Disable_RDP%" CALL :RDP
if /I "%Firewall_Settings%" EQU "Y" CALL :Fix_Firewall_Settings
if /I "%Disable_features%" EQU "Y" CALL :Disable_Weak_Services
if /I "%Disable_features%" EQU "Y" CALL :Disable_Services
if /I "Cleaning Files" EQU "Cleaning Files" CALL :Cleaning_Files
if /I "%Users%" EQU "Y" CALL :User_Auditing
if /I "Flush DNS" EQU "Flush DNS" CALL :Flush_DNS

goto :MENU

:Run_Wmic_Info
call %~dp0\Meta\Sub_Scripts\wmic_info.bat
EXIT /B 0

:Set_Auditpol
auditpol /set /category:* /success:enable
auditpol /set /category:* /failure:enable
EXIT /B 0

:Change_Firefox_Settings
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
EXIT /B 0

:Delete_File_Shares
wmic path Win32_Share delete
EXIT /B 0

:Install_InternetExp
dism /online /enable-feature:"Internet-Explorer-Optional-amd64"
"c:\program files\Mozilla Firefox\firefox.exe" -silent -nosplash -setDefaultBrowser
EXIT /B 0

:Install_LGPO_STIG
if "%OS%" EQU "Windows10" set Operating=true
if "%OS%" EQU "Windows81" set Operating=true
if "%OS%" EQU "Windows8" set Operating=true
if /I "%Operating%" EQU "true" (
  :: Windows 10 and Windows 8.1 and Windows8
  lgpo /g "%~dp0\Meta\Perfect\October 2019 STIG\_Win10"

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
	:: for /F "tokens=2 delims==" %%s in ('set regfiles[') do REGEDIT /S %~dp0\Meta\regfiles\%%s
	REGEDIT /S %~dp0\Meta\regfiles\everything.reg
	auditpol /set /category:* /success:enable
	auditpol /set /category:* /failure:enable
	net accounts /lockoutthreshold:5
	gpupdate /force
	EXIT /B 0
) else (
	CHOICE /M "Are you running 2016?"
	if %ERRORLEVEL% EQU 2 set server69=Y
	if %ERRORLEVEL% EQU 1 set server69=N

	if /I "%server69%" EQU "Y" (
	  :: Windows Server 2016
	  lgpo /g "%~dp0\Meta\Perfect\October 2019 STIG\_Ser16"
		reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /V DisableExceptionChainValidation /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions /V value /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DownloadMode /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DODownloadMode /T REG_DWORD /D 0 /F

		:: They kept changing the value name for this, so I'm just doing all of them.
		reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /V AllowCortana /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config /V AutoConnectAllowedOEM /T REG_DWORD /D 0 /F
		reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSyncNGSC /T REG_DWORD /D 1 /F
		reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSync /T REG_DWORD /D 1 /F

		:: for /F "tokens=2 delims==" %%s in ('set regfiles[') do REGEDIT /S %~dp0\Meta\regfiles\%%s
		REGEDIT /S %~dp0\Meta\regfiles\everything.reg
		auditpol /set /category:* /success:enable
		auditpol /set /category:* /failure:enable
		net accounts /lockoutthreshold:5
		gpupdate /force
		EXIT /B 0
	) else (
	  :: Windows Server 2019
	  lgpo /g "%~dp0\Meta\Perfect\October 2019 STIG\_Ser19"
		reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /V DisableExceptionChainValidation /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions /V value /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DownloadMode /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DODownloadMode /T REG_DWORD /D 0 /F

		:: They kept changing the value name for this, so I'm just doing all of them.
		reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /V AllowCortana /T REG_DWORD /D 0 /F
		reg add HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config /V AutoConnectAllowedOEM /T REG_DWORD /D 0 /F
		reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSyncNGSC /T REG_DWORD /D 1 /F
		reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSync /T REG_DWORD /D 1 /F

		:: for /F "tokens=2 delims==" %%s in ('set regfiles[') do REGEDIT /S %~dp0\Meta\regfiles\%%s
		REGEDIT /S %~dp0\Meta\regfiles\everything.reg
		auditpol /set /category:* /success:enable
		auditpol /set /category:* /failure:enable
		net accounts /lockoutthreshold:5
		gpupdate /force
		EXIT /B 0
	)
)

:Update_Registry
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

:: Regardless, set these keys
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V CreateEncryptedOnlyTickets /T REG_DWORD /D 1 /F
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /V fDisableEncryption /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V fAllowFullControl /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V fAllowToGetHelp /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V AllowRemoteRPC /T REG_DWORD /D 0 /F

:: Security - Do not hide extensions for know file types.
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\HideFileExt" /v "CheckedValue" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
EXIT /B 0

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
	EXIT /B 0
) else (
  :: Disables SMB1
  sc.exe config lanmanworkstation depend= bowser/mrxsmb20/nsi
  sc.exe config mrxsmb10 start= disabled
  :: Disables SMB2/3
  sc.exe config lanmanworkstation depend= bowser/mrxsmb10/nsi
  sc.exe config mrxsmb20 start= disabled
	EXIT /B 0
)

:RDP
if /I "%Disable_RDP%" EQU "Y" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V fDenyTSConnections /T REG_DWORD /D 1 /F
	sc config iphlpsvc start= disabled
	sc stop iphlpsvc
	sc config umrdpservice start= disabled
	sc stop umrdpservice
	sc config termservice start= disabled
	sc stop termservice
	EXIT /B 0
) else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V fDenyTSConnections /T REG_DWORD /D 0 /F
  reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /V UserAuthentication /T REG_DWORD /D 1 /F
	EXIT /B 0
)

:Fix_Firewall_Settings
start %~dp0\Meta\Sub_Scripts\Firewall.bat
EXIT /B 0

:Disable_Weak_Services
start %~dp0\Meta\Sub_Scripts\Features.bat
EXIT /B 0

:Disable_Services
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
	sc config %%S start= disabled > nul 2>&1
	sc stop %%S > nul 2>&1
	echo -
)

:: Services that are an automatic start.
for %%S in (eventlog,mpssvc) do (
	sc config %%S start= auto > nul 2>&1
	sc start %%S > nul 2>&1
	echo -
)

:: Services that are an automatic (delayed) start.
for %%S in (windefend,sppsvc,wuauserv) do (
	sc config %%S start= delayed-auto > nul 2>&1
	sc start %%S > nul 2>&1
	echo -
)

:: Services that are a manual start.
for %%S in (wersvc,wecsvc) do (
	sc config %%S start= demand > nul 2>&1
	echo -
)

echo. & echo Services configured.
EXIT /B 0

:Cleaning_Files
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
echo. & echo Startup files cleanse
EXIT /B 0

:User_Auditing
color 0D
copy %~dp0\Meta\Sub_Scripts\users.ps1 %USERPROFILE%\desktop

pause
set PATH=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\
powershell.exe -executionpolicy bypass -file %USERPROFILE%\desktop\users.ps1
cd C:\Windows\System32
set path=C:\Windows\System32
del %USERPROFILE%\desktop\users.ps1
color 1D

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
color 1f
EXIT /B 0

:Flush_DNS
echo Flushing DNS
ipconfig /flushdns
echo Flushed DNS
echo Clearing contents of: C:\Windows\System32\drivers\etc\hosts
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts
attrib +r +s C:\WINDOWS\system32\drivers\etc\hosts
echo Cleared hosts file
EXIT /B 0



:Task_Kill
cls
tasklist /SVC
set /p kill="Enter PID of service you want DEAD: "
taskkill /F /PID %kill%
CHOICE /M "Any more services? (Y,N)"
if %ERRORLEVEL% EQU 1 goto :TaskKill
cls
pause
goto :MENU
