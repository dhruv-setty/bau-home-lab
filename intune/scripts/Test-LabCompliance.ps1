<#
  Local compliance check that mirrors the LAB Windows compliance baseline.
  Run in an elevated PowerShell window: .\Test-LabCompliance.ps1
  Writes results to ..\evidence\compliance-<computer>-<date>.csv
#>
$ErrorActionPreference = 'SilentlyContinue'
$results = @()
function Add-Check($Setting, $Expected, $Actual, $Pass) {
  $script:results += [pscustomobject]@{ Setting = $Setting; Expected = $Expected; Actual = "$Actual"; Status = $(if ($Pass) { 'Compliant' } else { 'Not compliant' }) }
}

$os = [Environment]::OSVersion.Version
$build = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
Add-Check 'Minimum OS build' '19045 or later' $build ([int]$build -ge 19045)

$bl = Get-BitLockerVolume -MountPoint $env:SystemDrive
Add-Check 'BitLocker on system drive' 'On' $bl.ProtectionStatus ($bl.ProtectionStatus -eq 'On')

$sb = Confirm-SecureBootUEFI
Add-Check 'Secure Boot' 'True' $sb ($sb -eq $true)

$tpm = Get-Tpm
Add-Check 'TPM present and ready' 'True' $tpm.TpmReady ($tpm.TpmPresent -and $tpm.TpmReady)

$fw = Get-NetFirewallProfile | Where-Object { -not $_.Enabled }
Add-Check 'Firewall on for all profiles' 'All enabled' $(if ($fw) { "Off: $($fw.Name -join ', ')" } else { 'All enabled' }) (-not $fw)

$mp = Get-MpComputerStatus
Add-Check 'Defender antivirus' 'Enabled' $mp.AntivirusEnabled ($mp.AntivirusEnabled -eq $true)
Add-Check 'Defender real-time protection' 'Enabled' $mp.RealTimeProtectionEnabled ($mp.RealTimeProtectionEnabled -eq $true)

$dg = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
Add-Check 'Code integrity (HVCI)' 'Running' ($dg.SecurityServicesRunning -contains 2) ($dg.SecurityServicesRunning -contains 2)

$results | Format-Table -AutoSize
$overall = if ($results.Status -contains 'Not compliant') { 'NOT COMPLIANT' } else { 'COMPLIANT' }
Write-Host "Overall: $overall"
$out = Join-Path $PSScriptRoot "..\evidence"
New-Item -ItemType Directory -Force -Path $out | Out-Null
$results | Export-Csv -NoTypeInformation -Path (Join-Path $out "compliance-$env:COMPUTERNAME-$(Get-Date -f yyyyMMdd).csv")
