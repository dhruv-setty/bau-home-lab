# Intune lab: enrolment, compliance and configuration

No Microsoft 365 tenant was available, so this lab builds the Intune pieces that do not need one and records how each would be applied in a tenant.

## 1. Enrolment (Windows Autopilot)

Collect the device hardware hash. This runs without a tenant and produces the CSV an admin uploads in Intune under Devices, Enrollment, Windows Autopilot devices.

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
Install-Script -Name Get-WindowsAutopilotInfo -Force
Get-WindowsAutopilotInfo -OutputFile .\evidence\autopilot-hash.csv
```

In a tenant: upload the CSV, assign a deployment profile to an Autopilot device group, then reset the device and sign in as the user. The device then shows as Entra joined and enrolled in Intune.

Redact the serial number and hash before committing the CSV or a screenshot of it.

## 2. Compliance policy

`policies/compliance-windows.json` is the baseline in Microsoft Graph format (`windows10CompliancePolicy`): password, minimum OS build, BitLocker, Secure Boot, TPM, firewall, Defender and code integrity. A non-compliant device is blocked after a 24 hour grace period.

`scripts/Test-LabCompliance.ps1` checks the same settings on a real Windows machine and reports Compliant or Not compliant for each one, the way the Intune device compliance view does. Run it elevated and keep the CSV as evidence.

## 3. Configuration profile

`policies/config-windows-device-restrictions.json` (`windows10GeneralConfiguration`): password rules, screen timeout after 15 minutes, Defender real-time and cloud protection, and SmartScreen app install control.

## Applying in a tenant

POST each JSON file with Microsoft Graph, then assign it to a device group:

- `POST https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicies`
- `POST https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations`

## Troubleshooting notes

| Symptom | Check | Fix |
|---|---|---|
| Not compliant: BitLocker | `Get-BitLockerVolume` | Turn on BitLocker, then sync |
| Not compliant: Secure Boot | `Confirm-SecureBootUEFI` | Enable Secure Boot in UEFI firmware |
| Not compliant: OS build | `winver` | Install pending Windows updates |
| Policy not applied | Settings, Accounts, Access work or school, Sync | Confirm the device is in the assigned group |
