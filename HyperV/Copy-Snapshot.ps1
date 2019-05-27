$wd = (get-date).toString('ddd');
$dt = (get-date).toString('yyyyMMdd');

$MX_SMTPSERVER = "joham-nl.mail.eo.outlook.com"
$MX_FROM = "administratie@joham.nl"
$MX_TO = "beheer@joham.nl"
$MX_SUBJECT = "Automatische Backup "
$MX_SUCCESS = "De automatische backup heeft alle snapshots van afgelopen week gekopieerd naar \\$(Get-Content Env:computername)\snapshot\$dt"
$MX_FAILED = "De automatische backup kan alleen bestanden kopieeren op zondag!"

$smtp = New-Object Net.Mail.SmtpClient($MX_SMTPSERVER)

cd d:\snapshot

if (($wd.StartsWith('zo') -eq $true) -or ($wd.StartsWith('su') -eq $true)) {
    mkdir $dt;
    Write-Host "Copying files (*.sna,*.hsh,*.vhd,*.zip,*.7z to $dt on $wd";
    dir *.sna,*.hsh,*.vhd,*.zip,*.7z | move -destination $dt #-whatif
    Write-Host "Done Copying files!";
    $smtp.Send($MX_FROM,$MX_TO, $MX_SUBJECT, $MX_SUCCESS)
    #Write-Host "Starting Backup";
    #copy $dt -Destination "\\backup\main\$dt" -Recurse -WhatIf
    #Write-Host "Backup Finished";

}
else {
    Write-Host "Can only copy files on sunday!";
    $smtp.Send($MX_FROM,$MX_TO, $MX_SUBJECT, $MX_FAILED)
}
