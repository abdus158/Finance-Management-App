import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_transactions.dart';

class LedgerState extends ChangeNotifier {
  final AddTransaction addTransactionUseCase;
  final GetTransactions getTransactionsUseCase;

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  LedgerState({
    required this.addTransactionUseCase,
    required this.getTransactionsUseCase,
  });

  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetches decrypted transactions securely through usecases
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await getTransactionsUseCase();
    } catch (e) {
      _errorMessage = "Failed to load transactions: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adds a validated, encrypted transaction securely
  Future<void> addNewTransaction(TransactionEntity tx) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await addTransactionUseCase(tx);
      await loadTransactions(); // reload after adding
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
