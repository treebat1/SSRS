$ReportServerUri = "http://<ServerName>/ReportServer/ReportService2010.asmx";
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;
 
#check out all members of $Proxy
#$Proxy | Get-Member
#http://msdn.microsoft.com/en-us/library/reportservice2010.reportingservice2010.listchildren.aspx
 
$items = $Proxy.ListChildren("/", $true);
 

foreach($item in $items){
    if($item.TypeName -eq "Folder")
    {    
        write-host $item.Name     
        
        $inherited = $true
        $itempolicies = $Proxy.GetPolicies($item.Path,[ref]$inherited)
        if (-not $inherited){
            $Proxy.InheritParentSecurity($item.Path)
        }
    }  
   
}