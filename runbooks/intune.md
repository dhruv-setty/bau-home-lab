# Intune device management

## Enrolment
1. Confirm the user is licensed and in the enrolment group.
2. Enrol the device and check it appears in the Intune portal.
3. Check compliance status. A non-compliant device shows the failing setting.

## Common fixes
- Device not syncing: trigger a sync from the portal and from the Company Portal app.
- App not installing: check the assignment group and the install status for that device.
- Non-compliant device: fix the failing setting (for example encryption or OS version), then sync again.

## Retire and wipe
- Retire removes company data and keeps personal data. Wipe resets the device.
- Confirm which one is approved in the ticket before running it.
