#Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.ReadWrite.ApplicationConfiguration" -TenantId organizations

# check if the Home Realmm Policy Exist
$checkHomeRealmPolicyExist = Get-MgPolicyHomeRealmDiscoveryPolicy

if ($null -eq $checkHomeRealmPolicyExist) {   
    write-Host "Home Realm Policy Does not Exist"
}
    else 
  {Write-Host "Home Realm Policy Exist, Skipping Creation" -ForegroundColor Green}

