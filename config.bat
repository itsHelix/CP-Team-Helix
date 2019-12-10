@echo off
color 1f
if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
CHOICE /M "Do you want Echo OFF?"
if %ERRORLEVEL% EQU 1 @echo off
if %ERRORLEVEL% EQU 2 @echo on

setlocal enabledelayedexpansion

:filename
set /p filename="Enter filename/hostname (no spaces): "
CHOICE /M "Is "%filename%" correct?"
if %ERRORLEVEL% EQU 1 echo ^^! > %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :filename

echo service password-encryption >> %filename%.config.txt
echo ^^! >> %filename%.config.txt
echo hostname %filename% >> %filename%.config.txt
echo ^^! >> %filename%.config.txt
echo ^^! >> %filename%.config.txt
echo ^^! >> %filename%.config.txt
echo ^^! >> %filename%.config.txt

:MENU
cls
color f0
echo Choose An option:
:: For this to show properly use encoding [Windows 1252] it will show as "I" when you do this. if you don't and then save+run it will break!
echo ษออออออออออออออออออออออออป
echo บ  1. Set up a switch
echo บ  2. Set up a default gateway
echo บ  3. Set up a VLAN
echo บ  4. Set up a router
echo บ  5. NAT
echo บ  6. OSPF
echo บ  7.
echo บ  8.
echo บ  9.
echo บ  0. Test
echo ษออออออออออออออออออออออออผ

:: Fetch option
CHOICE /C 1234567890 /M "Enter your choice:"
if %ERRORLEVEL% EQU 10 goto :nat.mask
if %ERRORLEVEL% EQU 9 goto
if %ERRORLEVEL% EQU 8 goto
if %ERRORLEVEL% EQU 7 goto
if %ERRORLEVEL% EQU 6 goto :ospf
if %ERRORLEVEL% EQU 5 goto :NAT
if %ERRORLEVEL% EQU 4 goto :router
if %ERRORLEVEL% EQU 3 goto :vlan
if %ERRORLEVEL% EQU 2 goto :gateway
if %ERRORLEVEL% EQU 1 goto :interface

:ospf
set /p ospf.process="Enter ospf process you want to edit: "
CHOICE /M "Is %ospf.process% correct?"
if %ERRORLEVEL% EQU 2 goto :ospf
if %ERRORLEVEL% EQU 1 echo router ospf %ospf.process% >> %filename%.config.txt

:ospf.id
echo input examples: 200.200.200.3 or x.x.x.x
set /p ospf.id="Enter router id: "
CHOICE /M "Is %ospf.id% correct?"
if %ERRORLEVEL% EQU 2 goto :ospf.id
if %ERRORLEVEL% EQU 1 echo  router-id %ospf.id% >> %filename%.config.txt

:ospf.ip
echo input examples: 200.200.200.3 200.200.200.253 or x.x.x.x y.y.y.y
set /p ospf.ip="Enter ip and mask for ospf area: "
CHOICE /M "Is %ospf.ip% correct?"
if %ERRORLEVEL% EQU 2 goto :ospf.ip
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:ospf.area
set /p ospf.area="Enter ospf area number: "
CHOICE /M "Is %ospf.area% correct?"
if %ERRORLEVEL% EQU 2 goto :ospf.area
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

echo  network %ospf.ip% area %ospf.area%

CHOICE /M "Do you want to add another IP?"
if %ERRORLEVEL% EQU 2 echo . > nul 2>&1
if %ERRORLEVEL% EQU 1 goto :ospf.ip

echo ^^! >> %filename%.config.txt
:goto MENU

:router
cls
echo input examples: FastEthernet0/1 or GigabitEthernet0/1
echo    Fa: FastEthernet
echo    Gi: GigabitEthernet
echo    Ten: Ten GigabitEthernet
set /p interface="Enter interface: "
CHOICE /M "Is %interface% correct?"
if %ERRORLEVEL% EQU 2 goto :router
if %ERRORLEVEL% EQU 1 echo interface %interface% >> %filename%.config.txt

:router.int.description
CHOICE /M "Do you want this interface to have a description?"
if %ERRORLEVEL% EQU 2 goto :end.router.int.description
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:router.description.int.start
cls
set /p router.int.description="Enter a description: "
CHOICE /M "Is %router.int.description% correct?"
if %ERRORLEVEL% EQU 1 echo  description %router.int.description% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :router.int.description.start
:end.router.int.description

:router.ip
cls
CHOICE /M "Do you want this interface to have a static IP?"
if %ERRORLEVEL% EQU 2 goto :end.router.ip
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:router.ip.start
cls
echo input example: 193.104.37.238 255.255.255.252
set /p router.ip="Enter ip for interface: "
CHOICE /M "Is %router.ip% correct?"
if %ERRORLEVEL% EQU 2 goto :router.ip.start
if %ERRORLEVEL% EQU 1 echo  ip address %router.ip% >> %filename%.config.txt
:end.router.ip



CHOICE /M "Do you want to add another interface?"
if %ERRORLEVEL% EQU echo . > nul 2>&1
if %ERRORLEVEL% EQU 1 goto :router

:static.route
:static.route.destination
echo input examples: 200.200.200.3 200.200.200.253 or x.x.x.x y.y.y.y
set /p static.route.destination="Enter static route destination: "
CHOICE /M "Is %static.route.destination% correct?"
if %ERRORLEVEL% EQU 2 goto :static.route.destination
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:static.route.hop
echo input examples: 255.255.255.0 or x.x.x.x
set /p static.route.hop="Enter net hop: "
CHOICE /M "Is %static.route.hop% correct?"
if %ERRORLEVEL% EQU 2 goto :static.route.hop
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

echo ^^! >> %filename%.config.txt

echo ip route %static.route.destination% %static.route.hop% >> %filename%.config.txt

echo ^^! >> %filename%.config.txt
GOTO :MENU

:NAT
:nat.name
set /p nat.name="Enter name of NAT pool: "
CHOICE /M "Is %nat.name% correct?"
if %ERRORLEVEL% EQU 2 goto :nat.name
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:nat.range
echo input examples: 200.200.200.3 200.200.200.253 or x.x.x.x y.y.y.y
set /p nat.range="Enter range of NAT pool: "
CHOICE /M "Is %nat.range% correct?"
if %ERRORLEVEL% EQU 2 goto :nat.range
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:nat.mask
echo input examples: 255.255.255.0 or x.x.x.x
set /p nat.mask="Enter mask of NAT pool: "
CHOICE /M "Is %nat.mask% correct?"
if %ERRORLEVEL% EQU 2 goto :nat.mask
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

echo ip nat pool %nat.name% %nat.range% netmask %nat.mask% >> %filename%.config.txt

pause
:nat.inside
cls
:nat.inside.name
set /p nat.inside.name="Enter name of NAT pool you want to use for inside: "
CHOICE /M "Is %nat.inside.name% correct?"
if %ERRORLEVEL% EQU 2 goto :nat.inside.name
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:nat.inside.access
set /p nat.inside.access="Enter number of access list you want to use for inside: "
CHOICE /M "Is %nat.inside.access% correct?"
if %ERRORLEVEL% EQU 2 goto :nat.inside.access
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

echo ip nat inside source list %nat.inside.access% pool %nat.inside.name% >> %filename%.config.txt

:nat.inside.range
echo input examples: 200.200.200.3 200.200.200.253 or x.x.x.x y.y.y.y
set /p nat.inside.range="Enter range of static NAT: "
CHOICE /M "Is %nat.inside.range% correct?"
if %ERRORLEVEL% EQU 2 goto :nat.inside.range
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

echo ip nat inside source static %nat.inside.range% >> %filename%.config.txt

:access
:access.name
echo input examples: 172.16.1.0 0.0.0.255 or x.x.x.x y.y.y.y
set /p access.name="Enter number of access list you want to add ips to: "
CHOICE /M "Is %access.name% correct?"
if %ERRORLEVEL% EQU 2 goto :access.name
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:access.ip
set /p access.ip="Enter IP access list should permit: "
CHOICE /M "Is %access.ip% correct?"
if %ERRORLEVEL% EQU 2 goto :access.ip
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1
echo access-list %access.name% permit %access.ip% >> %filename%.config.txt

CHOICE /M "Do you want to permit another IP?"
if %ERRORLEVEL% EQU 2 echo . > nul 2>&1
if %ERRORLEVEL% EQU 1 goto :access.ip

echo ^^! >> %filename%.config.txt
GOTO :MENU





:vlan
set /p vlan="Enter vlan number: "
CHOICE /M "Is %vlan% correct?"
if %ERRORLEVEL% EQU 1 echo interface Vlan%vlan% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :vlan

:vlan.ip
cls
CHOICE /M "Do you want this Vlan to have an IP?"
if %ERRORLEVEL% EQU 2 goto :end.vlan.ip
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:vlan.ip.start
cls
echo input example: 193.104.37.238 255.255.255.252
set /p vlan.ip="Enter ip for interface: "
CHOICE /M "Is %vlan.ip% correct?"
if %ERRORLEVEL% EQU 1 echo  ip address %vlan.ip% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :vlan.ip.start
:end.vlan.ip

:vlan.description
CHOICE /M "Do you want this vlan to have a description?"
if %ERRORLEVEL% EQU 2 goto :end.vlan.description
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1
:vlan.description.start
cls
set /p vlan.description="Enter a description: "
CHOICE /M "Is %vlan.description% correct?"
if %ERRORLEVEL% EQU 1 echo  description %vlan.description% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :vlan.description.start
:end.vlan.description

echo ^^! >> %filename%.config.txt
goto :MENU

:gateway
cls
echo input examples: 192.168.20.1
set /p gateway="Enter a default gateway: "
CHOICE /M "Is %gateway% correct?"
if %ERRORLEVEL% EQU 1 echo interface %gateway% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :gateway
echo  ip default-gateway %gateway% >> %filename%.config.txt

echo ^^! >> %filename%.config.txt
goto :MENU

:interface
cls
echo input examples: FastEthernet0/1 or GigabitEthernet0/1
echo    Fa: FastEthernet
echo    Gi: GigabitEthernet
echo    Ten: Ten GigabitEthernet
set /p interface="Enter interface: "
CHOICE /M "Is %interface% correct?"
if %ERRORLEVEL% EQU 1 echo interface %interface% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :interface

:int.trunk
cls
CHOICE /M "Do you want this interface to have trunking?"
if %ERRORLEVEL% EQU 1 goto :int.trunk.vlan
if %ERRORLEVEL% EQU 2 goto :int.access

:int.trunk.vlan
cls
echo Vlan example: "40,10,100" or "100"
set /p int.trunk="Enter vlan for interface: "
echo  switchport trunk allowed vlan %int.trunk% >> %filename%.config.txt
echo  switchport mode trunk >> %filename%.config.txt
echo  switchport trunk encapsulation dot1q >> %filename%.config.txt
goto :end.int.access.trunk
:int.access
echo Vlan example: "100"
set /p int.trunk="Enter vlan for interface: "
echo  switchport access vlan %int.trunk% >> %filename%.config.txt
echo  switchport mode access >> %filename%.config.txt
:end.int.access.trunk

:int.ip
cls
CHOICE /M "Do you want this interface to have an IP?"
if %ERRORLEVEL% EQU 2 goto :end.int.ip
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:int.ip.start
cls
echo input example: 193.104.37.238 255.255.255.252
set /p int.ip="Enter ip for interface: "
CHOICE /M "Is %int.ip% correct?"
if %ERRORLEVEL% EQU 2 goto :int.ip.start
if %ERRORLEVEL% EQU 1 echo  ip address %int.ip% >> %filename%.config.txt
:end.int.ip

:interface.shutdown
cls
CHOICE /M "Do you want this interface to be shutdown?"
if %ERRORLEVEL% EQU 1 echo  shutdown >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 echo  no shutdown >> %filename%.config.txt

:int.description
CHOICE /M "Do you want this interface to have a description?"
if %ERRORLEVEL% EQU 2 goto :end.int.description
if %ERRORLEVEL% EQU 1 echo . > nul 2>&1

:int.description.start
cls
set /p int.description="Enter a description: "
CHOICE /M "Is %int.description% correct?"
if %ERRORLEVEL% EQU 1 echo  description %int.description% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :int.description.start
:end.int.description

echo ^^! >> %filename%.config.txt
goto :MENU
