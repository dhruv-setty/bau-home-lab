# Joiner, mover, leaver lab (Samba AD in Docker)

No Microsoft 365 tenant was available, so this lab runs the same user lifecycle on a local Samba Active Directory domain controller in Docker. Each step is mapped to the matching Microsoft 365 or Entra ID admin task.

## Run

```bash
cd projects/identity-lifecycle
./jml.sh up       # start the domain controller, create OUs and groups
./jml.sh joiner   # INC-1001: two new starters
./jml.sh mover    # REQ-1002: Sales to Finance
./jml.sh leaver   # REQ-1003: offboard one user
./jml.sh reset    # INC-1004: password reset
./jml.sh report   # final state and ticket log
./jml.sh down
```

Every step writes a line to `projects/identity-lifecycle/evidence/jml-log.csv`.

## Mapping to Microsoft 365

| Lab step | Samba AD action | Microsoft 365 / Entra equivalent |
|---|---|---|
| Joiner | Create user in OU=Staff, set department and title, force password change | Add user in the admin center, set usage location, assign licence |
| Joiner | Add to SG-Sales and SG-Mailbox-Sales | Add to security group, grant Full Access to the sales shared mailbox |
| Mover | Change department and title, swap groups | Update profile, swap groups, move shared mailbox permissions |
| Leaver | Disable account, scramble password, strip groups, move to OU=Leavers | Block sign-in, revoke sessions, convert mailbox to shared, remove licence and groups |
| Reset | Temporary password, change at next sign-in | Reset password, require change at next sign-in, check MFA |

## Evidence

Redact before committing screenshots: domain names, tenant IDs, UPNs and serials.
