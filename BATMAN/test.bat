@echo OFF
setlocal enabledelayedexpansion

::MultipleChoiceBox runs (This add-on was made and distrubuted by Rob van der Woude [https://www.robvanderwoude.com/])
MultipleChoiceBox.exe "Disable_RDP;Disable_SMB;Delete_File_Shares;Firefox_Settings;Update_Software_with_PatchMyPc;Users;Disable_features;Firewall_Settings;Run_Everything.exe" "What do you want?" "Batman" /C:2 > temp.txt

::Parsing MultipleChoiceBox
for %%S in (Disable_RDP,Disable_SMB,Delete_File_Shares,Firefox_Settings,Update_Software_with_PatchMyPc,Users,Disable_features,Firewall_Settings,Run_Everything.exe) do (
  set %%S = N
  FINDSTR /C:%%S temp.txt && if NOT ERRORLEVEL 1 set %%S=Y
	set %%S
)
pause

del temp.txt
cls
