This works on my SBS 2008 box. Nice if anybody out there could test the script as well. There are some quirks with PowerShell v1 (and my thinking). You can easily add a Write-Host $_ before the For loop and Write-Host $member inside the For loop to get screen output or just see what is going on.  
 
 
 
# Initialize array with two fields:
 
# Distribution group, Members
 
$totalObj = @()
 
 
 
# Retrieve all DGs
 
$temp = Get-DistributionGroup -ResultSize Unlimited |  

       

       # Loop through all distribution groups
 
       ForEach-Object {           

       

             # Add the members of the DG to an array
 
             [array]$mem = Get-DistributionGroupMember -id $_      

             

             # Loop through the DG and assign each member name to the variable $member
 
             for ($i = 0; $i -lt $mem.Count; $i++) {
 
                    $member = $mem[$i].name
 
                    

                    # Create instance of object of type .NET
 
                    $obj = New-Object System.Object
 
       

                    # Add the name of the DG to the object
 
                    $obj | Add-Member -MemberType NoteProperty -Value $_.Name -Name 'Distribution Group' -Force
 
                    

                    # Add the member name to the object
 
                    $obj | Add-Member -MemberType NoteProperty -Value $member -Name 'Members' -Force -PassThru
 
                    

                    # Add the object to the array
 
                    $totalObj += $obj
 
             }
 
       } 

 
 
# Pipe output to .csv file
 
$totalObj | Export-Csv -Encoding 'Unicode' c:\temp\ngtest.csv
 
 
 
The output is written like this to the csv. file:
 
 
 
"Distribution Group",Members
 
"All Users","Jon-Alfred Smith"
 
"All Users","Julie Smith"
 
"Windows SBS Administrators","Standard User with administration links"
 
"Windows SBS Administrators","Jon-Alfred Smith"


 
If you just want to have the name of the DG once, change this line: Only add the name the first time, when the counter is zero:
 
 
 
# Add the name of the DG to the object
 
if ($i -eq 0) {
 
$obj | Add-Member -MemberType NoteProperty -Value $_.Name -Name 'Distribution Group' -Force
 
}
 
 
