# Ticketing lab: incidents, requests, SLAs and escalation

A service desk process defined as files: categories, a priority matrix, SLA targets, escalation rules and a sample queue. `sla_report.py` measures each ticket against its SLA and flags breaches, the way an ITSM tool's SLA view does.

## Ticket types

| Type | Meaning | Example |
|---|---|---|
| Incident | Something that worked has stopped working | Outlook will not open, VPN drops |
| Service request | A standard ask with a known fulfilment path | New starter account, software install, access to a shared mailbox |

## Workflow

Incident: New, Assigned, In progress, Pending (user or vendor), Resolved, Closed.
Service request: New, Approval (if needed), Fulfilment, Resolved, Closed.

- Pending pauses the SLA clock. Resolved auto-closes after 3 business days if the user does not reopen it.
- Every ticket records what was tried, so an escalation never repeats steps.

## Categories

| Category | Subcategories |
|---|---|
| Account and access | Password reset, MFA, joiner, mover, leaver, group or mailbox access |
| Email and collaboration | Outlook, shared mailbox, Teams, OneDrive, SharePoint |
| Device | Laptop or desktop, enrolment and compliance, printer, peripherals |
| Network | VPN, Wi-Fi, internet, DNS |
| Software | Install, licence, application error |
| Security | Phishing report, suspected compromise, lost or stolen device |

## Priority matrix (impact by urgency)

| Impact \ Urgency | High | Medium | Low |
|---|---|---|---|
| High (many users or a whole site) | P1 | P2 | P3 |
| Medium (a team or a VIP) | P2 | P3 | P4 |
| Low (one user, workaround exists) | P3 | P4 | P4 |

## SLA targets

| Priority | First response | Resolution | Clock |
|---|---|---|---|
| P1 Critical | 15 minutes | 4 hours | 24x7 |
| P2 High | 30 minutes | 8 business hours | Business hours |
| P3 Medium | 4 business hours | 3 business days | Business hours |
| P4 Low | 1 business day | 5 business days | Business hours |

Business hours: Monday to Friday, 8:00 to 17:00 NZ time. A business day is 9 business hours.

## Escalation

Functional escalation (to a skill group):

| From | To | When |
|---|---|---|
| L1 service desk | L2 desktop or identity | Fix needs admin rights, or L1 steps exhausted after 30 minutes |
| L2 | L3 or vendor | Root cause is in infrastructure, an application or a vendor product |
| Any | Security team | Suspected compromise or phishing with credentials entered: immediately |

Hierarchical escalation (to management):

| Trigger | Notify |
|---|---|
| 75% of the resolution SLA used | Team lead |
| SLA breached | Service desk manager |
| Any P1 | Service desk manager at logging, then hourly updates |

## Sample queue and SLA report

`tickets.csv` holds a sample queue, including the joiner, mover, leaver and password reset tickets from the identity lab (INC-1001, REQ-1002, REQ-1003, INC-1004).

```bash
python3 sla_report.py tickets.csv "2026-11-24 12:00"
```

The report shows response and resolution time used against target, and marks each ticket Met, At risk (75% or more used, still open) or Breached.
