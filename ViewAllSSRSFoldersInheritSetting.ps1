#$ReportServerUri =  'http://chdc/ReportServer_PROD/ReportService2010.asmx';
$ReportServerUri =  'http://chdc/ReportServer_DEV/ReportService2010.asmx';
$Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2010 -UseDefaultCredential ;
 
#check out all members of $Proxy
#$Proxy | Get-Member
#http://msdn.microsoft.com/en-us/library/reportservice2010.reportingservice2010.listchildren.aspx
 
$items = $Proxy.ListChildren("/", $true);
 
write-host "Folder, Inherited"

foreach($item in $items){
    if($item.TypeName -eq "Folder")
    {            
        $inherited = $true
        $itempolicies = $Proxy.GetPolicies($item.Path,[ref]$inherited)
        write-host  $item.Name, $inherited -Separator ", "
    }  
   
}
