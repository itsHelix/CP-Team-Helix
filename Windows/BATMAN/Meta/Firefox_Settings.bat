cd %appdata%\Mozilla\Firefox\Profiles
for /d %%F in (*) do cd "%%F" & goto :break
:break
copy /y /v %~dp0\Perfect\prefs.js %cd%\sysprefs.js
cls
echo. & echo If you see _user.js.parrot = SUCCESS: No no he's not dead, he's, he's restin'!
echo. & echo You are good!
start /wait firefox about:config
