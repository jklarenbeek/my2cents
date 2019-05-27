#####################################
#                                   #
# Script to retreive group members  #  
#                                   #
#    Karl Mitschke March 7 2008     #
#                                   #
#####################################

#
# usage : 
# get-exgrouprecurse <groupname> will display group members and the subgroup on screen
#
# $group = get-exgrouprecurse <groupname> 
# $group |Export-Csv <file name> -NoTypeInformation will export the group members to a file
#

######################################
#  heavily modified from recipe 7.3  # 
#   in 'Active Directory Cookbook'   #
#          by Robbie Allen           #
######################################

#requires -pssnapin Microsoft.Exchange.Management.PowerShell.Admin
param($group)
$UnknownGroup = @{}
function DisplayMembers($group)
{
	$SubGroup = @{}
	$AllMembers = @()
	if(!$group)
	{
		$group = Read-Host "Enter the groups display name"
	}
	if ($group.Contains("'"))
	{
		$group = $group.Replace("'",'"')
	}
	if ($group -eq "/?")
	{
		Write-Host "Usage:"
		Write-Host ""
		Write-Host "get-exgrouprecurse -group <group name>"
		Write-Host ""
		Write-Host "or get-exgrouprecurse <group name>"
		Write-Host "Returns an object containing the group member, and the group name."
		break
	}
	
	$validate = Get-Group $group
	if ($validate.RecipientTypeDetails.ToString() -match "mail")
	{
		$searchGroup = Get-DistributionGroupMember $group
		if ($searchGroup)
		{	
			foreach ($member in $searchGroup)
			{
				$membertype = $member.RecipientTypeDetails
				if($membertype -match "Group")
				{
					$samname = $member.SamAccountName.ToString()
					if ($SubGroup.ContainsKey($samname) -eq $true)
					{
 						Write-Output "^ already seen group member (stopping to avoid loop)"
					}
		         	else
					{
						$SubGroup.Add($samname,$member.DisplayName.ToString())
					}
				}	
				else
				{
					if($member.PrimarySmtpAddress -and $member.RecipientTypeDetails -notcontains "group")
					{
						$obj = new-object psObject
						$obj | Add-Member -membertype noteproperty -name GroupMember -Value $member
						$obj | Add-Member -MemberType noteproperty -Name GroupName -Value $group
						$AllMembers += $obj
					}					
				}
			}
		}
		else
		{
			$UnknownGroup.add($group,1)
		}
		if($SubGroup.Values.Count -gt 0)
		{
			foreach ($subGroup in $SubGroup.values)
			{
				DisplayMembers $subGroup
			}
		}
		if ($UnknownGroup.Keys.Count -gt 0)
		{
			foreach ($LostGroup in $UnknownGroup.keys)
			{
				$obj = new-object psObject
				$obj | Add-Member -membertype noteproperty -name GroupMember -Value "Cannot enumerate group"
				$obj | Add-Member -MemberType noteproperty -Name GroupName -Value $LostGroup
				$AllMembers += $obj
			}
			$UnknownGroup.Clear()
		}	
	}	
	else
	{
		Write-Output "$group does not appear to be mail enabled."
	}
	Write-Output $AllMembers 
}
DisplayMembers $group