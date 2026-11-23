# Active Directory

## Account tasks
- Unlock an account: check the lockout source before unlocking, so a stale password on another device does not lock it again.
- Reset a password: verify identity, reset, require change at next logon.
- Disable a leaver: disable the account, move it to the leavers OU, remove group memberships, note the date in the description.

## Groups
- Grant access by adding the user to a role group, not by assigning rights to the user directly.
- Check nested membership when a user has access nobody can explain.

## Group Policy
- Use `gpresult /r` on the client to see which policies applied.
- Use `gpupdate /force` after a change, then confirm with `gpresult` again.

Local lab: see [projects/identity-lifecycle](../projects/identity-lifecycle/README.md) for the scripted joiner, mover and leaver cycle.
