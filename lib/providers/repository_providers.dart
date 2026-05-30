import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/network/api_client.dart';
import '../data/repositories/api_motif_repository.dart';
import '../data/repositories/mock_motif_repository.dart';
import '../domain/repositories/motif_repository.dart';
import 'settings_providers.dart';

// Single binding point for mock <-> api. UI/state depend only on this provider.
// appSettingsProvider is read solely in the api branch, so mock mode never
// touches the (un-overridden) sharedPreferencesProvider.
final motifRepositoryProvider = Provider<MotifRepository>((ref) {
  switch (AppConfig.dataSource) {
    case DataSource.mock:
      return MockMotifRepository();
    case DataSource.api:
      final settings = ref.watch(appSettingsProvider);
      return ApiMotifRepository(ApiClient(baseUrl: settings.baseUrl));
  }
});
