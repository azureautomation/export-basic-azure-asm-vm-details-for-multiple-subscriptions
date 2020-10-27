Add-AzureAccount
$Subs = @()
$Subs = Get-AzureSubscription | Select-Object SubscriptionId, SubscriptionName, TenantID | Out-GridView -Title "Select Subscriptions (use Ctrl/Shift for multiples)" -PassThru
$ASMVMList = @()
foreach ($Sub in $Subs) {
    Select-AzureSubscription -SubscriptionId $sub.SubscriptionId

    $ASMVMs = Get-AzureVM
    $ASMServs = Get-AzureService
    foreach ($ASMVM in $ASMVMs) {
        $Loc = ($ASMServs | Where-Object {$_.ServiceName -eq $ASMVMs.ServiceName}).Location
        $VMdet = new-object psobject -Property @{
            SubscriptionGuid = $($sub.SubscriptionId)
            SubscriptionName = $($sub.SubscriptionName)
            Name = $ASMVM.Name
            ServiceName = $ASMVM.ServiceName
            PowerState = $ASMVM.PowerState
            AvailabilitySetName = $ASMVM.AvailabilitySetName
            InstanceSize = $ASMVM.InstanceSize
            Location = $Loc
        }
        $ASMVMList += $VMDet
    }
}
$ASMVMList | Select-Object SubscriptionGuid, SubscriptionName, Name, ServiceName, PowerState, Location, InstanceSize, AvailabilitySetName | Export-Csv -Path "$($Env:Temp)\ASMVMs.csv" -NoTypeInformation
Invoke-Item "$($Env:Temp)\ASMVMs.csv"
