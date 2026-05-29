import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Security & persistence layers
import '../core/security/secure_repository.dart';
import '../providers/fcc_provider.dart';

// Ledger Module
import '../modules/ledger/data/datasources/ledger_local_datasource.dart';
import '../modules/ledger/data/repositories_impl/transaction_repository_impl.dart';
import '../modules/ledger/domain/usecases/add_transaction.dart';
import '../modules/ledger/domain/usecases/get_transactions.dart';
import '../modules/ledger/presentation/state/ledger_state.dart';

// Wallet Module
import '../modules/wallet/data/datasources/wallet_local_datasource.dart';
import '../modules/wallet/data/repositories_impl/wallet_repository_impl.dart';
import '../modules/wallet/domain/usecases/get_wallets.dart';
import '../modules/wallet/domain/usecases/transfer_funds.dart';
import '../modules/wallet/presentation/state/wallet_state.dart';

// Loans Module
import '../modules/loans/data/datasources/loan_local_datasource.dart';
import '../modules/loans/data/repositories_impl/loan_repository_impl.dart';
import '../modules/loans/domain/usecases/get_loans.dart';
import '../modules/loans/domain/usecases/pay_installment.dart';
import '../modules/loans/presentation/state/loan_state.dart';

import 'routes.dart';
import 'theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Dependency Injection instantiation
    final secureRepository = SecureRepository();

    final ledgerRepo = TransactionRepositoryImpl(LedgerLocalDataSourceImpl(secureRepository));
    final walletRepo = WalletRepositoryImpl(WalletLocalDataSourceImpl(secureRepository));
    final loanRepo = LoanRepositoryImpl(LoanLocalDataSourceImpl(secureRepository));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FCCProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LedgerState(
            addTransactionUseCase: AddTransaction(ledgerRepo),
            getTransactionsUseCase: GetTransactions(ledgerRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletState(
            getWalletsUseCase: GetWallets(walletRepo),
            transferFundsUseCase: TransferFunds(walletRepo),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LoanState(
            getLoansUseCase: GetLoans(loanRepo),
            payInstallmentUseCase: PayInstallment(loanRepo),
            repository: loanRepo,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Financial Command Center',
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.lockscreen,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
