import '../../data/sources/data_source.dart';
import '../../data/sources/data_source_factory.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository_impl/auth_repository_impl.dart';
import '../../features/providers/repository/provider_repository.dart';
import '../../features/providers/repository_impl/provider_repository_impl.dart';
import '../../features/jobs/repository/job_repository.dart';
import '../../features/jobs/repository_impl/job_repository_impl.dart';
import '../../features/wallet/repository/wallet_repository.dart';
import '../../features/wallet/repository_impl/wallet_repository_impl.dart';

class Injector {
  static late AuthDataSource authDs;
  static late ProviderDataSource providerDs;
  static late JobDataSource jobDs;
  static late WalletDataSource walletDs;

  static late AuthRepository authRepo;
  static late ProviderRepository providerRepo;
  static late JobRepository jobRepo;
  static late WalletRepository walletRepo;
}

void setupDependencies(String dataSourceType) {
  Injector.authDs = DataSourceFactory.createAuth(dataSourceType);
  Injector.providerDs = DataSourceFactory.createProvider(dataSourceType);
  Injector.jobDs = DataSourceFactory.createJob(dataSourceType);
  Injector.walletDs = DataSourceFactory.createWallet(dataSourceType);

  Injector.authRepo = AuthRepositoryImpl(Injector.authDs);
  Injector.providerRepo = ProviderRepositoryImpl(Injector.providerDs);
  Injector.jobRepo = JobRepositoryImpl(Injector.jobDs);
  Injector.walletRepo = WalletRepositoryImpl(Injector.walletDs);
}
