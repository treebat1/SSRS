#https://serverfault.com/questions/153167/using-powershell-to-set-user-permissions-in-reporting-services

function Add-SSRSUserRole
(   
    [string]$reportServerUrl,[string]$userGroup,[string]$requiredRole,[string]$folder,[bool]$inheritFromParent
)
{
    #Ensure we stop on errors
    $ErrorActionPreference = "Stop";
    #Connect to the SSRS webservice 
    $ssrs = New-WebServiceProxy -Uri "$reportServerUrl" -UseDefaultCredential;
    $namespace = $ssrs.GetType().Namespace;
    $changesMade = $false;

    #Look for a matching policy     
    $policies = $ssrs.GetPolicies($folder, [ref]$inheritFromParent);
    if ($policies.GroupUserName -contains $userGroup)
    {
        Write-Host "User/Group already exists. Using existing policy.";
        $policy = $policies | where {$_.GroupUserName -eq $userGroup} | Select -First 1 ;
    }
    else
    {
        #A policy for the User/Group needs to be created
        Write-Host "User/Group was not found. Creating new policy.";
        $policy = New-Object -TypeName ($namespace + '.Policy');
        $policy.GroupUserName = $userGroup;
        $policy.Roles = @();
        $policies += $policy;
        $changesMade = $true;
    }

    #Now we have the policy, look for a matching role
    $roles = $policy.Roles;
    if (($roles.Name -contains $requiredRole) -eq $false)
    {
        #A role for the policy needs to added
        Write-Host "Policy doesn't contain specified role. Adding.";
        $role = New-Object -TypeName ($namespace + '.Role');
        $role.Name = $requiredRole;
        $policy.Roles += $role;
        $changesMade = $true;
    }
    else 
    {
        Write-Host "Policy already contains specified role. No changes required.";
    }

    #If changes were made...
    if ($changesMade)
    {
        #...save them to SSRS
        Write-Host "Saving changes to SSRS.";
        $ssrs.SetPolicies($folder, $policies);
    }
    Write-Host "Complete.";
}

[string]$url = "http://chdc/ReportServer_DEV/ReportService2010.asmx";
Add-SSRSUserRole $url "uboc-ad\rx95913" "AuditTest" "/Vertigo" $false;
