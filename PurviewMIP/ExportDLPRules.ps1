#Script will Connecto to Purview SCC and export Purview DLP Scripts

#Variables
$FilePath = Read-Host "Enter the name of the folder path you want to save the report"
$Date = $(Get-Date -f yyyy-MMM-dd)

#Connect to Purview SCC to as interactive logon

try {
    Write-Output "Connecting to Purview SCC via interactive logon. Make sure your PIM with correct permissions activated."
    Connect-IPPSsession
}
catch {
    Write-Error "Failed to connect to Purviewno : $_"
    exit
}


try {
    Write-Output "Getting DLP Policy Rules"
    $skydlprulesexport = Get-DlpComplianceRule | Select-Object DisplayName, ReportSeverityLevel, BlockAccess, GenerateAlert, Disabled, Mode
}
catch {
    Write-Error "Failed to get DLP Policy Rules: $_"
    exit
}


Write-Output $skydlprulesexport 