Write-Output "Checking if ExchangeOnline module is installed prior to running the script."
$ExchangeModuleCheck = Get-Module -Name ExchangeOnlineManagement -ListAvailable

if ($null -ne $ExchangeModuleCheck) {
    Write-Host "Exchange module is installed on your PC."
}
else {
    Write-Host "Exchange module not installed. Exiting..."
    Exit
}

# Variables
$ConfigFolderPath = Read-Host "Enter the folder path to save the complete configuration export"
if (-not (Test-Path $ConfigFolderPath)) {
    New-Item -ItemType Directory -Path $ConfigFolderPath -Force | Out-Null
}

$ReportFolderPath = Read-Host "Enter the path to the reports directory"
if (-not (Test-Path $ReportFolderPath)) {
    New-Item -ItemType Directory -Path $ReportFolderPath -Force | Out-Null
}

$Date = $(Get-Date -f yyyy-MMM-dd)

# Connect to Purview SCC
Write-Host "Connecting to Purview SCC via interactive logon. Ensure your PIM with the correct permissions is activated." -ForegroundColor Red
Write-Host "Type 'OK' to proceed or press Enter to cancel."
$confirmation = Read-Host

if ($confirmation -ne "OK") {
    Write-Host "Operation canceled by the user."
    Exit
}

try {
    Connect-IPPSSession 
    Write-Output "Connection to Purview SCC successful."
}
catch {
    Write-Error "Failed to connect to Purview SCC. Error details: $($_.Exception.Message)"
    Exit
}

# Export DLP Policy Rules
try {
    Write-Output "Getting DLP Policy Rules..."
    $skydlprulesexport = Get-DlpComplianceRule
    $skydlppolicies = Get-DlpCompliancePolicy
    $skylabelpolicies = Get-LabelPolicy
    $skylabels = Get-Label
}
catch {
    Write-Error "Failed to get DLP Policy Rules. Error details: $($_.Exception.Message)"
    Exit
}

$SaveDLPRuleFilePath = "$ConfigFolderPath\SkyDlpRuleExport_$Date.json"
$SaveDLPRuleReportFilePath = "$ReportFolderPath\SkyDLPRules.json"
$SaveDLPPolicyFilePath = "$ConfigFolderPath\SkyDlpPolicyExport_$Date.json"
$SaveDLPPolicyReportFilePath = "$ReportFolderPath\SkyDlpPolicy.json"
$SaveLabelPolicyFilePath = "$ConfigFolderPath\SkyLabelPolicy_$Date.json"
$SaveLabelPolicyReportFilePath = "$ReportFolderPath\SkyLabelPolicy.json"
$SaveLabelsFilePath = "$ConfigFolderPath\SkyLabels_$Date.json"
$SaveLabelsReportFilePath = "$ReportFolderPath\SkyLabels.json"

# Export JSON files
$skydlprulesexport | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveDLPRuleFilePath
$skydlprulesexport | Select-Object DisplayName, ParentPolicyName, ReportSeverityLevel, BlockAccess, GenerateAlert, Disabled, Mode | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveDLPRuleReportFilePath
$skydlppolicies | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveDLPPolicyFilePath
$skydlppolicies | Select-Object Name, Mode, IsSimulationPolicy | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveDLPPolicyReportFilePath
$skylabelpolicies | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveLabelPolicyFilePath
$skylabelpolicies | Select-Object Name, Labels, Settings, Workload, Priority, Enabled | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveLabelPolicyReportFilePath
$skylabels | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveLabelsFilePath
$skylabels | Select-Object Name, ContentType, Priority, DisplayName | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveLabelsReportFilePath


Write-Output "DLP Rule Export Completed. Files saved to:"
Write-Output $SaveDLPRuleFilePath
Write-Output $SaveDLPRuleReportFilePath
Write-Output $SaveDLPPolicyFilePath
Write-Output $SaveDLPPolicyReportFilePath
Write-Output $SaveLabelPolicyFilePath 
Write-Output $SaveLabelPolicyReportFilePath
Write-Output $SaveLabelsFilePath
Write-Output $SaveLabelsReportFilePath

<# Part 2 - Script will now produce a delta file and compare the changes from previous configuration File
Write-Host "Do you want to compare the latest config to previous one? Type 'OK' to proceed or press Enter to cancel."
$confirmationForCompare = Read-Host

if ($confirmationForCompare -ne "OK") {
    Write-Host "Operation canceled by the user."
    Exit
}

Write-Host "Enter the previous config file path to compare:"
$maxAttempts = 2
$attempt = 0

while ($attempt -lt $maxAttempts) {
    $PreviousConfigPath = Read-Host "Enter the full path of the previous config file"
    
    if (Test-Path $PreviousConfigPath) {
        Write-Host "File found: $PreviousConfigPath"
        break
    }
    else {
        Write-Error "File does not exist. Attempt $($attempt + 1) of $maxAttempts."
        $attempt++
    }
}

if ($attempt -eq $maxAttempts -and -not (Test-Path $PreviousConfigPath)) {
    Write-Error "Maximum attempts reached. Exiting script."
    Exit
}

# Load Previous and current configuration JSON files
$PreviousDLPConfig = Get-Content -Path "$PreviousConfigPath" | ConvertFrom-Json
$CurrentDLPConfig = Get-Content -Path "$SaveConfigFilePath" | ConvertFrom-Json
# Compare previous config with existing config variable
$ConfigDifferences = Compare-Object -ReferenceObject $PreviousDLPConfig -DifferenceObject $CurrentDLPConfig

# Write difference to report Directory

$ConfigDifferenceFilePath = "$ReportFolderPath\DlpConfigChanges.json"
$ConfigDifferences | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $ConfigDifferenceFilePath 

Write-Host "Config Difference saved to $ConfigDifferenceFilePath" 
#>