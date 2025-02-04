# Ensure Microsoft Graph module is installed
if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Connect to Microsoft Graph (if not already connected)
if (!(Get-MgContext)) {
    Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All"
}

# Get current date
$CutoffDate = (Get-Date).AddDays(-90)

# Get all users with sign-in activity
$Users = Get-MgUser -All -Property DisplayName,UserPrincipalName,SignInActivity | Select-Object DisplayName,UserPrincipalName,SignInActivity

# Filter users who have not logged in within the last 30 days
$InactiveUsers = $Users | Where-Object {
    ($_.SignInActivity.LastSignInDateTime -eq $null) -or ($_.SignInActivity.LastSignInDateTime -lt $CutoffDate)
} | ForEach-Object {
    [PSCustomObject]@{
        DisplayName       = $_.DisplayName
        UserPrincipalName = $_.UserPrincipalName
        LastSignInDateTime = $_.SignInActivity.LastSignInDateTime
    }
}

# Display results
$InactiveUsers | Format-Table -AutoSize

# Export results to CSV
$InactiveUsers | Export-Csv -Path "InactiveUsers_Last30Days.csv" -NoTypeInformation

Write-Host "Report saved as InactiveUsers_Last30Days.csv"
