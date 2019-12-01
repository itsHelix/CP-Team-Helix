for /f "delims=" %%A in ('dir /s /b %WINDIR%\system32\*htable.xsl') do set "var=%%A"

echo "" > %USERPROFILE%\desktop\output\wmic_out.html
wmic process get CSName,Description,ExecutablePath,ProcessId /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic service get Caption,Name,PathName,ServiceType,Started,StartMode,StartName /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic USERACCOUNT list full /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic group list full /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic nicconfig where IPEnabled='true' get Caption,DefaultIPGateway,Description,DHCPEnabled,DHCPServer,IPAddress,IPSubnet,MACAddress /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic volume get Label,DeviceID,DriveLetter,FileSystem,Capacity,FreeSpace /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic netuse list full /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic qfe get Caption,Description,HotFixID,InstalledOn /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic startup get Caption,Command,Location,User /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic PRODUCT get Description,InstallDate,InstallLocation,PackageCache,Vendor,Version /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic os get name,version,InstallDate,LastBootUpTime,LocalDateTime,Manufacturer,RegisteredUser,ServicePackMajorVersion,SystemDirectory /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html
wmic Timezone get DaylightName,Description,StandardName /format:"%var%" >> %USERPROFILE%\desktop\output\wmic_out.html

wmic product get name,version /output:%USERPROFILE%\desktop\output\InstallList.htm product get /format:hform.xsl
