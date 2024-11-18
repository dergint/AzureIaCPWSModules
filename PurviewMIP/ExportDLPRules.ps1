#Script will Connecto to Purview SCC and export Purview DLP Scripts

#Pre-requisites. Ensre ExchangeOnlineModule installed prior to running the sript.


Write-Output "Checking if ExchangeOnline module installed prior to running the script"
$ExchangeModuleCheck = Get-InstalledModule ExchangeOnlineManagement -ErrorAction SilentlyContinue | Select-Object Name, Version, InstalledLocation

if ($ExchangeModuleCheck) {
    Write-Host "Exchange module is installed on your PC"
}
else {
    Write-Host "Module not installed"
    Exit
}

#Variables
$ConfigFolderPath = Read-Host "Enter the name of the folder path you want to save the complete configuration export"
$Date = $(Get-Date -f yyyy-MMM-dd)
$ReportFolderPath = Read-Host "Enter path to reports directory"


#Connect to Purview SCC to as interactive logon

# Prompt for confirmation
Write-Host "Connecting to Purview SCC via interactive logon. Make sure your PIM with correct permissions is activated." "Type 'OK' to continue or Enter to cancel and proceed with connecting to Purview SCC"  -ForegroundColor Red
$confirmation = Read-Host 

# Check if the user typed "OK" (case-insensitive)
if ($confirmation -eq "OK") {
    try {
        Connect-IPPSSession
    }
    catch {
        Write-Error "Failed to connect to Purview SCC: $_"
        exit
    }
}
else {
    Write-Host "Operation canceled by the user."
    exit
}

try {
    Write-Output "Getting DLP Policy Rules"
    #option1- $skydlprulesexport = Get-DlpComplianceRule | Select-Object DisplayName, ParentPolicyName, ReportSeverityLevel, BlockAccess, GenerateAlert, Disabled, Mode
    $skydlprulesexport = Get-DlpComplianceRule 
}
catch {
    Write-Error "Failed to get DLP Policy Rules: $_"
    exit
}
$SaveConfigFilePath = "$ConfigFolderPath\SkyDlpRuleExport_$Date.json"
$SaveReportFilePath = "$ReportFolderPath\SkyDLPRules.json"
$skydlprulesexport | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveConfigFilePath
$skydlprulesexport | Select-Object DisplayName, ParentPolicyName, ReportSeverityLevel, BlockAccess, GenerateAlert, Disabled, Mode | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $SaveReportFilePath
Write-Output "DLP Rule Export Completed"











