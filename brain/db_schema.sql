-- SQLite Schema Definition for Financial Command Center (FCC)

-- 1. Wallets Container Table
CREATE TABLE wallets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL, -- Enum: 'CASH', 'BANK', 'DIGITAL', 'BUSINESS'
    balance REAL NOT NULL DEFAULT 0.0,
    currency TEXT NOT NULL DEFAULT 'PKR'
);

-- 2. Categories Classification Table
CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    type TEXT NOT NULL, -- Enum: 'INCOME', 'EXPENSE'
    context TEXT NOT NULL -- Enum: 'PERSONAL', 'BUSINESS', 'BOTH'
);

-- 3. Smart Ledger Transactions Table
CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    walletId TEXT NOT NULL,
    type TEXT NOT NULL, -- Enum: 'INCOME', 'EXPENSE', 'TRANSFER'
    amount REAL NOT NULL,
    categoryId TEXT NOT NULL,
    tags TEXT NOT NULL, -- Comma-separated tags (e.g., "Nexus, Subscription")
    priority TEXT NOT NULL DEFAULT 'LOW', -- Enum: 'LOW', 'MEDIUM', 'HIGH'
    date INTEGER NOT NULL, -- Unix timestamp (milliseconds since epoch)
    notes TEXT NOT NULL,
    linkedTransactionId TEXT, -- Linked transaction ID for internal transfers (self-reference)
    FOREIGN KEY (walletId) REFERENCES wallets (id) ON DELETE CASCADE,
    FOREIGN KEY (categoryId) REFERENCES categories (id)
);

-- 4. Loan & Liability Table
CREATE TABLE loans (
    id TEXT PRIMARY KEY,
    personName TEXT NOT NULL,
    type TEXT NOT NULL, -- Enum: 'PAYABLE' (I owe them), 'RECEIVABLE' (They owe me)
    principalAmount REAL NOT NULL,
    remainingAmount REAL NOT NULL,
    dueDate INTEGER NOT NULL, -- Unix timestamp (milliseconds since epoch)
    status TEXT NOT NULL DEFAULT 'ACTIVE' -- Enum: 'ACTIVE', 'PAID', 'DEFAULTED'
);

-- 5. Loan Installment Tracker Table
CREATE TABLE loan_installments (
    id TEXT PRIMARY KEY,
    loanId TEXT NOT NULL,
    transactionId TEXT NOT NULL,
    amount REAL NOT NULL,
    date INTEGER NOT NULL, -- Unix timestamp (milliseconds since epoch)
    FOREIGN KEY (loanId) REFERENCES loans (id) ON DELETE CASCADE,
    FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
);

-- Indices for performance optimization
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_wallet ON transactions(walletId);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_installments_loan ON loan_installments(loanId);
