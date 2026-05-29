# Offline First Sync Architecture

## Principle
Local database is the primary source of truth.

## Flow

```
User Action
↓
Save instantly to Isar
↓
Update UI immediately
↓
Add operation to SyncQueue
↓
Background sync attempts cloud upload
```

## Sync Rules

- Never block user actions due to internet
- Sync must retry automatically
- Failed syncs remain queued

## Conflict Strategy

Current:
- Last write wins

Future:
- Timestamp merge strategy

## Sync States

- Pending
- Syncing
- Synced
- Failed

## Required Components

- SyncManager
- ConnectivityService
- RetryHandler
