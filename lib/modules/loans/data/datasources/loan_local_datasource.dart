import '../../../../core/security/secure_repository.dart';
import '../../../../core/database/db_helper.dart';
import '../../../../models/loan.dart' as global_model;
import '../models/loan_model.dart';

abstract class LoanLocalDataSource {
  Future<List<LoanModel>> fetchLoans();
  Future<void> saveLoan(LoanModel loan);
  Future<void> payInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  });
  Future<Map<String, double>> fetchTrustScores();
}

class LoanLocalDataSourceImpl implements LoanLocalDataSource {
  final SecureRepository secureRepository;
  final DBHelper dbHelper = DBHelper.instance;

  LoanLocalDataSourceImpl(this.secureRepository);

  @override
  Future<List<LoanModel>> fetchLoans() async {
    final secureLoans = await secureRepository.getDecryptedLoans();
    return secureLoans.map((l) {
      return LoanModel(
        id: l.id,
        personName: l.personName,
        type: l.type,
        principalAmount: l.principalAmount,
        remainingAmount: l.remainingAmount,
        dueDate: l.dueDate,
        status: l.status,
      );
    }).toList();
  }

  @override
  Future<void> saveLoan(LoanModel loan) async {
    final globalLoan = global_model.Loan(
      id: loan.id,
      personName: loan.personName,
      type: loan.type,
      principalAmount: loan.principalAmount,
      remainingAmount: loan.remainingAmount,
      dueDate: loan.dueDate,
      status: loan.status,
    );
    await secureRepository.addSecureLoan(globalLoan);
  }

  @override
  Future<void> payInstallment({
    required String loanId,
    required String walletId,
    required double amount,
    required String notes,
  }) async {
    await secureRepository.makeSecureInstallment(
      loanId: loanId,
      walletId: walletId,
      amount: amount,
      notes: notes,
    );
  }

  @override
  Future<Map<String, double>> fetchTrustScores() async {
    return await dbHelper.calculateTrustScores();
  }
}
