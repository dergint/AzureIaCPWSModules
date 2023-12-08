#Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.ReadWrite.ApplicationConfiguration" -TenantId organizations

# check if the Home Realmm Policy Exist
$checkHomeRealmPolicyExist = Get-MgPolicyHomeRealmDiscoveryPolicy

if ($checkHomeRealmPolicyExist -eq $null) {   
    $response = Read-Host "Home Realm Policy Does not Exist, do you want to create it? (y/n)"
    if ($response -eq "y") {
        # Create Home Realm Policy
        $AzureADPolicyDefinition = @(
            @{
               "HomeRealmDiscoveryPolicy" = @{
                  "AlternateIdLogin" = @{
                     "Enabled" = $true
                  }
               }
            } | ConvertTo-JSON -Compress
          )
          
          $AzureADPolicyParameters = @{
            Definition            = $AzureADPolicyDefinition
            DisplayName           = "BasicAutoAccelerationPolicy"
            AdditionalProperties  = @{ IsOrganizationDefault = $true }
          }
          
          New-MgPolicyHomeRealmDiscoveryPolicy @AzureADPolicyParameters
       
    }
    else {
        Exit
    }
}
    else 
  {Write-Host "Home Realm Policy Exist, Skipping Creation" -ForegroundColor Green}
