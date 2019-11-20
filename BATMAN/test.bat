@echo OFF


set regfiles[0]=clearpagefile.reg
set regfiles[1]=Enable_Secure_Sign.reg
set regfiles[2]=Set_SmarScreen_to_Warn.reg
:: set regfiles[3] =
:: set regfiles[4] =
:: set regfiles[5] =

for /F "tokens=2 delims==" %%s in ('set regfiles[') do echo %%s

pause
