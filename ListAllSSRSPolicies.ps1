#---------------------------------------------
# Author:	Craig Porteous
#		@cporteous
# Synopsis: 	List out all SSRS (native mode)
#		folders & their security policies
#		& output dataset to CSV file
#---------------------------------------------
 
Clear-Host
$ReportServerUri = 'http://chdc/ReportServer_DEV/ReportService2010.asmx'
$InheritParent = $true
$SSRSroot = "/"
$rsPerms = @()
$rsResult = @()
 
$rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
#List out all subfolders under the parent directory and Select their "Path"
$folderList = $rsProxy.ListChildren($SSRSroot, $InheritParent) | Select -Property Path, TypeName | Where-Object {$_.TypeName -eq "Folder"} | Select Path
#Iterate through every folder 
foreach($folder in $folderList)
{
	#Return all policies on this folder
	$Policies = $rsProxy.GetPolicies( $folder.Path, [ref] $InheritParent )
	#For each policy, add details to an array
	foreach($rsPolicy in $Policies)
	{
		[array]$rsResult = New-Object PSObject -Property @{
		"Path" = $folder.Path;
		"GroupUserName" = $rsPolicy.GroupUserName;
		"Role" = $rsPolicy.Roles[0].Name
		}
		$rsPerms += $rsResult
	}
}
#Output array to csv named after instance URL		
$rsPerms | Export-Csv -Path "U:\Target\SSRS_SQL9_Prod_AllPolicies.csv" -NoTypeInformation
