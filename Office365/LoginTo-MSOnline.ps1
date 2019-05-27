#Start-Service winrm
#Set-ExecutionPolicy RemoteSigned

Import-Module MSOnline
$user = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $user -Authentication Basic -AllowRedirection
Import-PSSession $session
Connect-MsolService -Credential $user

