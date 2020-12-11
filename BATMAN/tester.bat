CHOICE /M "Are you running 2019?"
if %ERRORLEVEL% EQU 2 set server69=true
if %ERRORLEVEL% EQU 1 set server69=flase

if /I "%server69%" EQU "true" (
  echo 2016
) else (
  echo server 2019
)

pause
