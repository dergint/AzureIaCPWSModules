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
$Users = Get-MgUser -All -Property DisplayName,UserPrincipalName,SignInActivity | Select-Object DisplayName,UserPrincipalName,UserType,SignInActivity

# Filter users who have not signed in within the last 30 days
$InactiveUsers = $Users | Where-Object {
    ($_.LastSignInDateTime -eq $null) -or ($_.LastSignInDateTime -lt $CutoffDate)
} | ForEach-Object {
    [PSCustomObject]@{
        DisplayName        = $_.DisplayName
        UserPrincipalName  = $_.UserPrincipalName
        UserType           = $_.UserType  # Adding UserType (Member/Guest)
        LastSignInDateTime = $_.LastSignInDateTime
    }
}

# Display results in console
$InactiveUsers | Format-Table -AutoSize

# Export filtered results to CSV
$InactiveUsers | Export-Csv -Path "InactiveUsers_Last30Days.csv" -NoTypeInformation

Write-Host "Report saved as InactiveUsers_Last30Days.csv"
