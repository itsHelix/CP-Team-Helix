param(
	[string]$UserName = $null,
	[switch]$TabDelimited,
	[switch]$h,
	[parameter( ValueFromRemainingArguments = $true )]
	[object]$invalidArgs
)

if ( $h -or $invalidArgs ) {
	Write-Host
	Write-Host "LoginDialog.ps1,  Version 1.01"
	Write-Host "Present a login dialog, and return the user name and password"
	Write-Host
	Write-Host "Usage:  " -NoNewline
	Write-Host "./LoginDialog.ps1  [ username ]  [ -TabDelimited ]" -ForegroundColor White
	Write-Host
	Write-Host "Where:  " -NoNewline
	Write-Host "username           " -ForegroundColor White -NoNewline
	Write-Host "is the optional user name presented in the dialog"
	Write-Host "        -TabDelimited      " -ForegroundColor White -NoNewline
	Write-Host "tab delimited output (default delimiter: semicolon)"
	Write-Host
	Write-Host "Written by Rob van der Woude"
	Write-Host "http://www.robvanderwoude.com"
	Exit 1
} else {
	Try
	{
		# Dialog asking for credentials
		$cred = Get-Credential $UserName
		
		# Return username and password, delimited by a semicolon (default) or tab (switch -TabDelimited)
		Write-Host $cred.GetNetworkCredential( ).UserName -NoNewline
		if ( $TabDelimited ) {
			Write-Host "`t" -NoNewline
		} else {
			Write-Host ";" -NoNewline
		}
		Write-Host $cred.GetNetworkCredential( ).Password
	}
	Catch
	{
		Write-Host "-- Canceled --"
		Exit 1
	}
}