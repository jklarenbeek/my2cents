$DGrps = Get-DistributionGroup;
ForEach ($DGrp in $DGrps) {
  $DGrp.name |Out-file -Filepath c:\DG.csv -Append; 
  $GrpMbrs = Get-DistributionGroupMember -id $DGrp;
  foreach ($GrpMbr in $GrpMbrs) {
    $GrpMbr.DistinguishedName |Out-file -Filepath c:\DG.csv -append; 
  }
}