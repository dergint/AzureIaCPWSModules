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

# Prompt user for output path
$OutputPath = Read-Host "Enter the full path to save the CSV report (e.g. C:\Reports\InactiveUsers.csv)"
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = "InactiveUsers_Last90Days.csv"
    Write-Host "No path provided. Saving to current directory as '$OutputPath'."
}

# Create output directory if it doesn't exist
$OutputDir = Split-Path -Path $OutputPath -Parent
if ($OutputDir -and !(Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Export filtered results to CSV
$InactiveUsers | Export-Csv -Path $OutputPath -NoTypeInformation

Write-Host "Report saved as $OutputPath"
