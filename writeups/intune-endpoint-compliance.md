# Endpoint Enrolment, Compliance and Configuration with Microsoft Intune

## Motivation

Conditional access decisions depend on device compliance, so the compliance baseline determines which devices reach company data. This project defines a Windows baseline as Microsoft Graph policy objects and evaluates a device against it locally, reproducing the Intune compliance view without a tenant.

## Objectives

1. Prepare Windows Autopilot enrolment by collecting the device hardware hash.
2. Define a compliance policy covering encryption, boot integrity, TPM, firewall, antivirus and OS build.
3. Define a configuration profile enforcing password, screen lock and Defender settings.
4. Evaluate a device per setting and remediate failures.

## Assumptions

- Target platform Windows 10 22H2 (build 19045) or later.
- Non-compliant devices are blocked after a 24 hour grace period.
- Results below are synthetic fixed data points for device `LAB-PC01`, not a capture from a live device.

## Method

| Artefact | Type | Contents |
|---|---|---|
| `compliance-windows.json` | `windows10CompliancePolicy` | Password, minimum OS build, BitLocker, Secure Boot, TPM, firewall, Defender, real-time protection, code integrity |
| `config-windows-device-restrictions.json` | `windows10GeneralConfiguration` | Password rules, 15 minute screen timeout, Defender real-time and cloud protection, SmartScreen app install control |
| `Test-LabCompliance.ps1` | Local evaluation | Reads each baseline setting from the device and reports Compliant or Not compliant |
| `Get-WindowsAutopilotInfo` | Enrolment | Exports the hardware hash CSV for Autopilot registration |

```
Hardware hash ──> Autopilot device group ──> deployment profile
                                                │
Device sign-in ──> Entra join + Intune enrolment ┘
      │
      └─> compliance evaluation ──> Compliant ──> conditional access allows
                                └─> Not compliant ──> grace period ──> block
```

## Results

| Setting | Run 1 | Remediation | Run 2 |
|---|---|---|---|
| Minimum OS build | Compliant (22631) | None | Compliant |
| BitLocker on system drive | Not compliant | BitLocker enabled, recovery key escrowed | Compliant |
| Secure Boot | Compliant | None | Compliant |
| TPM present and ready | Compliant | None | Compliant |
| Firewall, all profiles | Compliant | None | Compliant |
| Defender antivirus | Compliant | None | Compliant |
| Defender real-time protection | Compliant | None | Compliant |
| Code integrity (HVCI) | Not compliant | Memory integrity enabled, restart | Compliant |

Run 1: 6 of 8 compliant. Run 2: 8 of 8 compliant.

## Observations

- BitLocker and memory integrity are the settings most often off on unmanaged devices; both need a restart or encryption pass before the device reports compliant.
- Per setting evaluation identifies the exact remediation, which shortens the ticket compared with a single pass or fail result.
- Separating compliance (what is evaluated) from configuration (what is enforced) keeps a failed setting traceable to the profile that should have set it.

## Limitations

- Policy JSON is validated for syntax only and has not been imported into a tenant.
- Data points are synthetic. A live run replaces them with the CSV written by `Test-LabCompliance.ps1`.
