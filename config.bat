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

:MENU
cls
color f0
echo Choose An option:
:: For this to show properly use encoding [Windows 1252] it will show as "I" when you do this. if you don't and then save+run it will break!
echo ษออออออออออออออออออออออออป
echo บ  1. Set up an interface
echo บ  2. Set up a default gateway
echo บ  3. Set up a VLAN
echo ษออออออออออออออออออออออออสออออออออออออออออผ

:: Fetch option
CHOICE /C 123456 /M "Enter your choice:"
if %ERRORLEVEL% EQU 6 goto
if %ERRORLEVEL% EQU 5 goto
if %ERRORLEVEL% EQU 4 goto
if %ERRORLEVEL% EQU 3 goto :vlan
if %ERRORLEVEL% EQU 2 goto :gateway
if %ERRORLEVEL% EQU 1 goto :interface

:vlan
set /p vlan="Enter interface: "
CHOICE /M "Is %vlan% correct?"
if %ERRORLEVEL% EQU 1 echo interface Vlan%vlan% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :vlan

:vlan.ip
cls
CHOICE /M "Do you want this Vlan to have an IP?"
if %ERRORLEVEL% EQU 1 goto echo . > nul 2>&1
if %ERRORLEVEL% EQU 2 goto :end.vlan.ip
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
if %ERRORLEVEL% EQU 1 goto echo . > nul 2>&1
if %ERRORLEVEL% EQU 2 goto :end.vlan.description
:vlan.description.start
cls
set /p vlan.description="Enter a default gateway: "
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
if %ERRORLEVEL% EQU 1 goto echo . > nul 2>&1
if %ERRORLEVEL% EQU 2 goto :end.int.ip
:int.ip.start
cls
echo input example: 193.104.37.238 255.255.255.252
set /p int.ip="Enter ip for interface: "
CHOICE /M "Is %int.ip% correct?"
if %ERRORLEVEL% EQU 1 echo  ip address %int.ip% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :int.ip.start
:end.int.ip

:interface.shutdown
cls
CHOICE /M "Do you want this interface to be shutdown?"
if %ERRORLEVEL% EQU 1 echo  shutdown >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 echo  no shutdown >> %filename%.config.txt

:int.description
CHOICE /M "Do you want this interface to have a description?"
if %ERRORLEVEL% EQU 1 goto echo . > nul 2>&1
if %ERRORLEVEL% EQU 2 goto :end.int.description
:int.description.start
cls
set /p int.description="Enter a default gateway: "
CHOICE /M "Is %int.description% correct?"
if %ERRORLEVEL% EQU 1 echo  description %int.description% >> %filename%.config.txt
if %ERRORLEVEL% EQU 2 goto :int.description.start
:end.int.description

goto :MENU
