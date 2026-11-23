# Identity Lifecycle Administration on Active Directory with Microsoft 365 Mapping

## Motivation

Joiner, mover and leaver requests are the highest volume identity work on a service desk, and errors in them cause access creep or orphaned accounts. Without a Microsoft 365 tenant, the lifecycle is exercised on a Samba Active Directory domain controller in Docker, with each step mapped to its Microsoft 365 and Entra ID equivalent.

## Objectives

1. Provision two starters with department, title, mail address, group membership and shared mailbox access.
2. Move one user between departments, removing old access before granting new access.
3. Offboard one user so that no credential, group or interactive sign-in remains.
4. Reset a password with a forced change at next sign-in.
5. Record every change against a ticket reference.

## Assumptions

- Domain `LAB.LOCAL`, organisational units `OU=Staff` and `OU=Leavers`.
- Shared mailbox access is represented by mail-enabled security groups `SG-Mailbox-Sales` and `SG-Mailbox-Finance`.
- Results below are synthetic fixed data points showing expected output, not a capture from a live directory.

## Method

| Step | Ticket | Directory action | Microsoft 365 / Entra equivalent |
|---|---|---|---|
| Joiner | INC-1001 | `samba-tool user create` into `OU=Staff`, attributes set, forced password change; added to `SG-Sales`, `SG-Mailbox-Sales` | Create user, usage location NZ, assign licence, group membership, Full Access to shared mailbox |
| Mover | REQ-1002 | `department` and `title` replaced via LDIF; removed from Sales groups before Finance groups added | Profile update, group swap, mailbox permission swap with Send As |
| Leaver | REQ-1003 | Account disabled, password replaced with a random value, all groups except Domain Users removed, object moved to `OU=Leavers` | Block sign-in, revoke sessions, convert mailbox to shared, remove licence and groups |
| Reset | INC-1004 | Temporary password with `--must-change-at-next-login`, account enabled | Reset password, require change at next sign-in, verify MFA registration |

```
New starter ──> OU=Staff ──> SG-Sales + SG-Mailbox-Sales
      │
      ├─ mover ──> remove Sales access ──> add SG-Finance + SG-Mailbox-Finance
      │
      └─ leaver ─> disable ─> scramble password ─> strip groups ─> OU=Leavers
```

## Results

| Time | Ticket | Action | User | Outcome |
|---|---|---|---|---|
| 09:20 | INC-1001 | Joiner | alex.tane | Provisioned, Sales access |
| 09:21 | INC-1001 | Joiner | sam.ruka | Provisioned, Sales access |
| 10:30 | REQ-1002 | Mover | alex.tane | Finance access only |
| 13:10 | REQ-1003 | Leaver | sam.ruka | Disabled, no groups, in Leavers |
| 15:34 | INC-1004 | Reset | alex.tane | Change required at next sign-in |

Final state: `alex.tane` enabled in Finance groups only; `sam.ruka` disabled with Domain Users as the sole membership.

## Observations

- Removing old access before granting new access on a move prevents a window in which the user holds both departments' permissions.
- Scrambling a leaver's password in addition to disabling the account covers the case where the account is re-enabled in error.
- Moving leavers to a dedicated organisational unit gives a single scope for retention review and later deletion.

## Limitations

- Licensing, usage location, session revocation and mailbox conversion have no Samba equivalent and are documented, not executed.
- Data points are synthetic. A live run replaces them with the output of `jml.sh report`.
