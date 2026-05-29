import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWallets {
  final WalletRepository repository;

  GetWallets(this.repository);

  Future<List<WalletEntity>> call() async {
    return await repository.getWallets();
  }
}
