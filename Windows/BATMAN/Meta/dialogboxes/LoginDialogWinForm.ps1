# PowerShell login dialog using Windows Forms.
# This script is for demonstration purposes only: if you really need a
# login dialog, use PowerShell's built-in Get-Credential cmdlet instead
#
# Form created with the PoshGUI Editor
# https://poshgui.com/Editor
#
# Event handling edited by Rob van der Woude
# https://www.robvanderwoude.com

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles( )

$dialog            = New-Object System.Windows.Forms.Form
$dialog.ClientSize = '300,200'
$dialog.text       = "Login"
$dialog.TopMost    = $true

$labelName          = New-Object System.Windows.Forms.Label
$labelName.text     = "Name"
$labelName.AutoSize = $true
$labelName.width    = 25
$labelName.height   = 10
$labelName.location = New-Object System.Drawing.Point( 29, 40 )
$labelName.Font     = 'Microsoft Sans Serif,10'

$textboxName           = New-Object System.Windows.Forms.TextBox
# Default login name is %UserName%
$textboxName.Text      = [System.Environment]::UserName
$textboxName.multiline = $false
$textboxName.width     = 140
$textboxName.height    = 20
$textboxName.location  = New-Object System.Drawing.Point( 109, 36 )
$textboxName.Font      = 'Microsoft Sans Serif,10'
# When Enter key is pressed while focus is on name field, move focus to password field IF and ONLY IF name field is NOT empty
$textboxName.Add_KeyUp( { if ( ( $_.keyCode -eq 13 ) -and ( $textboxName.Text.Replace( ';', '' ).Trim( ) -match ".+" ) ) { $textboxPassword.focus( ) } } )

$labelPassword          = New-Object System.Windows.Forms.Label
$labelPassword.text     = "Password"
$labelPassword.AutoSize = $true
$labelPassword.width    = 25
$labelPassword.height   = 10
$labelPassword.location = New-Object System.Drawing.Point( 29, 98 )
$labelPassword.Font     = 'Microsoft Sans Serif,10'

$textboxPassword              = New-Object System.Windows.Forms.TextBox
$textboxPassword.multiline    = $false
$textboxPassword.width        = 140
$textboxPassword.height       = 20
$textboxPassword.location     = New-Object System.Drawing.Point( 109, 94 )
$textboxPassword.Font         = 'Microsoft Sans Serif,10'
# Hide the password
$textboxPassword.PasswordChar = '*'
# When Enter key is pressed while focus is on password field, close dialog and return result IF and ONLY IF name and password fields are NOT empty
$textboxPassword.Add_KeyUp( { if ( ( $_.keyCode -eq 13 ) -and ( $textboxPassword.Text.Trim( ) -match ".+" ) -and ( $textboxName.Text.Replace( ';', '' ).Trim( ) -match ".+" ) ) { Write-Host $textboxName.Text.Replace( ';', '' ).Trim( ) -NoNewline; Write-Host ";" -NoNewline; Write-Host $textboxPassword.Text.Trim( ); $dialog.Close( ) } } )

$buttonOK          = New-Object System.Windows.Forms.Button
$buttonOK.text     = "OK"
$buttonOK.width    = 60
$buttonOK.height   = 30
$buttonOK.location = New-Object System.Drawing.Point( 109, 144 )
$buttonOK.Font     = 'Microsoft Sans Serif,10'
# When OK button is clicked, close dialog and return result IF and ONLY IF name and password fields are NOT empty
$buttonOK.Add_Click( { if ( ( $textboxName.Text.Replace( ';', '' ).Trim( ) -match ".+" ) -and ( $textboxPassword.Text.Trim( ) -match ".+" ) ) { Write-Host $textboxName.Text.Replace( ';', '' ).Trim( ) -NoNewline; Write-Host ";" -NoNewline; Write-Host $textboxPassword.Text.Trim( ); $dialog.Close( ) } } )

$buttonCancel          = New-Object System.Windows.Forms.Button
$buttonCancel.text     = "Cancel"
$buttonCancel.width    = 60
$buttonCancel.height   = 30
$buttonCancel.location = New-Object System.Drawing.Point( 189, 144 )
$buttonCancel.Font     = 'Microsoft Sans Serif,10'
# When Cancel button is clicked, close the dialog without returning a result
$buttonCancel.Add_Click( { $dialog.Close( ) } )

$dialog.controls.AddRange( @( $labelName, $textboxName, $labelPassword, $textboxPassword, $buttonOK, $buttonCancel ) )
# Allow Esc key to cancel
$dialog.CancelButton = $buttonCancel

[void] $dialog.ShowDialog( )

