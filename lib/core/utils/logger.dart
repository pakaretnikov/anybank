class Logger {
  Logger._();

  static void info(String message) {}
  static void warn(String message) {}
  static void error(String message, [Object? err, StackTrace? st]) {}
}

