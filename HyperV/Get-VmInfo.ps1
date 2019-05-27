function Get-VmInfo
{
    <#

    .SYNOPSIS
    A PowerShell script to retrive Virtual Machines information from one or more Hyper-V servers
   
    .DESCRIPTION
    Retrives Virtual Machine information from Hyper-V servers

    .EXAMPLE
    Get-VmInfo 192.168.17.23, 192.168.16.2 -Credential administrator | Out-GridView

    Retrives the virtual machines information from the two Hyper-V servers 192.168.17.23 and 192.168.16.2
   
    .EXAMPLE
    Get-VmInfo 192.168.17.23 | Out-GridView

    Retrives the virtual machines information from the Hyper-V server 192.168.17.23 with default credentials
   
    .Example
    Get-VmInfo 192.168.17.23, 192.168.16.2 -Credential administrator | Group-Object OS | Format-Table -Property Name, Count
   
    Name                                                                Count
    ----                                                                -----
    Windows Server 2008 R2 Datacenter                                       9
    Windows 7 Ultimate                                                      1
    Windows Server (R) 2008 Datacenter                                      3
   
    .NOTES

    .LINK
    http://mindre.net/post/Retrive-a-list-of-virtual-machines-in-Hyper-V-with-PowerShell.aspx
   
    #>

    Param
    (
    [parameter(Mandatory=$true)]
    [String[]]
    [ValidateNotNullOrEmpty()]
    $HyperVServer,
   
    [parameter(Mandatory=$false)]
    [String]
    [ValidateNotNullOrEmpty()]
    $Credential
    )

    if ($HyperVServer -ne "." -and $Credential -ne "" -and $Credential -ne $null)
    {
        $wmiCredentials = Get-Credential $Credential
    }

    $jobs = @()
   
    foreach ($hvServer in $HyperVServer)
    {
        $jobs += Start-Job -ArgumentList $hvServer, $wmiCredentials -ScriptBlock {
            $hvServer = $args[0]
            $wmiCredentials = $args[1]
           
            $array = @()
           
            if ($wmiCredentials -eq $null)
            {
                $VMs = gwmi -namespace root\virtualization Msvm_VirtualSystemManagementService -computername $hvServer
            }
            else
            {
                $VMs = gwmi -namespace root\virtualization Msvm_VirtualSystemManagementService -computername $hvServer -Credential $wmiCredentials
            }

            $infoArray = 0,1,4,100,101,103,105,106
            $vmInfoArray = $VMs.GetSummaryInformation($null, $infoArray).SummaryInformation
               
            foreach ($vmInfo in [array] $vmInfoArray)
            {               
                switch ($vmInfo.EnabledState)
                {
                    2 { $vmState = "Running" }
                    3 { $vmState = "Stopped" }
                    32768 { $vmState = "Paused" }
                    32769 { $vmState = "Suspended" }
                    32770 { $vmState = "Starting" }
                    32771 { $vmState = "Snapshoting" }
                    32773 { $vmState = "Saving" }
                    32774 { $vmState = "Stopping" }
                    32776 { $vmState = "Pausing" }
                    32777 { $vmState = "Resuming" }
                    default { $vmState = "Unknown" }
                }

                $out = new-object psobject
                $out | add-member noteproperty Server $hvServer
                $out | add-member noteproperty Name $vmInfo.ElementName
                $out | add-member noteproperty State $vmState
               
                if ($vmState -ne "Stopped")
                {
                    $out | add-member noteproperty Memory "$($vmInfo.MemoryUsage) MB"
                    $out | add-member noteproperty Processors $vmInfo.NumberOfProcessors
                    $out | add-member noteproperty Load "$($vmInfo.ProcessorLoad) %"
                    $uptime = [int]($vmInfo.UpTime / 1000)
                    $out | add-member noteproperty UpTime "$([Math]::Floor($uptime / 86400)) days, $([Math]::Floor($uptime / 3600 % 24)) hours, $([Math]::Floor($uptime / 60 % 60)) minutes"
                    $out | add-member noteproperty OS $vmInfo.GuestOperatingSystem
                }
               
                $out | add-member noteproperty Guid $vmInfo.Name
                $array += $out
            }
           
            write-output $array
        }
    }
   
   
    $array = @()
   
    foreach ($job in Wait-Job -Job $jobs)
    {
        $array += Receive-Job $job
    }
   
    Remove-Job -Job $jobs

    write-output $($array | Select-Object Server, Name, State, Memory, Processors, Load, UpTime, OS, Guid | Sort-Object Server, Name)
}