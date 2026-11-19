import 'data_source.dart';
import 'memory_data_source.dart';
import 'firebase_data_source.dart';

class DataSourceFactory {
  static AuthDataSource createAuth(String type) {
    switch (type.toLowerCase()) {
      case 'firebase':
        return FirebaseAuthDataSource();
      case 'memory':
      default:
        return MemoryAuthDataSource();
    }
  }

  static ProviderDataSource createProvider(String type) {
    switch (type.toLowerCase()) {
      case 'firebase':
        return FirebaseProviderDataSource();
      case 'memory':
      default:
        return MemoryProviderDataSource();
    }
  }

  static JobDataSource createJob(String type) {
    switch (type.toLowerCase()) {
      case 'firebase':
        return FirebaseJobDataSource();
      case 'memory':
      default:
        return MemoryJobDataSource();
    }
  }

  static WalletDataSource createWallet(String type) {
    switch (type.toLowerCase()) {
      case 'firebase':
        return FirebaseWalletDataSource();
      case 'memory':
      default:
        return MemoryWalletDataSource();
    }
  }
}
