

# TEST 
#  .\Send-SmtpMailMessage.ps1 -Body (Get-Content .\nieuwsbrief20160919-inlined.html -Encoding "UTF8") -Subject "RIGO Nieuwsbrief - 6 oktober 2016"
#  .\Send-SmtpMailMessage.ps1 -Body (Get-Content .\nieuwsbrief20160919-inlined.html -Encoding "UTF8") -To "johannes.klarenbeek@rigo.nl" -Subject "RIGO Nieuwsbrief - 6 oktober 2016"

# SEND NEWSLETTER
#  .\Send-SmtpMailMessage.ps1 -Body (Get-Content .\nieuwsbrief20160919-inlined.html -Encoding "UTF8") -To "nieuwsbrief@rigo.nl" -BCC @("nieuwsleden@rigo.nl") -Subject "RIGO Nieuwsbrief - 6 oktober 2016"


[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [String]
	$SmtpServer = "pod51017.outlook.com",   #change to your SMTP server
    [Parameter(Mandatory=$false)]
    [Int]
	$SmtpServerPort = 587,
    [Parameter(Mandatory=$true)]
    [System.Management.Automation.PSCredential]
    $Credentials,
    [Parameter(Mandatory=$false)]
    [String]
	$From = "nieuwsbrief@rigo.nl",   #Email account you want to send from
    [Parameter(Mandatory=$false)]
    [String]
	$To = "nbgroep@rigo.nl", # "nieuwsleden@rigo.nl",
    [Parameter(Mandatory=$false)]
    [String[]]
    $CC,
    [Parameter(Mandatory=$false)]
    [String[]]
    $BCC, # @("nieuwsleden@rigo.nl")
    [Parameter(Mandatory=$false)]
	$Attachment,
    [Parameter(Mandatory=$true)]
    [String]
	$Subject,
    [Parameter(Mandatory=$True)] #,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [Object[]]
	$Body
)
	
Process{

    $message = New-Object System.Net.Mail.MailMessage( $From , $To )

    foreach($addr in $CC) {
        $message.CC.Add((New-Object system.Net.Mail.mailaddress $addr))
    }
    foreach($addr in $BCC) {
        $message.BCC.Add((New-Object system.Net.Mail.mailaddress $addr))
    }

    $message.Subject = $Subject
    if ($Attachment) { $message.Attachments.add($Attachment) }
    $message.IsBodyHtml = $true
    $message.BodyEncoding = [System.Text.Encoding]::UTF8
    $message.Body = $Body

    $smtp = New-Object System.Net.Mail.SmtpClient( $SmtpServer , $SmtpServerPort )
    $smtp.EnableSsl = $true
    $smtp.Credentials = $credentials
    $smtp.Send( $message )

}


