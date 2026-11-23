# Service Desk Ticketing: Workflow, SLA Measurement and Escalation

## Motivation

Consistent categorisation and priority are what make SLA reporting meaningful. This project defines an incident and request process as files and measures a ticket queue against it, reproducing the SLA view of an ITSM platform.

## Objectives

1. Separate incidents from service requests, each with its own workflow states.
2. Derive priority from impact and urgency rather than user assertion.
3. Set response and resolution targets per priority, on business hours where appropriate.
4. Define functional and hierarchical escalation.
5. Report each ticket as Met, At risk or Breached.

## Assumptions

- Business hours Monday to Friday 08:00 to 17:00 NZ time; a business day is 9 hours.
- Pending time pauses the resolution clock.
- The queue is a synthetic sample of eight tickets, including the four identity lifecycle tickets; the report is real output of `sla_report.py` over that sample, evaluated at 2026-11-24 12:00.

## Method

| Impact \ Urgency | High | Medium | Low |
|---|---|---|---|
| High | P1 | P2 | P3 |
| Medium | P2 | P3 | P4 |
| Low | P3 | P4 | P4 |

| Priority | First response | Resolution | Clock |
|---|---|---|---|
| P1 | 15 minutes | 4 hours | 24x7 |
| P2 | 30 minutes | 8 business hours | Business hours |
| P3 | 4 business hours | 3 business days | Business hours |
| P4 | 1 business day | 5 business days | Business hours |

Escalation: L1 to L2 when admin rights are needed or after 30 minutes without progress; L2 to L3 or vendor for infrastructure or product faults; any tier to Security immediately on suspected compromise. Team lead notified at 75% of resolution target, manager on breach and at logging of any P1.

## Results

| Ticket | Priority | Response used | Resolution used | Status |
|---|---|---|---|---|
| INC-1001 | P4 | 15m of 9h | 2h 35m of 45h | Met |
| REQ-1002 | P4 | 30m of 9h | 8h 15m of 45h | Met |
| REQ-1003 | P2 | 10m of 30m | 1h 05m of 8h | Met |
| INC-1004 | P3 | 4m of 4h | 15m of 27h | Met |
| INC-1005 | P1 | 10m of 15m | 3h 45m of 4h | Met |
| INC-1006 | P3 | 30m of 4h | 27h 30m of 27h | Breached |
| INC-1007 | P3 | 1h 15m of 4h | 25h of 27h | At risk |
| INC-1008 | P2 | 5m of 30m | 1h 30m of 8h | Met |

Six met, one at risk, one breached.

## Observations

- INC-1006 breached by 30 minutes after a weekend boundary; the 75% notification would have reached the team lead with roughly 7 business hours remaining.
- INC-1005 met its P1 target with 15 minutes to spare, which is the margin a major incident process is designed to protect.
- INC-1007 links to the endpoint compliance project: a BitLocker failure that needs a user restart is a common cause of an at risk P3.

## Limitations

- Ticket data is synthetic; the SLA calculation is not.
- Public holidays are not excluded from business hours.
