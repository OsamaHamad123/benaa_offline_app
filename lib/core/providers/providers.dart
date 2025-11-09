import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/drift_database.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../security/crypto_box.dart';

// App Config Provider
final appConfigProvider = FutureProvider<AppConfig>((ref) async {
  return await AppConfig.load();
});

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase(openEncryptedDb());
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider).value;
  if (config == null) {
    throw Exception('App config not loaded');
  }
  return ApiClient(config);
});

// Crypto Box Provider
final cryptoBoxProvider = FutureProvider<CryptoBox>((ref) async {
  return await CryptoBox.create();
});

// Database ready provider - waits for database to be initialized
final databaseReadyProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  // Ensure database is open
  try {
    await db.customSelect('SELECT 1').get();
    return true;
  } catch (e) {
    return false;
  }
});
