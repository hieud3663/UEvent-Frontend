# Architecture Decisions (UEvent)

## Local Data Source Decision Guide
Evaluate per feature before creating a local data source.

Required (must implement):
- Auth token and session -> FlutterSecureStorage.
- Passkey credentials -> FlutterSecureStorage.
- QR ticket data -> Hive (offline access at event gate).
- Basic user profile cache -> Hive.

Recommended (improves UX):
- Registered events list -> Hive (fast load on app open).

Not needed (real-time data where stale cache can cause harm):
- Event listing and discovery.
- Check-in and QR scan result.
- Q&A and Feedback.
- Admin operations.

Decision note:
- If a feature is in the not-needed group, do not create LocalDataSource unless product requirements change.
