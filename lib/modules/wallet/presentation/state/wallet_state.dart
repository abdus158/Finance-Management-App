import 'package:flutter/material.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/get_wallets.dart';
import '../../domain/usecases/transfer_funds.dart';

class WalletState extends ChangeNotifier {
  final GetWallets getWalletsUseCase;
  final TransferFunds transferFundsUseCase;

  List<WalletEntity> _wallets = [];
  bool _isLoading = false;
  String? _errorMessage;

  WalletState({
    required this.getWalletsUseCase,
    required this.transferFundsUseCase,
  });

  List<WalletEntity> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetches wallets securely
  Future<void> loadWallets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wallets = await getWalletsUseCase();
    } catch (e) {
      _errorMessage = "Failed to load wallets: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Executes a secure internal funds transfer (Double-Entry verified)
  Future<void> executeTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    required String notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await transferFundsUseCase(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        notes: notes,
      );
      await loadWallets(); // refresh balances
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
