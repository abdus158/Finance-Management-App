import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import '../../models/loan.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fcc_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const nullableText = 'TEXT';

    // 1. Wallets Table
    await db.execute('''
      CREATE TABLE wallets (
        id $textType PRIMARY KEY,
        name $textType,
        type $textType,
        balance $realType,
        currency $textType
      )
    ''');

    // 2. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $textType PRIMARY KEY,
        name $textType,
        icon $textType,
        type $textType,
        context $textType
      )
    ''');

    // 3. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id $textType PRIMARY KEY,
        walletId $textType,
        type $textType,
        amount $realType,
        categoryId $textType,
        tags $textType,
        priority $textType,
        date $integerType,
        notes $textType,
        linkedTransactionId $nullableText,
        FOREIGN KEY (walletId) REFERENCES wallets (id),
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // 4. Loans Table
    await db.execute('''
      CREATE TABLE loans (
        id $textType PRIMARY KEY,
        personName $textType,
        type $textType,
        principalAmount $realType,
        remainingAmount $realType,
        dueDate $integerType,
        status $textType
      )
    ''');

    // 5. Loan Installments Table
    await db.execute('''
      CREATE TABLE loan_installments (
        id $textType PRIMARY KEY,
        loanId $textType,
        transactionId $textType,
        amount $realType,
        date $integerType,
        FOREIGN KEY (loanId) REFERENCES loans (id),
        FOREIGN KEY (transactionId) REFERENCES transactions (id)
      )
    ''');

    // 6. Users / Lock PIN Table
    await db.execute('''
      CREATE TABLE users (
        id $textType PRIMARY KEY,
        pin_hash $textType,
        salt $textType,
        created_at $integerType
      )
    ''');

    // Seed initial data
    await _seedInitialData(db);
  }

  Future _seedInitialData(Database db) async {
    final uuid = const Uuid();

    // 1. Seed Default Wallets
    final wallets = [
      Wallet(id: uuid.v4(), name: 'Cash Wallet', type: 'CASH', balance: 5000.0, currency: 'PKR'),
      Wallet(id: uuid.v4(), name: 'HBL Bank', type: 'BANK', balance: 120000.0, currency: 'PKR'),
      Wallet(id: uuid.v4(), name: 'Easypaisa', type: 'DIGITAL', balance: 15000.0, currency: 'PKR'),
      Wallet(id: uuid.v4(), name: 'Emerge Nexus', type: 'BUSINESS', balance: 450000.0, currency: 'PKR'),
    ];

    for (var w in wallets) {
      await db.insert('wallets', w.toMap());
    }

    // 2. Seed Default Categories
    final categories = [
      // Personal
      {'id': uuid.v4(), 'name': 'Food & Dining', 'icon': 'fastfood', 'type': 'EXPENSE', 'context': 'PERSONAL'},
      {'id': uuid.v4(), 'name': 'Rent & Bills', 'icon': 'home', 'type': 'EXPENSE', 'context': 'PERSONAL'},
      {'id': uuid.v4(), 'name': 'Salary', 'icon': 'work', 'type': 'INCOME', 'context': 'PERSONAL'},
      {'id': uuid.v4(), 'name': 'Shopping', 'icon': 'shopping_bag', 'type': 'EXPENSE', 'context': 'PERSONAL'},
      // Business (Emerge Nexus)
      {'id': uuid.v4(), 'name': 'Client Payment', 'icon': 'payments', 'type': 'INCOME', 'context': 'BUSINESS'},
      {'id': uuid.v4(), 'name': 'Marketing & Ads', 'icon': 'campaign', 'type': 'EXPENSE', 'context': 'BUSINESS'},
      {'id': uuid.v4(), 'name': 'Hosting & Software', 'icon': 'dns', 'type': 'EXPENSE', 'context': 'BUSINESS'},
      {'id': uuid.v4(), 'name': 'Freelancer Payout', 'icon': 'people', 'type': 'EXPENSE', 'context': 'BUSINESS'},
      // Both
      {'id': uuid.v4(), 'name': 'Miscellaneous', 'icon': 'category', 'type': 'EXPENSE', 'context': 'BOTH'},
    ];

    for (var c in categories) {
      await db.insert('categories', c);
    }
  }

  // --- WALLET METHODS ---

  Future<List<Wallet>> getAllWallets() async {
    final db = await instance.database;
    final result = await db.query('wallets');
    return result.map((json) => Wallet.fromMap(json)).toList();
  }

  Future<int> updateWalletBalance(String id, double newBalance) async {
    final db = await instance.database;
    return await db.update(
      'wallets',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- TRANSACTION METHODS ---

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      // 1. Insert transaction
      await txn.insert('transactions', tx.toMap());

      // 2. Adjust Wallet Balance
      final List<Map<String, dynamic>> walletResult = await txn.query(
        'wallets',
        where: 'id = ?',
        whereArgs: [tx.walletId],
      );
      if (walletResult.isNotEmpty) {
        final wallet = Wallet.fromMap(walletResult.first);
        double newBalance = wallet.balance;
        if (tx.type == 'INCOME') {
          newBalance += tx.amount;
        } else if (tx.type == 'EXPENSE') {
          newBalance -= tx.amount;
        }
        await txn.update(
          'wallets',
          {'balance': newBalance},
          where: 'id = ?',
          whereArgs: [tx.walletId],
        );
      }
    });
  }

  // Smart Feature: Internal Wallet Transfer (Dual transaction with single action)
  Future<void> transferFunds({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    final db = await instance.database;
    final uuid = const Uuid();
    final now = DateTime.now();

    final txOutId = uuid.v4();
    final txInId = uuid.v4();

    await db.transaction((txn) async {
      // 1. Insert "Out" Transaction
      final txOut = TransactionModel(
        id: txOutId,
        walletId: fromWalletId,
        type: 'EXPENSE',
        amount: amount,
        categoryId: 'TRANSFER', // special tag
        tags: 'Transfer, Internal',
        priority: 'MEDIUM',
        date: now,
        notes: '[Transfer Out to Wallet] $notes',
        linkedTransactionId: txInId,
      );
      await txn.insert('transactions', txOut.toMap());

      // 2. Insert "In" Transaction
      final txIn = TransactionModel(
        id: txInId,
        walletId: toWalletId,
        type: 'INCOME',
        amount: amount,
        categoryId: 'TRANSFER',
        tags: 'Transfer, Internal',
        priority: 'MEDIUM',
        date: now,
        notes: '[Transfer In from Wallet] $notes',
        linkedTransactionId: txOutId,
      );
      await txn.insert('transactions', txIn.toMap());

      // 3. Deduct from Source Wallet
      final List<Map<String, dynamic>> walletSrc = await txn.query('wallets', where: 'id = ?', whereArgs: [fromWalletId]);
      if (walletSrc.isNotEmpty) {
        final src = Wallet.fromMap(walletSrc.first);
        await txn.update('wallets', {'balance': src.balance - amount}, where: 'id = ?', whereArgs: [fromWalletId]);
      }

      // 4. Add to Destination Wallet
      final List<Map<String, dynamic>> walletDst = await txn.query('wallets', where: 'id = ?', whereArgs: [toWalletId]);
      if (walletDst.isNotEmpty) {
        final dst = Wallet.fromMap(walletDst.first);
        await txn.update('wallets', {'balance': dst.balance + amount}, where: 'id = ?', whereArgs: [toWalletId]);
      }
    });
  }

  // --- LOAN METHODS ---

  Future<List<Loan>> getAllLoans() async {
    final db = await instance.database;
    final result = await db.query('loans', orderBy: 'dueDate ASC');
    return result.map((json) => Loan.fromMap(json)).toList();
  }

  Future<void> addLoan(Loan loan) async {
    final db = await instance.database;
    await db.insert('loans', loan.toMap());
  }

  // Pay Installment / Receive installment against a Loan
  Future<void> recordInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    final db = await instance.database;
    final uuid = const Uuid();
    final now = DateTime.now();

    await db.transaction((txn) async {
      // 1. Fetch Loan
      final List<Map<String, dynamic>> loanRes = await txn.query('loans', where: 'id = ?', whereArgs: [loanId]);
      if (loanRes.isEmpty) return;
      final loan = Loan.fromMap(loanRes.first);

      // 2. Verify remaining balance
      final double newRemaining = loan.remainingAmount - amount;
      final String newStatus = newRemaining <= 0 ? 'PAID' : 'ACTIVE';

      // 3. Create Transaction
      final txId = uuid.v4();
      final tx = TransactionModel(
        id: txId,
        walletId: walletId,
        type: loan.type == 'PAYABLE' ? 'EXPENSE' : 'INCOME', // paying off liability is expense, receiving loan payment is income
        amount: amount,
        categoryId: 'LOAN_PAYMENT',
        tags: 'Loan, Installment',
        priority: 'HIGH',
        date: now,
        notes: '[Loan Payment: ${loan.personName}] $notes',
      );

      // 4. Insert Transaction & Update Wallet Balance
      await txn.insert('transactions', tx.toMap());
      final List<Map<String, dynamic>> walletResult = await txn.query('wallets', where: 'id = ?', whereArgs: [walletId]);
      if (walletResult.isNotEmpty) {
        final w = Wallet.fromMap(walletResult.first);
        double wBal = w.balance;
        if (tx.type == 'INCOME') {
          wBal += amount;
        } else {
          wBal -= amount;
        }
        await txn.update('wallets', {'balance': wBal}, where: 'id = ?', whereArgs: [walletId]);
      }

      // 5. Create Installment Record
      final installment = LoanInstallment(
        id: uuid.v4(),
        loanId: loanId,
        transactionId: txId,
        amount: amount,
        date: now,
      );
      await txn.insert('loan_installments', installment.toMap());

      // 6. Update Loan status
      await txn.update(
        'loans',
        {
          'remainingAmount': newRemaining < 0 ? 0.0 : newRemaining,
          'status': newStatus,
        },
        where: 'id = ?',
        whereArgs: [loanId],
      );
    });
  }

  // --- CASH FLOW & TRUST SCORE FORECASTS ---

  // Advanced twist: Trust Score Calculation (Receivables only)
  // Formula: Starts at 100%. Deducts 10 points for each loan that passes due date unpaid.
  // Deducts 2 points per day delayed.
  Future<Map<String, double>> calculateTrustScores() async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> result = await db.query('loans', where: "type = 'RECEIVABLE'");

    final Map<String, double> scores = {};
    for (var row in result) {
      final loan = Loan.fromMap(row);
      double score = 100.0;

      if (loan.status == 'ACTIVE' && now > loan.dueDate.millisecondsSinceEpoch) {
        final delayMs = now - loan.dueDate.millisecondsSinceEpoch;
        final delayDays = (delayMs / (1000 * 60 * 60 * 24)).floor();
        score -= 10.0; // Base penalty for breach
        score -= (delayDays * 2.0); // 2 pts per day
      }

      if (score < 0) score = 0.0;
      scores[loan.personName] = score;
    }

    return scores;
  }

  // Advanced twist: Forecast cash remaining days (Daily burn rate)
  // Calculates average expenses of last 7 days and forecasts how long current total balance will last.
  Future<Map<String, dynamic>> getCashForecast() async {
    final db = await instance.database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    // Get total balance
    final List<Map<String, dynamic>> wallets = await db.query('wallets');
    double totalBalance = 0.0;
    for (var w in wallets) {
      totalBalance += (w['balance'] as num).toDouble();
    }

    // Get expenses of last 7 days
    final List<Map<String, dynamic>> lastWeekTx = await db.rawQuery('''
      SELECT SUM(amount) as totalExpense 
      FROM transactions 
      WHERE type = 'EXPENSE' AND date >= ? AND categoryId != 'TRANSFER'
    ''', [sevenDaysAgo]);

    double lastWeekTotal = 0.0;
    if (lastWeekTx.isNotEmpty && lastWeekTx.first['totalExpense'] != null) {
      lastWeekTotal = (lastWeekTx.first['totalExpense'] as num).toDouble();
    }

    double dailyBurnRate = lastWeekTotal / 7.0;
    double daysRemaining = dailyBurnRate > 0 ? (totalBalance / dailyBurnRate) : 999.0;

    return {
      'totalBalance': totalBalance,
      'dailyBurnRate': dailyBurnRate,
      'daysRemaining': daysRemaining == 999.0 ? 'Infinity' : daysRemaining.toStringAsFixed(1),
      'isLowRisk': daysRemaining > 15,
      'isCritical': daysRemaining <= 6, // Critical alarm: less than 6 days remaining!
    };
  }

  // Get categories list
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories');
  }

  // --- WALLET CRUD ---

  Future<void> insertWallet(Wallet wallet) async {
    final db = await instance.database;
    await db.insert('wallets', wallet.toMap());
  }

  // Only allows deletion when balance is 0 (no funds stranded).
  // Historical transactions referencing this wallet are kept as records.
  Future<String?> deleteWallet(String id) async {
    final db = await instance.database;
    final rows = await db.query('wallets', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return 'Wallet not found.';
    final w = Wallet.fromMap(rows.first);
    if (w.balance != 0) {
      return w.balance > 0
          ? 'Transfer all funds out before deleting.'
          : 'Resolve negative balance before deleting.';
    }
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
    return null; // null = success
  }

  // --- TRANSACTION DELETE ---

  // Reverses the wallet balance impact of the deleted transaction.
  // For transfer pairs, deletes and reverses both legs.
  Future<void> deleteTransaction(String txId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final rows = await txn.query('transactions', where: 'id = ?', whereArgs: [txId]);
      if (rows.isEmpty) return;
      final tx = TransactionModel.fromMap(rows.first);

      Future<void> reverseBalance(String walletId, String txType, double amount) async {
        final wRows = await txn.query('wallets', where: 'id = ?', whereArgs: [walletId]);
        if (wRows.isEmpty) return;
        final w = Wallet.fromMap(wRows.first);
        final double newBal = txType == 'INCOME' ? w.balance - amount : w.balance + amount;
        await txn.update('wallets', {'balance': newBal}, where: 'id = ?', whereArgs: [walletId]);
      }

      await reverseBalance(tx.walletId, tx.type, tx.amount);

      if (tx.linkedTransactionId != null) {
        final linkedRows = await txn.query('transactions',
            where: 'id = ?', whereArgs: [tx.linkedTransactionId]);
        if (linkedRows.isNotEmpty) {
          final linked = TransactionModel.fromMap(linkedRows.first);
          await reverseBalance(linked.walletId, linked.type, linked.amount);
          await txn.delete('transactions', where: 'id = ?', whereArgs: [tx.linkedTransactionId]);
        }
      }

      await txn.delete('transactions', where: 'id = ?', whereArgs: [txId]);
    });
  }

  // --- LOAN DELETE ---

  Future<void> deleteLoan(String loanId) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('loan_installments', where: 'loanId = ?', whereArgs: [loanId]);
      await txn.delete('loans', where: 'id = ?', whereArgs: [loanId]);
    });
  }

  // --- USER PIN UPDATE ---

  Future<void> updateUserPin(String newHash, String newSalt) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'pin_hash': newHash, 'salt': newSalt},
      where: 'id = ?',
      whereArgs: ['local_user'],
    );
  }
}
