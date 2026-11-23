# BAU home lab

Service desk and endpoint administration built as reproducible lab projects: identity lifecycle, device compliance and ticketing, each with a runbook, scripts, evidence and a write-up.

[![checks](https://github.com/dhruv-setty/bau-home-lab/actions/workflows/checks.yml/badge.svg)](https://github.com/dhruv-setty/bau-home-lab/actions/workflows/checks.yml)

## Projects

| Project | What it covers | Outcome | Write-up |
|---|---|---|---|
| [Identity lifecycle](projects/identity-lifecycle/README.md) | Joiner, mover, leaver and password reset on Samba AD in Docker, mapped to Microsoft 365 and Entra ID | Two starters provisioned, one move, one leaver fully offboarded, every change logged to a ticket | [Read](writeups/identity-lifecycle.md) |
| [Intune endpoint compliance](projects/intune/README.md) | Autopilot hash collection, Windows compliance policy and device restrictions profile in Microsoft Graph format, local compliance check | Device remediated from 6 of 8 to 8 of 8 compliant | [Read](writeups/intune-endpoint-compliance.md) |
| [Service desk ticketing](projects/ticketing/README.md) | Incident and request workflows, categories, impact by urgency matrix, P1 to P4 SLAs, escalation, SLA report script | Eight ticket queue scored: six met, one at risk, one breached | [Read](writeups/service-desk-ticketing.md) |
| [CVE-2022-1388 review](cve/CVE-2022-1388-f5-big-ip.md) | F5 BIG-IP authentication bypass: CVSS 3.1 table analysis and remediation | Exposure, impact and fix documented | |

## Skills shown

| Area | Tools and practices |
|---|---|
| Identity and access | Active Directory users, groups and OUs, `samba-tool`, LDIF, least privilege on moves, leaver hardening |
| Microsoft 365 and Entra ID | User lifecycle, licensing, shared mailbox permissions, password reset and MFA checks (mapped) |
| Endpoint management | Intune compliance and configuration policies, Windows Autopilot, BitLocker, Secure Boot, TPM, Defender, HVCI |
| Service management | Incident and request workflows, priority matrix, SLA measurement, functional and hierarchical escalation |
| Automation | Bash, PowerShell, Python, Docker, GitHub Actions |

## Runbooks

Short operational checklists used alongside the projects.

| Area | Runbook |
|---|---|
| Microsoft 365 user administration | [runbooks/m365.md](runbooks/m365.md) |
| Active Directory | [runbooks/active-directory.md](runbooks/active-directory.md) |
| Intune device management | [runbooks/intune.md](runbooks/intune.md) |
| Ticketing workflow | [runbooks/ticketing.md](runbooks/ticketing.md) |
| User-facing troubleshooting | [runbooks/troubleshooting.md](runbooks/troubleshooting.md) |

## Layout

```
projects/
  identity-lifecycle/   jml.sh, lab guide and Microsoft 365 mapping
  intune/               policies/*.json, scripts/Test-LabCompliance.ps1
  ticketing/            tickets.csv, sla_report.py, process definition
runbooks/               operational checklists
writeups/               project write-ups
evidence/synthetic/     fixed data points used in the write-ups
cve/                    vulnerability review
```

## Scope

All work runs in a lab on local virtual machines and Docker containers, not in a production environment or a Microsoft 365 tenant. Write-up figures use the synthetic fixed data points in `evidence/synthetic/`; the ticketing SLA figures are real output of the script over a sample queue.

Changes are recorded in [CHANGELOG.md](CHANGELOG.md).
