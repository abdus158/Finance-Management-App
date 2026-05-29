import '../../domain/entities/loan_entity.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_local_datasource.dart';
import '../models/loan_model.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanLocalDataSource localDataSource;

  LoanRepositoryImpl(this.localDataSource);

  @override
  Future<List<LoanEntity>> getLoans() async {
    return await localDataSource.fetchLoans();
  }

  @override
  Future<void> addLoan(LoanEntity loan) async {
    final model = LoanModel.fromEntity(loan);
    await localDataSource.saveLoan(model);
  }

  @override
  Future<void> payInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    await localDataSource.payInstallment(
      loanId: loanId,
      walletId: walletId,
      amount: amount,
      notes: notes,
    );
  }

  @override
  Future<Map<String, double>> fetchTrustScores() async {
    return await localDataSource.fetchTrustScores();
  }
}
