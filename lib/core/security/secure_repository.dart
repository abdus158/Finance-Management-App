import '../database/db_helper.dart';
import '../../models/transaction.dart';
import '../../models/loan.dart';
import 'security_helper.dart';

class SecureRepository {
  final DBHelper _dbHelper = DBHelper.instance;

  // Master key derived from active user session (initialized on login)
  static String activeSessionKey = "default_secure_crypt_key_fcc_32"; // Fallback 32-char key

  // --- USER AUTHENTICATION & LOCK METHODS ---

  // Registers a new security PIN for local lock screen
  Future<void> registerUserPin(String pin) async {
    final db = await _dbHelper.database;
    final salt = DateTime.now().toIso8601String();
    final pinHash = SecurityHelper.hashPin(pin, salt);

    await db.transaction((txn) async {
      // Clear previous user configuration (local device single user)
      await txn.delete('users');
      await txn.insert('users', {
        'id': 'local_user',
        'pin_hash': pinHash,
        'salt': salt,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    });

    // Derive active session encryption key dynamically
    activeSessionKey = SecurityHelper.deriveKey(pin, salt);
  }

  // Validates entered PIN against local hashed value
  Future<bool> verifyUserPin(String pin) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: ['local_user'],
    );

    if (result.isEmpty) return false;

    final String storedHash = result.first['pin_hash'] as String;
    final String storedSalt = result.first['salt'] as String;

    final String enteredHash = SecurityHelper.hashPin(pin, storedSalt);
    if (storedHash == enteredHash) {
      // Successful authentication -> Derive active session decryption key
      activeSessionKey = SecurityHelper.deriveKey(pin, storedSalt);
      return true;
    }
    return false;
  }

  // --- TRANSACTION SECURE REPOSITORY (CLEAN DATA LAYER) ---

  // Fetches transactions and decrypts sensitive notes dynamically
  Future<List<TransactionModel>> getDecryptedTransactions() async {
    final rawTxs = await _dbHelper.getAllTransactions();

    return rawTxs.map((tx) {
      final decryptedNotes = SecurityHelper.decryptField(tx.notes, activeSessionKey);
      return TransactionModel(
        id: tx.id,
        walletId: tx.walletId,
        type: tx.type,
        amount: tx.amount,
        categoryId: tx.categoryId,
        tags: tx.tags,
        priority: tx.priority,
        date: tx.date,
        notes: decryptedNotes,
        linkedTransactionId: tx.linkedTransactionId,
      );
    }).toList();
  }

  // Sanitizes and encrypts transactions before database insertion
  Future<void> addSecureTransaction(TransactionModel tx) async {
    // 1. INPUT VALIDATION & SANITIZATION LAYER
    if (tx.amount <= 0) {
      throw ArgumentError("Transaction amount must be strictly greater than zero.");
    }
    
    // Sanitize string notes to block injection attempts and script insertions
    final sanitizedNotes = SecurityHelper.sanitizeString(tx.notes);
    final sanitizedTags = SecurityHelper.sanitizeString(tx.tags);

    // 2. ENCRYPTION LAYER (AES-256)
    final encryptedNotes = SecurityHelper.encryptField(sanitizedNotes, activeSessionKey);

    final secureTx = TransactionModel(
      id: tx.id,
      walletId: tx.walletId,
      type: tx.type,
      amount: tx.amount,
      categoryId: tx.categoryId,
      tags: sanitizedTags,
      priority: tx.priority,
      date: tx.date,
      notes: encryptedNotes,
      linkedTransactionId: tx.linkedTransactionId,
    );

    // 3. SECURE PERSISTENCE (Parameterized execution in helper)
    await _dbHelper.addTransaction(secureTx);
  }

  // Secure Internal Fund Transfer with Dual-Entry parameter checks
  Future<void> makeSecureTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError("Transfer amount must be strictly greater than zero.");
    }

    final sanitizedNotes = SecurityHelper.sanitizeString(notes);
    await _dbHelper.transferFunds(
      fromWalletId: fromWalletId,
      toWalletId: toWalletId,
      amount: amount,
      notes: sanitizedNotes,
    );
  }

  // --- LOANS SECURE REPOSITORY ---

  // Fetches loans and decrypts PII (Contact/Person name) dynamically
  Future<List<Loan>> getDecryptedLoans() async {
    final rawLoans = await _dbHelper.getAllLoans();

    return rawLoans.map((loan) {
      final decryptedName = SecurityHelper.decryptField(loan.personName, activeSessionKey);
      return Loan(
        id: loan.id,
        personName: decryptedName,
        type: loan.type,
        principalAmount: loan.principalAmount,
        remainingAmount: loan.remainingAmount,
        dueDate: loan.dueDate,
        status: loan.status,
      );
    }).toList();
  }

  // Encrypts personName before inserting loan record
  Future<void> addSecureLoan(Loan loan) async {
    if (loan.principalAmount <= 0) {
      throw ArgumentError("Loan principal amount must be strictly greater than zero.");
    }

    final sanitizedName = SecurityHelper.sanitizeString(loan.personName);
    final encryptedName = SecurityHelper.encryptField(sanitizedName, activeSessionKey);

    final secureLoan = Loan(
      id: loan.id,
      personName: encryptedName,
      type: loan.type,
      principalAmount: loan.principalAmount,
      remainingAmount: loan.remainingAmount,
      dueDate: loan.dueDate,
      status: loan.status,
    );

    await _dbHelper.addLoan(secureLoan);
  }

  // Record Installment Payment securely
  Future<void> makeSecureInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError("Installment amount must be strictly greater than zero.");
    }

    final sanitizedNotes = SecurityHelper.sanitizeString(notes);
    await _dbHelper.recordInstallment(
      loanId: loanId,
      walletId: walletId,
      amount: amount,
      notes: sanitizedNotes,
    );
  }

  // --- WALLET ADD / DELETE ---

  Future<void> addSecureWallet(wallet) async {
    if ((wallet.balance as double) < 0) {
      throw ArgumentError("Wallet opening balance cannot be negative.");
    }
    final sanitizedName = SecurityHelper.sanitizeString(wallet.name as String);
    await _dbHelper.insertWallet(wallet.copyWith(name: sanitizedName));
  }

  // Returns error string on failure, null on success.
  Future<String?> deleteWallet(String id) async {
    return await _dbHelper.deleteWallet(id);
  }

  // --- TRANSACTION DELETE ---

  Future<void> deleteTransaction(String txId) async {
    await _dbHelper.deleteTransaction(txId);
  }

  // --- LOAN DELETE ---

  Future<void> deleteLoan(String loanId) async {
    await _dbHelper.deleteLoan(loanId);
  }

  // --- PIN CHANGE ---

  Future<void> changePin(String newPin) async {
    final salt = DateTime.now().toIso8601String();
    final newHash = SecurityHelper.hashPin(newPin, salt);
    await _dbHelper.updateUserPin(newHash, salt);
    activeSessionKey = SecurityHelper.deriveKey(newPin, salt);
  }
}
