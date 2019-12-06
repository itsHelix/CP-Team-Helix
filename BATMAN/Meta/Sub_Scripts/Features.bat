@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script Name	: Windows1020169.hardening.bat
:: Description	: This is a Windows 10, 2016, and 2019 hardening script. It was designed to help security professionals implement very strong security standers into there clients systems. This is in no way a final script, just a starting point for most professionals.
:: Users section: The ":Users" section of this script is made for CyberPatiot 2015-2022.
:: Helpers      : Tavin Turner, Abhinav Vemulapalli
:: Author      	: Ian Boraks
:: StackOverflow: https://stackoverflow.com/users/11013589/cutwow475
:: GitHub       : https://github.com/Cutwow
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
color 1f
echo "DISABLING WEAK Features"
for %%S in (IIS-WebServerRole,IIS-WebServer,IIS-CommonHttpFeatures,IIS-HttpErrors,IIS-HttpRedirect,IIS-ApplicationDevelopment,IIS-NetFxExtensibility,IIS-NetFxExtensibility45,IIS-HealthAndDiagnostics,IIS-HttpLogging,IIS-LoggingLibraries,IIS-RequestMonitor,IIS-HttpTracin,g,IIS-Security,IIS-URLAuthorization,IIS-RequestFiltering,IIS-IPSecurity,IIS-Performance,IIS-HttpCompressionDynamic,IIS-WebServerManagementTools,IIS-ManagementScriptingTools,IIS-IIS6ManagementCompatibility,IIS-Metabase,IIS-HostableWebCore,IIS-StaticContent,IIS-DefaultDocument,IIS-DirectoryBrowsing,IIS-WebDAV,IIS-WebSockets,IIS-ApplicationInit,IIS-ASPNET,IIS-ASPNET45,IIS-ASP,IIS-CGI,IIS-ISAPIExtensions,IIS-ISAPIFilter,IIS-ServerSideIncludes,IIS-CustomLogging,IIS-BasicAuthentication,IIS-HttpCompressionStatic,IIS-ManagementConsole,IIS-ManagementService,IIS-WMICompatibility,IIS-LegacyScripts,IIS-LegacySnapIn,IIS-FTPServer,IIS-FTPSvc,IIS-FTPExtensibility,TFTP,TelnetClient,TelnetServer) do (
	dism /online /disable-feature /featurename:%%S /NoRestart > nul 2>&1
	echo -
)
exit
