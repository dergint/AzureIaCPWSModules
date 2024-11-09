#check powershell version installed
$psversion = $PSVersionTable.PSVersion
Write-Host "The version of powershell installed is" $psversion -ForegroundColor Green
#ask if user wants to update powershell modules
$confirmUpdate = Read-Host "Do you want to update the powershell version? (Y/N)"
if ($confirmUpdate -eq "Y") {
    Write-Host "Updating powershell version" -ForegroundColor Green
    #update powershell version
    brew upgrade --cask powershell
    $psversion = $PSVersionTable.PSVersion
    Write-Host "The version of powershell installed is" $psversion -ForegroundColor Green
}
else {
    Write-Host "Powershell version not updated" -ForegroundColor Green
}

#update powershell modules
$modulesToUpdate = Read-Host "Enter the name of the module you want to update"
$modulesToUpdate | ForEach-Object {Update-Module -Name $_.Name -Force}
Write-Host "Modules updated" -ForegroundColor Green
$modulesAfterUpdate = Get-Module -ListAvailable | Where-Object { $_.Name -like "$modulesToUpdate*"}
Write-Host "These are the modules after update" $modulesAfterUpdate -ForegroundColor Green
$modulesAfterUpdate | Format-Table -AutoSize
#update powershell version
