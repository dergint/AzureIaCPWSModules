# Ensure Microsoft Graph module is installed
if (!(Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Force
}

# Connect to Microsoft Graph (if not already connected)
if (!(Get-MgContext)) {
    Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All"
}

# Get the cutoff date (30 days ago)
$CutoffDate = (Get-Date).AddDays(-90)

# Get all users with last sign-in details
$Users = Get-MgUser -All -Property DisplayName, UserPrincipalName, SignInActivity

# Fetch the user details including 'UserType' separately
$UserDetails = Get-MgUser -All -Property DisplayName, UserPrincipalName, UserType | 
Select-Object DisplayName, UserPrincipalName, UserType

# Join both datasets based on UserPrincipalName
$UserDict = @{}
$UserDetails | ForEach-Object { $UserDict[$_.UserPrincipalName] = $_.UserType }

# Filter users who have not signed in within the last 30 days
$InactiveUsers = $Users | Where-Object {
    ($_.SignInActivity.LastSignInDateTime -eq $null) -or ($_.SignInActivity.LastSignInDateTime -lt $CutoffDate)
} | ForEach-Object {
    [PSCustomObject]@{
        DisplayName        = $_.DisplayName
        UserPrincipalName  = $_.UserPrincipalName
        UserType           = $UserDict[$_.UserPrincipalName]  # Retrieve UserType
        LastSignInDateTime = $_.SignInActivity.LastSignInDateTime
    }
}

# Display results in console
$InactiveUsers | Format-Table -AutoSize

# Export filtered results to CSV
$InactiveUsers | Export-Csv -Path "InactiveUsers_Last30Days.csv" -NoTypeInformation

Write-Host "Report saved as InactiveUsers_Last30Days.csv"
