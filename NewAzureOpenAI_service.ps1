$newOpenAIServiceName= Read-Host "Enter the name of the new OpenAI service"
$resourceGroupName= Read-Host "Enter the name of the resource group"
$locationName= Read-Host "Enter the location of the resource group"

#prompt user if user group does not exist
$resourceGroupCheck = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

if ($resourceGroupCheck -eq $null) {
    $confirmation = Read-Host "Resource group does not exist. Do you want to create it? (Y/N)"
    switch ($confirmation) {
        "Y" { 
            # Create the resource group
            New-AzResourceGroup -Name $resourceGroupName -Location $locationName
        }
        "N" { # Exit the script
            return
        }
        default { # Continue with script
            Write-Host "Continuing with script"
        }
    }
}

New-AzCognitiveServicesAccount -ResourceGroupName $resourceGroupName -Name $newOpenAIServiceName -Type OpenAI -SkuName S0 -Location $locationName

$newOpenAIServiceName = Get-AzCognitiveServicesAccount -ResourceGroupName $resourceGroupName -Name $newOpenAIServiceName 

Write-Host $newOpenAIServiceName.Endpoint


