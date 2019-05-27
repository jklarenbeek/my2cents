Import-Csv .\ExternalContacts.csv | ForEach {
	$NewMailContactParams = @{
        Name = $_.Name
        ExternalEmailAddress = $_.ExternalEmailAddress
    }
	if(($_.Alias)) {$NewMailContactParams.Add("Alias",$_.Alias)}
	if(($_.DisplayName)) {$NewMailContactParams.Add("DisplayName",$_.DisplayName)}
	if(($_.FirstName)) {$NewMailContactParams.Add("FirstName",$_.FirstName)}
	if(($_.Initials)) {$NewMailContactParams.Add("Initials",$_.Initials)}
	if(($_.LastName)) {$NewMailContactParams.Add("LastName",$_.LastName)}

	New-MailContact @NewMailContactParams

	$SetContactParams = @{
		Identity = $_.Name
	}
	if(($_.StreetAddress)) {$SetContactParams.Add("StreetAddress",$_.StretAddress)}
	if(($_.City)) {$SetContactParams.Add("City",$_.City)}
	if(($_.StateOrProvince)) {$SetContactParams.Add("StateOrProvince",$_.StateOrProvince)}
	if(($_.PostalCode)) {$SetContactParams.Add("PostalCode",$_.PostalCode)}
	if(($_.CountryOrRegion)) {$SetContactParams.Add("CountryOrRegion",$_.CountryOrRegion)}
	if(($_.Phone)) {$SetContactParams.Add("Phone",$_.Phone)}
	if(($_.OtherTelephone)) {$SetContactParams.Add("OtherTelephone",$_.OtherTelephone)}
	if(($_.MobilePhone)) {$SetContactParams.Add("MobilePhone",$_.MobilePhone)}
	if(($_.HomePhone)) {$SetContactParams.Add("HomePhone",$_.HomePhone)}
	if(($_.OtherHomePhone)) {$SetContactParams.Add("OtherHomePhone",$_.OtherHomePhone)}
	if(($_.Fax)) {$SetContactParams.Add("Fax",$_.Fax)}
	if(($_.OtherFax)) {$SetContactParams.Add("OtherFax",$_.OtherFax)}
	if(($_.Company)) {$SetContactParams.Add("Company",$_.Company)}
	if(($_.Title)) {$SetContactParams.Add("Title",$_.Title)}
	if(($_.WebPage)) {$SetContactParams.Add("WebPage",$_.WebPage)}
	if(($_.Notes)) {$SetContactParams.Add("Notes",$_.Notes)}
	
	Set-Contact @SetContactParams

	$SetMailContactParams = @{
		Identity = $_.Name
	}
	if(($_.CustomAttribute1)) {$SetMailContactParams.Add("CustomAttribute1",$_.CustomAttribute1)}
	if(($_.CustomAttribute2)) {$SetMailContactParams.Add("CustomAttribute2",$_.CustomAttribute2)}

	Set-MailContact @SetMailContactParams
    
	$MailContact = Get-MailContact $_.Name
   	if(($_.Email2)) {$MailContact.EmailAddresses.Add($_.Email2)}
   	if(($_.Email3)) {$MailContact.EmailAddresses.Add($_.Email3)}

    if($MailContact.EmailAddresses.Count -gt 1) {
    	Set-MailContact $_.Name -EmailAddresses @{Add=$MailContact.EmailAddresses}
    }
}