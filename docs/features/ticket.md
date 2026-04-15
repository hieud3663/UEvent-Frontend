# Ticket Feature Decisions (UEvent)

## Ticket Cache Rule
After a successful registration, the repository must:
1. Receive `TicketModel` from remote.
2. Persist to local data source immediately (write-on-success).
3. On subsequent reads, use local-first and refresh from remote only on explicit pull.

Reason:
- User must be able to show QR at event gate without network.

## Write Operation Pattern (Ticket)
Pattern:
`Controller (optimistic UI update)`
`-> Repository.register()`
`-> RemoteDataSource.postRegistration()`
`-> LocalDataSource.saveTicket()`
`-> Controller (confirm or rollback state)`
