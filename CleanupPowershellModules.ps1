#Check what modules are installed 

$modulesToCheck = Read-Host "Enter the name of the module you want to check"

Get-Module -ListAvailable | Where-Object { $_.Name -like "$modulesToCheck*"} 

$versionToCheck = Read-Host "Enter the version of the module you want to check" 

$modulesToDelete = Get-Module -ListAvailable | Where-Object { $_.Name -like "$modulesToCheck*" -and $_.Version -eq "$versionToCheck"} 

# Display the modules to be deleted with version numbers in red
Write-Host "The following modules will be deleted:" -ForegroundColor Red
$modulesToDelete | Format-Table -AutoSize

# Confirm deletion of modules
$confirm = Read-Host "Confirm deleting the following modules? (Y/N)" 

if ($confirm -eq "Y") {
    Write-Host "Deleting the following modules:" -ForegroundColor Red
    $modulesToDelete | Format-Table -AutoSize 
    $modulesToDelete | ForEach-Object {Uninstall-Module -Name $_.Name -RequiredVersion "$versionToCheck" -Force}
    Write-Host "Modules deleted" -ForegroundColor Green
}
else {
    Write-Host "Modules not deleted" -ForegroundColor Green
}

#Confirm the status of the modules after deletion
$modulesAfterDeletion = Get-Module -ListAvailable | Where-Object { $_.Name -like "$modulesToCheck*"}
Write-Host "These are the modules remaining" $modulesAfterDeletion -ForegroundColor Green
$modulesAfterDeletion | Format-Table -AutoSize