#Remove-Contacts.ps1

$members = Get-DistributionGroupMember NieuwsLeden -ResultSize Unlimited
foreach($member in $members) {
    $id = $member.Identity
    Remove-DistributionGroupMember NieuwsLeden -Member $id -Confirm:$False

    $external = $member.ExternalEmailAddress
    if ($external) {
        Remove-MailContact -Identity $id -Confirm:$False
        Write-Host "Removed-Contact: $id"
    }
    else {
        Write-Host "Removed-Member: $id"
    }

}