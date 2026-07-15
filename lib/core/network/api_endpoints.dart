// REST endpoint paths (relative to AppSettings.baseUrl).
class ApiEndpoints {
  const ApiEndpoints._();

  static const String categories = '/categories';
  static const String generate = '/generate';
  static const String histories = '/histories';
  static const String login = '/auth/login';
  static const String register = '/register';
  static const String updatePassword = '/users/me/password';



  static String categoryById(String id) => '/categories/$id';
  static String motifById(String id) => '/motifs/$id';
  static String saveMotif(String id) => '/motifs/$id/save';
  static String downloadMotif(String id) => '/motifs/$id/download';
  static String deleteHistory(String id) => '/histories/$id';
}
