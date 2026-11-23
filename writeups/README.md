# Write-ups

Data points in these write-ups are synthetic fixed values (see `evidence/synthetic/`).

| Write-up | Summary |
|---|---|
| [Identity Lifecycle Administration on Active Directory with Microsoft 365 Mapping](identity-lifecycle.md) | Joiner, mover and leaver cycle on Samba AD in Docker, each step mapped to its Microsoft 365 and Entra action: access removed before granted on moves, leavers disabled, scrambled, stripped and isolated. |
| [Endpoint Enrolment, Compliance and Configuration with Microsoft Intune](intune-endpoint-compliance.md) | Windows baseline as Graph compliance and configuration policies, Autopilot hash collection and a per setting local evaluation. BitLocker and HVCI failures remediated from 6 of 8 to 8 of 8 compliant. |
| [Service Desk Ticketing: Workflow, SLA Measurement and Escalation](service-desk-ticketing.md) | Incident and request workflows, impact by urgency priority, P1 to P4 SLAs on NZ business hours and tiered escalation, with a script that scores a queue as Met, At risk or Breached. |
