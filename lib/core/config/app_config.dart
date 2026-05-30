// Active data source. UI/state only know motifRepositoryProvider; this flag
// decides the concrete binding. Default: mock.
enum DataSource { mock, api }

class AppConfig {
  AppConfig._();

  // Compile-time selection: --dart-define=DATA_SOURCE=mock|api
  static const String _raw =
      String.fromEnvironment('DATA_SOURCE', defaultValue: 'mock');

  static DataSource get dataSource =>
      _raw == 'api' ? DataSource.api : DataSource.mock;

  static bool get isMock => dataSource == DataSource.mock;
}
