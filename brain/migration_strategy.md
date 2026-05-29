# Database Migration Strategy

To ensure zero user data loss when schema updates occur in production, the application must adhere to this structured SQLite/Isar migration protocol.

## Version Control

1. **Current Schema Version**: `1`
2. **Schema Upgrade Protocol**:
   * Any database schema change must increment the database version in `_initDB()` (located in `DBHelper`).
   * A dedicated `migrationBlock` must handle table updates incrementally, rather than deleting/recreating tables.

## Offline Data Migration Checklist

- [ ] **Backup Prior State**: In future online sync phases, trigger an automatic cloud sync backup before starting the migration block.
- [ ] **Column Additions**: When adding new fields (e.g. `taxDeductible`), declare them as nullable or with a default value to prevent SQLite structural mismatch crashes.
- [ ] **Entity Mapping Updates**: Update both the DB entity mapper and domain models concurrently.
