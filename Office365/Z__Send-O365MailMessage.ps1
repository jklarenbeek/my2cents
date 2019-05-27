#DIT SCRIPT WORDT NIET GEBRUIKT VOOR DE NIEUWSBRIEF!
#OOK NIET VOOR ANDERE SCRIPTJES VAN DE NIEUWSBRIEF!

function Send-O365MailMessage {
 
    [CmdletBinding()]
 
    param(
 
      [Parameter(Position=1, Mandatory=$true)]
      [String[]]
      $To,
 
      [Parameter(Position=2, Mandatory=$false)]
      [String[]]
      $Cc,
 
      [Parameter(Position=3, Mandatory=$false)]
      [String[]]
      $Bcc,                    
 
      [Parameter(Position=4, Mandatory=$true)]
      [String]
      $Subject,
 
      [Parameter(Position=5, Mandatory=$true)]
      [String]
      $Body,
 
      [Parameter(Position=6, Mandatory=$false)]
      [Switch]
      $BodyAsHtml,                     
 
      [Parameter(Position=7, Mandatory=$true)]
      [System.Management.Automation.PSCredential]
      $Credential
 
      )
 
           
 
    begin {
      #Load the EWS Managed API Assembly
      Add-Type -Path 'C:\Program Files\Microsoft\Exchange\Web Services\1.1\Microsoft.Exchange.WebServices.dll'
    }
 
    process {
 
      #Insatiate the EWS service object 
      $service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService -ArgumentList Exchange2010_SP1

      #Set the credentials for Exchange Online
      $service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials -ArgumentList $Credential.UserName, $Credential.GetNetworkCredential().Password
 
      #Determine the EWS endpoint using autodiscover
      $service.AutodiscoverUrl($Credential.UserName, {$true})
  
      #Create the email message and set the Subject and Body
      $message = New-Object Microsoft.Exchange.WebServices.Data.EmailMessage -ArgumentList $service
      $message.Subject = $Subject
      $message.Body = $Body
 
      #If the -BodyAsHtml parameter is not used, send the message as plain text                  
      if(!$BodyAsHtml) {
        $message.Body.BodyType = 'Text'
      }                
 
      #Add each specified recipient
      $To | ForEach-Object{
        $null = $message.ToRecipients.Add($_)
      }
 
      #Add each specified carbon copy recipient               
      if($CcRecipients) {
        $CcRecipients | ForEach-Object{
          $null = $message.CcRecipients.Add($_)
        }
      }
 
       #Add each specified blind copy recipient
       if($BccRecipients) {
         $BccRecipients | ForEach-Object{
           $null = $message.BccRecipients.Add($_)
         }
       }
 
       #Send the message and save a copy in the Sent Items folder 
       $message.SendAndSaveCopy()
 
    }
 
}


function Send-SmtpMailMessage {

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
        [Parameter(Mandatory=$true)]
        [String[]]
	    $To = "jklarenbeek@gmail.com", #"nieuwsleden@rigo.nl",
        [Parameter(Mandatory=$false)]
        [String[]]
        $CC,
        [Parameter(Mandatory=$false)]
        [String[]]
        $BCC,
        [Parameter(Mandatory=$false)]
	    $Attachment,
        [Parameter(Mandatory=$true)]
        [String]
	    $Subject,
        [Parameter(Mandatory=$true)]
        [String]
	    $Body
    )
	
    Process{


        $message = New-Object System.Net.Mail.MailMessage( $From , $To )
        if ($CC) { $message.CC = $CC }
        if ($BCC) { $message.BCC = $BCC }

        $message.Subject = $Subject
        $message.Attachments.add($Attachment)
        $message.IsBodyHtml = $true
        $message.Body = $Body
 
        $smtp = New-Object System.Net.Mail.SmtpClient( $SmtpServer , $SmtpServerPort )
        $smtp.EnableSsl = $true
        #$smtp.Credentials = New-Object System.Net.NetworkCredential( $SmtpUser , $SmtpPassword );
        $smtp.Credentials = $credentials
        $smtp.Send( $message )
    }
}
