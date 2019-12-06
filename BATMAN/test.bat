setlocal EnableDelayedExpansion
wmic product get name > temp.txt
for /F "tokens=1,2*" %%x in  (temp.txt) do echo %%x
