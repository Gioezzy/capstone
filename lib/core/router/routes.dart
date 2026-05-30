// Route name and path constants.
class Routes {
  Routes._();

  static const String splashPath = '/splash';
  static const String splashName = 'splash';

  static const String homePath = '/home';
  static const String homeName = 'home';

  static const String categoriesPath = '/categories';
  static const String categoriesName = 'categories';

  static const String configurePath = '/configure';
  static const String configureName = 'configure';

  static const String generatingPath = '/generating';
  static const String generatingName = 'generating';

  static const String resultPath = '/result';
  static const String resultName = 'result';

  static const String historyPath = '/history';
  static const String historyName = 'history';

  static const String historyDetailPath = '/history/:id';
  static const String historyDetailName = 'historyDetail';

  static const String settingsPath = '/settings';
  static const String settingsName = 'settings';

  static const String aboutPath = '/about';
  static const String aboutName = 'about';

  static String historyDetailPathFor(String id) => '/history/$id';
}
