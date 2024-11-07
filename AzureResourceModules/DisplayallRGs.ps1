Connect-AzAccount

$AllResourceGroups = Get-AzResourceGroup
foreach ($RGGroups in $AllResourceGroups) {
    $ResourceGroupName = $RGGroups.ResourceGroupName 
    # Write-Host "List of resource groups" $ResourceGroupName
    Write-Host "Resource Group: $ResourceGroupName"
}