CHOICE /M "Do you want Echo ON "
if %ERRORLEVEL% EQU 2 @echo off
if %ERRORLEVEL% EQU 1 @echo on
:MENU
color f0
echo Choose An option:
echo ���������������������ͻ
echo �  1. Does everything �
echo �  2. Policies        �
echo �  3. Users           �
echo �  4. Software        �
echo �  5. Input           �
echo �����������������������������������������ͻ
echo �Current options: Current OS = %OS%
echo � 	 Enable RemoteDesktop = %RemoteDesktop%
echo �	 Run hardenpolicy.ps1 = %HPps1%
echo �	 Enable SMB = %SMB%
echo �	 Keep shares = %share%
echo �	 Run Users script = %Users%
echo �	 Run Firefox script = %Firefox%
echo �	 Install/update software = %Software%
echo �����������������������������������������ͼ
pause
