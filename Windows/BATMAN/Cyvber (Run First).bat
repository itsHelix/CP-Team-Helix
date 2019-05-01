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

REM Kills Firfox so it can update
tasklist /FI "IMAGENAME eq firefox.exe" 2>NUL | find /I /N "firefox.exe">NUL
if "%ERRORLEVEL%"=="0" (
	echo Firefox is running!
	echo Attempting to stop...
	cls
	taskkill /IM firefox.exe /F
	cls
	echo The burning dog-cat has been slain.

	REM Do audit POL
	auditpol /set /category:* /success:enable
	auditpol /set /category:* /failure:enable
) else (
	echo Firefox is already indicating stopped.
)

:MENU
echo Choose An option:
echo  __________________________________
echo    1. Does everything
echo    2. After Fire
echo    3. REGISTRY
echo    4. Disable Weak services
echo    5. Are you all out of options? Want to try some experimental stuff?
echo    6. Want to install some dank Apps? Press "6"!
echo    7. Input
echo __________________________________

REM Fetch option
CHOICE /C 1234567 /M "Enter your choice:"
if ERRORLEVEL 7 goto Input
if ERRORLEVEL 6 goto Apps
if ERRORLEVEL 5 goto EXP
if ERRORLEVEL 4 goto weak
if ERRORLEVEL 3 goto Reg1234
if ERRORLEVEL 2 goto AfterFire
if ERRORLEVEL 1 goto all

:Input
set /p Loc="Enter Location: "
echo %Loc%
pause
goto %Loc%

:FirefoxSettings
call %~dp0\Meta\Firefox_Settings.bat
cls
goto Menu

:all
REM Disables remote registy
net start | findstr Remote Registry
if %errorlevel%==0 (
	echo Remote Registry is running!
	echo Attempting to stop...
	net stop RemoteRegistry
	sc config RemoteRegistry start=disabled
	if %errorlevel%==1 echo Stop failed... sorry...
) else (
	echo Remote Registry is already indicating stopped.
)

REM -------------- SECTION --------------
echo. & echo FIREWALL
REM Enables Firewall
netsh advfirewall set allprofiles state on
netsh advfirewall reset
netsh advfirewall show allprofiles
netsh advfirewall firewall set rule name="Remote Assistance (DCOM-In)" new enable=no
netsh advfirewall firewall set rule name="Remote Assistance (PNRP-In)" new enable=no
netsh advfirewall firewall set rule name="Remote Assistance (RA Server TCP-In)" new enable=no
netsh advfirewall firewall set rule name="Remote Assistance (SSDP TCP-In)" new enable=no
netsh advfirewall firewall set rule name="Remote Assistance (SSDP UDP-In)" new enable=no
netsh advfirewall firewall set rule name="Remote Assistance (TCP-In)" new enable=no
netsh advfirewall firewall set rule name="Telnet Server" new enable=no
netsh advfirewall firewall set rule name="netcat" new enable=no
echo. & echo Advanced Port 1
netsh advfirewall set allprofiles state on
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound
netsh advfirewall firewall add rule name="Block135tout" protocol=TCP dir=out remoteport=135 action=block
netsh advfirewall firewall add rule name="Block135uout" protocol=UDP dir=out remoteport=135 action=block
netsh advfirewall firewall add rule name="Block135tin" protocol=TCP dir=in localport=135 action=block
netsh advfirewall firewall add rule name="Block135tout" protocol=UDP dir=in localport=135 action=block
echo. & echo Advanced Port 2
netsh advfirewall firewall add rule name="Block137tout" protocol=TCP dir=out remoteport=137 action=block
netsh advfirewall firewall add rule name="Block137uout" protocol=UDP dir=out remoteport=137 action=block
netsh advfirewall firewall add rule name="Block137tin" protocol=TCP dir=in localport=137 action=block
netsh advfirewall firewall add rule name="Block137tout" protocol=UDP dir=in localport=137 action=block
echo. & echo Advanced Port 3
netsh advfirewall firewall add rule name="Block138tout" protocol=TCP dir=out remoteport=138 action=block
netsh advfirewall firewall add rule name="Block138uout" protocol=UDP dir=out remoteport=138 action=block
netsh advfirewall firewall add rule name="Block138tin" protocol=TCP dir=in localport=138 action=block
netsh advfirewall firewall add rule name="Block138tout" protocol=UDP dir=in localport=138 action=block
echo. & echo Advanced Port 4
netsh advfirewall firewall add rule name="Block139tout" protocol=TCP dir=out remoteport=139 action=block
netsh advfirewall firewall add rule name="Block139uout" protocol=UDP dir=out remoteport=139 action=block
netsh advfirewall firewall add rule name="Block139tin" protocol=TCP dir=in localport=139 action=block
netsh advfirewall firewall add rule name="Block139tout" protocol=UDP dir=in localport=139 action=block

:: Disable default rules.
netsh advfirewall firewall set rule group="Connect" new enable=no
netsh advfirewall firewall set rule group="Contact Support" new enable=no
netsh advfirewall firewall set rule group="Cortana" new enable=no
netsh advfirewall firewall set rule group="DiagTrack" new enable=no
netsh advfirewall firewall set rule group="Feedback Hub" new enable=no
netsh advfirewall firewall set rule group="Microsoft Photos" new enable=no
netsh advfirewall firewall set rule group="OneNote" new enable=no
netsh advfirewall firewall set rule group="Remote Assistance" new enable=no
netsh advfirewall firewall set rule group="Windows Spotlight" new enable=no

:: Delete custom rules in case script has previously run.
netsh advfirewall firewall delete rule name="block_Connect_in"
netsh advfirewall firewall delete rule name="block_Connect_out"
netsh advfirewall firewall delete rule name="block_ContactSupport_in"
netsh advfirewall firewall delete rule name="block_ContactSupport_out"
netsh advfirewall firewall delete rule name="block_Cortana_in"
netsh advfirewall firewall delete rule name="block_Cortana_out"
netsh advfirewall firewall delete rule name="block_DiagTrack_in"
netsh advfirewall firewall delete rule name="block_DiagTrack_out"
netsh advfirewall firewall delete rule name="block_dmwappushservice_in"
netsh advfirewall firewall delete rule name="block_dmwappushservice_out"
netsh advfirewall firewall delete rule name="block_FeedbackHub_in"
netsh advfirewall firewall delete rule name="block_FeedbackHub_out"
netsh advfirewall firewall delete rule name="block_OneNote_in"
netsh advfirewall firewall delete rule name="block_OneNote_out"
netsh advfirewall firewall delete rule name="block_Photos_in"
netsh advfirewall firewall delete rule name="block_Photos_out"
netsh advfirewall firewall delete rule name="block_RemoteRegistry_in"
netsh advfirewall firewall delete rule name="block_RemoteRegistry_out"
netsh advfirewall firewall delete rule name="block_RetailDemo_in"
netsh advfirewall firewall delete rule name="block_RetailDemo_out"
netsh advfirewall firewall delete rule name="block_WMPNetworkSvc_in"
netsh advfirewall firewall delete rule name="block_WMPNetworkSvc_out"
netsh advfirewall firewall delete rule name="block_WSearch_in"
netsh advfirewall firewall delete rule name="block_WSearch_out"

:: Add custom blocking rules.
netsh advfirewall firewall add rule name="block_Connect_in" dir=in program="%WINDIR%\SystemApps\Microsoft.PPIProjection_cw5n1h2txyewy\Receiver.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_Connect_out" dir=out program="%WINDIR%\SystemApps\Microsoft.PPIProjection_cw5n1h2txyewy\Receiver.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_ContactSupport_in" dir=in program="%WINDIR%\SystemApps\ContactSupport_cw5n1h2txyewy\ContactSupport.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_ContactSupport_out" dir=out program="%WINDIR%\SystemApps\ContactSupport_cw5n1h2txyewy\ContactSupport.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_Cortana_in" dir=in program="%WINDIR%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_Cortana_out" dir=out program="%WINDIR%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\SearchUI.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_DiagTrack_in" dir=in service="DiagTrack" action=block enable=yes
netsh advfirewall firewall add rule name="block_DiagTrack_out" dir=out service="DiagTrack" action=block enable=yes
netsh advfirewall firewall add rule name="block_dmwappushservice_in" dir=in service="dmwappushservice" action=block enable=yes
netsh advfirewall firewall add rule name="block_dmwappushservice_out" dir=out service="dmwappushservice" action=block enable=yes
netsh advfirewall firewall add rule name="block_FeedbackHub_in" dir=in program="%ProgramFiles%\WindowsApps\Microsoft.WindowsFeedbackHub_1.1708.2831.0_x64__8wekyb3d8bbwe\PilotshubApp.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_FeedbackHub_out" dir=out program="%ProgramFiles%\WindowsApps\Microsoft.WindowsFeedbackHub_1.1708.2831.0_x64__8wekyb3d8bbwe\PilotshubApp.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_OneNote_in" dir=in program="%ProgramFiles%\WindowsApps\Microsoft.Office.OneNote_17.8625.21151.0_x64__8wekyb3d8bbwe\onenoteim.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_OneNote_out" dir=out program="%ProgramFiles%\WindowsApps\Microsoft.Office.OneNote_17.8625.21151.0_x64__8wekyb3d8bbwe\onenoteim.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_Photos_in" dir=in program="%ProgramFiles%\WindowsApps\Microsoft.Windows.Photos_2017.39091.16340.0_x64__8wekyb3d8bbwe\Microsoft.Photos.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_Photos_out" dir=out program="%ProgramFiles%\WindowsApps\Microsoft.Windows.Photos_2017.39091.16340.0_x64__8wekyb3d8bbwe\Microsoft.Photos.exe" action=block enable=yes
netsh advfirewall firewall add rule name="block_RemoteRegistry_in" dir=in service="RemoteRegistry" action=block enable=yes
netsh advfirewall firewall add rule name="block_RemoteRegistry_out" dir=out service="RemoteRegistry" action=block enable=yes
netsh advfirewall firewall add rule name="block_RetailDemo_in" dir=in service="RetailDemo" action=block enable=yes
netsh advfirewall firewall add rule name="block_RetailDemo_out" dir=out service="RetailDemo" action=block enable=yes
netsh advfirewall firewall add rule name="block_WMPNetworkSvc_in" dir=in service="WMPNetworkSvc" action=block enable=yes
netsh advfirewall firewall add rule name="block_WMPNetworkSvc_out" dir=out service="WMPNetworkSvc" action=block enable=yes
netsh advfirewall firewall add rule name="block_WSearch_in" dir=in service="WSearch" action=block enable=yes
netsh advfirewall firewall add rule name="block_WSearch_out" dir=out service="WSearch" action=block enable=yes


REM -------------- SECTION --------------
:Poll
:AfterFire

secedit /configure /db %windir%\security\local.sdb /cfg %~dp0\Meta\Perfect\local.cfg

REM Enables UAC and other things
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f

REM This registry key enables updates :)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d 4
REM -------------- SECTION --------------
:skip
cls

REM msc
dism /online /disable-feature /featurename:TelnetClient >NUL
dism /online /disable-feature /featurename:TelnetServer >NUL

REM Do not display last user on logon
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v dontdisplaylastusername /t REG_DWORD /f /d 1

cls

:remote
REM Remote services
set /P choice=Disable Remote Services[Y/N]?
if /I "%choice%" EQU "Y" (
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
REM Regardless, set these keys
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V CreateEncryptedOnlyTickets /T REG_DWORD /D 1 /F
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /V fDisableEncryption /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V fAllowFullControl /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\ControlSet001\Control\Remote Assistance" /V fAllowToGetHelp /T REG_DWORD /D 0 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /V AllowRemoteRPC /T REG_DWORD /D 0 /F


REM -------------- SECTION --------------

:Here
cls

:weak
REM Weak services
echo "DISABLING WEAK SERVICES"
dism /online /disable-feature /featurename:IIS-WebServerRole /NoRestart
dism /online /disable-feature /featurename:IIS-WebServer /NoRestart
dism /online /disable-feature /featurename:IIS-CommonHttpFeatures /NoRestart
dism /online /disable-feature /featurename:IIS-HttpErrors /NoRestart
dism /online /disable-feature /featurename:IIS-HttpRedirect /NoRestart
dism /online /disable-feature /featurename:IIS-ApplicationDevelopment /NoRestart
dism /online /disable-feature /featurename:IIS-NetFxExtensibility /NoRestart
dism /online /disable-feature /featurename:IIS-NetFxExtensibility45 /NoRestart
dism /online /disable-feature /featurename:IIS-HealthAndDiagnostics /NoRestart
dism /online /disable-feature /featurename:IIS-HttpLogging /NoRestart
dism /online /disable-feature /featurename:IIS-LoggingLibraries /NoRestart
dism /online /disable-feature /featurename:IIS-RequestMonitor /NoRestart
dism /online /disable-feature /featurename:IIS-HttpTracing /NoRestart
dism /online /disable-feature /featurename:IIS-Security /NoRestart
dism /online /disable-feature /featurename:IIS-URLAuthorization /NoRestart
dism /online /disable-feature /featurename:IIS-RequestFiltering /NoRestart
dism /online /disable-feature /featurename:IIS-IPSecurity /NoRestart
dism /online /disable-feature /featurename:IIS-Performance /NoRestart
dism /online /disable-feature /featurename:IIS-HttpCompressionDynamic /NoRestart
dism /online /disable-feature /featurename:IIS-WebServerManagementTools /NoRestart
dism /online /disable-feature /featurename:IIS-ManagementScriptingTools /NoRestart
dism /online /disable-feature /featurename:IIS-IIS6ManagementCompatibility /NoRestart
dism /online /disable-feature /featurename:IIS-Metabase /NoRestart
dism /online /disable-feature /featurename:IIS-HostableWebCore /NoRestart
dism /online /disable-feature /featurename:IIS-StaticContent /NoRestart
dism /online /disable-feature /featurename:IIS-DefaultDocument /NoRestart
dism /online /disable-feature /featurename:IIS-DirectoryBrowsing /NoRestart
dism /online /disable-feature /featurename:IIS-WebDAV /NoRestart
dism /online /disable-feature /featurename:IIS-WebSockets /NoRestart
dism /online /disable-feature /featurename:IIS-ApplicationInit /NoRestart
dism /online /disable-feature /featurename:IIS-ASPNET /NoRestart
dism /online /disable-feature /featurename:IIS-ASPNET45 /NoRestart
dism /online /disable-feature /featurename:IIS-ASP /NoRestart
dism /online /disable-feature /featurename:IIS-CGI /NoRestart
dism /online /disable-feature /featurename:IIS-ISAPIExtensions /NoRestart
dism /online /disable-feature /featurename:IIS-ISAPIFilter /NoRestart
dism /online /disable-feature /featurename:IIS-ServerSideIncludes /NoRestart
dism /online /disable-feature /featurename:IIS-CustomLogging /NoRestart
dism /online /disable-feature /featurename:IIS-BasicAuthentication /NoRestart
dism /online /disable-feature /featurename:IIS-HttpCompressionStatic /NoRestart
dism /online /disable-feature /featurename:IIS-ManagementConsole /NoRestart
dism /online /disable-feature /featurename:IIS-ManagementService /NoRestart
dism /online /disable-feature /featurename:IIS-WMICompatibility /NoRestart
dism /online /disable-feature /featurename:IIS-LegacyScripts /NoRestart
dism /online /disable-feature /featurename:IIS-LegacySnapIn /NoRestart
dism /online /disable-feature /featurename:IIS-FTPServer /NoRestart
dism /online /disable-feature /featurename:IIS-FTPSvc /NoRestart
dism /online /disable-feature /featurename:IIS-FTPExtensibility /NoRestart
dism /online /disable-feature /featurename:TFTP /NoRestart
dism /online /disable-feature /featurename:TelnetClient /NoRestart
dism /online /disable-feature /featurename:TelnetServer /NoRestart

echo Done with SERVICES/Features simple

pause

REM -------------- SECTION --------------
cls
echo. & echo Configuring services advanced

REM Services that should be burned at the stake.
for %%S in (tapisrv,bthserv,mcx2svc,remoteregistry,seclogon,telnet,tlntsvr,p2pimsvc,simptcp,fax,msftpsvc,nettcpportsharing,iphlpsvc,lfsvc,bthhfsrv,irmon,sharedaccess,xblauthmanager,xblgamesave,xboxnetapisvc) do (
	sc config %%S start= disabled
	sc stop %%S
)

REM Services that are an automatic start.
for %%S in (eventlog,mpssvc) do (
	sc config %%S start= auto
	sc start %%S
)

REM Services that are an automatic (delayed) start.
for %%S in (windefend,sppsvc,wuauserv) do (
	sc config %%S start= delayed-auto
	sc start %%S
)

REM Services that are a manual start.
for %%S in (wersvc,wecsvc) do (
	sc config %%S start= demand
)

echo. & echo Services configured.
cls

REM -------------- SECTION --------------
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

REM -------------- REGIME --------------
:Reg1234
REM Registry things
echo Ready to start REG or at least the things that didn't get done?

REM making it so you can really hidden stuff
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V Hidden /T REG_DWORD /D 1 /F
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V HideFileExt /T REG_DWORD /D 0 /F
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /V ShowSuperHidden /T REG_DWORD /D 1 /F
REM -------------- SECTION --------------
echo ---------- 1 ----------
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V PromptOnSecureDesktop /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V ConsentPromptBehaviorAdmin /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V ConsentPromptBehaviorUser /T REG_DWORD /D 0 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V FilterAdministratorToken /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableInstallerDetection /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableLUA /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V EnableVirtualization /T REG_DWORD /D 1 /F
REM -------------- SECTION --------------
echo ---------- 2 ----------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V AllocateCDRoms /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /V ClearPageFileAtShutdown /T REG_DWORD /D 1 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /V AllocateFloppies /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers" /V AddPrinterDrivers /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /V LimitBlankPasswordUse /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /V AuditBaseObjects /T REG_DWORD /D 1 /F
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /V FullPrivilegeAuditing /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V DontDisplayLastUsername /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V UndockWithoutLogon /T REG_DWORD /D 0 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /V MaximumPasswordAge /T REG_DWORD /D 15 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /V DisablePasswordChange /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /V RequireStrongKey /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /V RequireSignOrSeal /T REG_DWORD /D 1 /F
echo ---------- 3 ----------
reg add HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /V SignSecureChannel /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\Netlogon\Parameters /V SealSecureChannel /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /V DisableCAD /T REG_DWORD /D 0 /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /V RestrictAnonymous /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /V RestrictAnonymousSAM /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /V AutoDisconnect /T REG_DWORD /D 45 /F
echo ---------- 3.5 ----------
reg add HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /V EnableSecuritySignature /T REG_DWORD /D 0 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /V RequireSecuritySignature /T REG_DWORD /D 0 /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /V DisableDomainCreds /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /V EveryoneIncludesAnonymous /T REG_DWORD /D 0 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\LanmanWorkstation\Parameters /V EnablePlainTextPassword /T REG_DWORD /D 0 /F
reg add HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /V NullSessionPipes /T REG_MULTI_SZ /D "" /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedExactPaths /V Machine /T REG_MULTI_SZ /D "" /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\AllowedPaths /V Machine /T REG_MULTI_SZ /D "" /F
reg add HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /V NullSessionShares /T REG_MULTI_SZ /D "" /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\Lsa /V UseMachineId /T REG_DWORD /D 0 /F
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /V EnabledV8 /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Internet Explorer\PhishingFilter" /V EnabledV9 /T REG_DWORD /D 1 /F
reg add HKLM\SYSTEM\CurrentControlSet\Control\CrashControl /V CrashDumpEnabled /T REG_DWORD /D 0 /F
echo ---------- 4 ----------
reg add HKCU\SYSTEM\CurrentControlSet\Services\CDROM /V AutoRun /T REG_DWORD /D 1 /F
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer /V NoDriveTypeAutorun /T REG_DWORD /D 255 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer /V NoDriveTypeAutorun /T REG_DWORD /D 255 /F
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer /V NoAutorun /T REG_DWORD /D 1 /F
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\Explorer /V NoAutorun /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V DisablePasswordCaching /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Internet Explorer\Main" /V DoNotTrack /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Internet Explorer\Download" /V RunInvalidSignatures /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /V LOCALMACHINE_CD_UNLOCK /T REG_DWORD /D 1 /T
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V WarnonBadCertRecving /T REG_DWORD /D /1 /F
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V WarnOnPostRedirect /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V WarnonZoneCrossing /T REG_DWORD /D 1 /F
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /V DisablePasswordCaching /T REG_DWORD /D 1 /F
REM -------------- IE --------------
REM Internet explorer
echo ---------- 5 ----------
auditpol /set /category:* /success:enable
auditpol /set /category:* /failure:enable
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\" /V CachedLogonsCount /T REG_SZ /D 0 /F
reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main" /v DoNotTrack /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Internet Explorer\Download" /v RunInvalidSignatures /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN\Settings" /v LOCALMACHINE_CD_UNLOCK /t REG_DWORD /d 1
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonBadCertRecving /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnOnPostRedirect /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v WarnonZoneCrossing /t REG_DWORD /d 1 /f
reg ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v DisablePasswordCaching /t REG_DWORD /d 1 /f
reg ADD HKCU\SYSTEM\CurrentControlSet\Services\CDROM /v AutoRun /t REG_DWORD /d 1 /f
reg ADD HKLM\SYSTEM\CurrentControlSet\Control\CrashControl /v CrashDumpEnabled /t REG_DWORD /d 0
echo ---------- 6 ----------
REM -------------- Different for Windows 8 + 10 --------------
set /P choice=Windows 8 or 10[Y/N]?
if /I "%choice%" EQU "Y" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /V DisableExceptionChainValidation /T REG_DWORD /D 0 /F
	reg add HKLM\SOFTWARE\Microsoft\PolicyManager\default\Settings\AllowSignInOptions /V value /T REG_DWORD /D 0 /F
	reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DownloadMode /T REG_DWORD /D 0 /F
	reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config /V DODownloadMode /T REG_DWORD /D 0 /F
	REM They kept changing the value name for this, so I'm just doing all of them.
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /V AllowCortana /T REG_DWORD /D 0 /F
	reg add HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config /V AutoConnectAllowedOEM /T REG_DWORD /D 0 /F
	reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSyncNGSC /T REG_DWORD /D 1 /F
	reg add HKLM\Software\Policies\Microsoft\Windows\OneDrive /V DisableFileSync /T REG_DWORD /D 1 /F
	REM Make sure onedrive is dead
	taskkill /f /im OneDrive.exe
	%SystemRoot%\System32\OneDriveSetup.exe /uninstall
	REM Location
	reg add HKLM\Software\Policies\Microsoft\Windows\LocationAndSensors /V DisableWindowsLocationProvider /T REG_DWORD /D 1 /F
	call Policies.bat
) else (
	echo Not Windows 8 or 10
)

REM -------------- ENTERPRISE --------------
set /P choicetwo=Win10Enterprise [Y/N]?
if /I "%choicetwo%" EQU "Y" (
	reg add HLKM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection /V AllowTelemetry /T REG_DWORD /D 0 /F
) else (
	reg add HLKM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection /V AllowTelemetry /T REG_DWORD /D 1 /F
)

set /P choicethree =Server [Y/N]?
if /I "%choicethree%" EQU "Y" (
	call ServerPolicies.bat
) else (
	echo ok oink
)

REM -------------- SERVER --------------
REM Found at https://gallery.technet.microsoft.com/scriptcenter/Windows-Server-Hardening-8f9f23df
set /P choicetwo=Windows Server? [Y/N]?
if /I "%choicetwo%" EQU "Y" (
	set PATH=%PATH%;%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\
	powershell.exe -executionpolicy bypass -file %~dp0\Meta\hardenpolicy.ps1
	cd C:\Windows\System32
	set path=C:\Windows\System32
) else (
	Skipping over %~dp0\Meta\hardenpolicy.ps1
)


REM Windows Update
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V AUOptions /T REG_DWORD /D 4 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V ElevateNonAdmins /T REG_DWORD /D 1 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V IncludeRecommendedUpdates /T REG_DWORD /D 1 /F
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /V ScheduledInstallTime /T REG_DWORD /D 22 /F

REM Misc. Includes Networking Stuff
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

REM -------------- </REGIME> --------------
cls
REM -------------- SECTION --------------
echo Doing Users
call %~dp0\Users.bat
pause
cls
:Apps
REM Applications
echo Starting APPS!

set /P choice=Want to use CHOCO (If you use/don't Chco you will still need to go to ninite.com and finsih installing some apps.)?[Y/N]?
if /I "%choice%" EQU "Y" (
	call %~dp0\Meta\Choco.bat
) else (
	start /wait %~dp0\Meta\MBSASetup-x86-EN.msi
	start /wait %~dp0\Meta\Install.exe
	start %~dp0\Software\PatchMyPC.exe
)

call %~dp0\Meta\Firefox_Settings.bat

cls
echo done
pause
cls
goto Menu

:EXP
REM Experimental, sketchy stuff
color 04
echo. & echo Doing **EXPERIMENTAL**

start %~dp0\Software\SoftwarePolicy220Setup.exe
echo click anything once policy thing has finished
pause
echo Ok so now that thing is done, in your taskbar (bottom right corner) there is a new icon. Click it and select UNLOCK! You will have to do this to countine running the script.
pause
cls
