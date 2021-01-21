
#---------------------------------------------
# Author:	Craig Porteous
#		@cporteous
# Synopsis:	Remove a specific user/group from 
#		all SSRS (native mode) folders. 
#		Excludes inherited folders
#---------------------------------------------
 
Clear-Host
$ReportServerUri = 'http://chdc/ReportServer_DEV/ReportService2010.asmx'
$InheritParent = $true
$GroupUserName = 'uboc-ad\rx95913'
 
$rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
#List out all subfolders under the parent directory
$items = $rsProxy.ListChildren("/", $true) | `
         SELECT TypeName, Path, ID, Name | `
         Where-Object {$_.typeName -eq "Folder"}
#Iterate through every folder 		 
foreach($item in $items)
{
	$Policies = $rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
	#Skip over folders marked to Inherit permissions. No changes needed.
	if($InheritParent -eq $false)
	{
		#List out ALL policies on folder but do not include the policy for the specified user/group
		$Policies = $Policies | Where-Object { $_.GroupUserName -ne $GroupUserName }
		#Set the folder's policies to this new set of policies
		$rsProxy.SetPolicies($Item.Path, $Policies);
	}
}
