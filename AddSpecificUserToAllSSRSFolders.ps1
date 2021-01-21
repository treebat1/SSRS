
#---------------------------------------------
# Author:	Craig Porteous
#		@cporteous
# Synopsis:	Add a specific user/group to all 
#		SSRS (native mode) folders with a 
#		specified Role. Excludes inherited
#		folders
#---------------------------------------------
 
Clear-Host
$ReportServerUri = 'http://chdc/ReportServer_DEV/ReportService2010.asmx'
#$ReportServerUri = 'http://chdc/ReportServer_PROD/ReportService2010.asmx'
$InheritParent = $true
$GroupUserName = 'UBOC-AD\app_car_svr_monitor'
$RoleName = 'Content Manager'
 
$rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
$type = $rsProxy.GetType().Namespace;
$policyType = "{0}.Policy" -f $type;
$roleType = "{0}.Role" -f $type;
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
		#Return all policies that contain the user/group we want to add
		$Policy = $Policies | 
		    Where-Object { $_.GroupUserName -eq $GroupUserName } | 
		    Select-Object -First 1
		#Add a new policy if doesnt exist
		if (-not $Policy) 
		{
		    $Policy = New-Object ($policyType)
		    $Policy.GroupUserName = $GroupUserName
		    $Policy.Roles = @()
			#Add new policy to the folder's policies
		    $Policies += $Policy
		}
		#Add the role to the new Policy
		$r = $Policy.Roles |
	        Where-Object { $_.Name -eq $RoleName } |
	        Select-Object -First 1
	    	if (-not $r) 
		{
	        	$r = New-Object ($roleType)
	        	$r.Name = $RoleName
	        	$Policy.Roles += $r
    		}
		#Set folder policies
		$rsProxy.SetPolicies($Item.Path, $Policies);
	}
}
 
