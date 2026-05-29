import '../entities/loan_entity.dart';
import '../repositories/loan_repository.dart';

class GetLoans {
  final LoanRepository repository;

  GetLoans(this.repository);

  Future<List<LoanEntity>> call() async {
    return await repository.getLoans();
  }
}
