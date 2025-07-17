# Install the PnP PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell" -Force -SkipPublisherCheck

# Prompt user for SharePoint source site and OneDrive destination site
$sourceSiteUrl = Read-Host "Enter the SharePoint source site URL (e.g., https://yourcompany.sharepoint.com/sites/yoursite)"
$destinationSiteUrl = Read-Host "Enter the OneDrive destination site URL (e.g., https://yourcompany-my.sharepoint.com/personal/yourname_domain_com)"

# Connect to the source SharePoint site
Write-Host "Connecting to SharePoint source site..."
Connect-PnPOnline -Url $sourceSiteUrl -Interactive
$sourceConnection = Get-PnPConnection

# Connect to the destination OneDrive site
Write-Host "Connecting to OneDrive destination site..."
Connect-PnPOnline -Url $destinationSiteUrl -Tenant "dergin.onmicrosoft.com" -Interactive
$destinationConnection = Get-PnPConnection

# Prompt for library names (defaults provided)
$sourceLibrary = Read-Host "Enter the source library/folder path (e.g., 'Documents')"
if ([string]::IsNullOrEmpty($sourceLibrary)) { $sourceLibrary = "Documents" }

$destinationLibrary = Read-Host "Enter the destination library/folder path (e.g., 'Documents')"
if ([string]::IsNullOrEmpty($destinationLibrary)) { $destinationLibrary = "Documents" }

# Get list of folders in the source library
Set-PnPConnection -Connection $sourceConnection
$folders = Get-PnPFolderItem -FolderSiteRelativeUrl $sourceLibrary -ItemType Folder

foreach ($folder in $folders) {
    $folderUrl = $folder.ServerRelativeUrl
    $folderName = $folder.Name

    # Create folder in destination
    Set-PnPConnection -Connection $destinationConnection
    Write-Host "Creating folder '$folderName' in OneDrive..."
    New-PnPFolder -Name $folderName -FolderSiteRelativeUrl $destinationLibrary -ErrorAction SilentlyContinue

    # Get files from source folder
    Set-PnPConnection -Connection $sourceConnection
    $files = Get-PnPFolderItem -FolderSiteRelativeUrl $folderUrl -ItemType File

    foreach ($file in $files) {
        $targetPath = "$destinationLibrary/$folderName/$($file.Name)"
        Write-Host "Copying '$($file.Name)' to '$targetPath'..."
        
        Set-PnPConnection -Connection $destinationConnection
        Copy-PnPFile -SourceUrl $file.ServerRelativeUrl -TargetUrl $targetPath -OverwriteIfAlreadyExists
    }
}

Write-Host "✅ Copy completed successfully!"
