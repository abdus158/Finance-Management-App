# Database Design

## Database
Isar Database

## Collections

### Transactions

Fields:
- id
- amount
- type
- category
- note
- walletId
- tag
- createdAt
- updatedAt
- syncStatus

Indexes:
- createdAt
- category
- walletId

---

### Wallets

Fields:
- id
- name
- type
- balance
- createdAt

---

### Loans

Fields:
- id
- personName
- type
- totalAmount
- remainingAmount
- dueDate
- status
- createdAt

---

### SyncQueue

Fields:
- id
- entityType
- entityId
- operationType
- payload
- status
- createdAt

Statuses:
- pending
- synced
- failed
