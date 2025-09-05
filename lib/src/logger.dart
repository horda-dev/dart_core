// ignore_for_file: avoid_print

enum LogLevel {
  /// The trace level is used to log the entry of a method
  /// that concludes with either an info or debug log message.
  ///
  /// Log messages at the trace level are typically worded to
  /// indicate that something is being done or about to be done.
  /// The ing present or gerund form of verbs is used in trace
  /// messages, for example "Writing message".
  trace,

  /// The debug level is used to log the completion of a secondary
  /// operation of a class or utility, or for recording other details.
  /// For example: A message writer's secondary operation, like
  /// it's initial method or its reply method.
  ///
  /// Log messages at the debug level are typically worded to
  /// indicate that something has been done or completed.
  /// The ed past tense form of verbs is used in debug messages,
  /// for example "Wrote initial message".
  debug,

  /// The info level is used to log the completion of the principle
  /// operation of a class or utility, like a callable class or
  /// object's actuator. For example: A message writer's principle
  /// actuator.
  ///
  /// Log messages at the info level are typically worded to indicate
  /// that something has been done or completed. The ed past tense
  /// form of verbs is used in trace messages, for example "Wrote message".
  info,

  /// The warn level is used to log an unexpected condition that
  /// isn't an error and that does not need to terminate the process.
  /// A warn log message indicates something that may not have been
  /// intentional and that a developer or operator should examine.
  warn,

  /// The error level is used to log an error message before a
  /// process terminates. The error level should only be used
  /// to log fatal, terminal error states.
  error,
}

/// Abstract logging interface for the Horda platform.
///
/// Provides structured logging capabilities with different severity levels
/// for debugging, monitoring, and troubleshooting system operations.
abstract class Logger {
  /// Current minimum log level that will be output.
  LogLevel get level;

  /// Logs a fatal error message before process termination.
  void error(String subject, String msg);

  /// Logs an unexpected but non-fatal condition.
  void warn(String subject, String msg);

  /// Logs completion of a principal operation.
  void info(String subject, String msg);

  /// Logs completion of a secondary operation or detailed information.
  void debug(String subject, String msg);

  /// Logs entry into a method or start of an operation.
  void trace(String subject, String msg);
}

/// Extension providing a generic log method for all log levels.
///
/// Enables logging at any level through a single method interface.
extension LogExtension on Logger {
  /// Logs a message at the specified level.
  ///
  /// [level] - The severity level for this log message
  /// [subject] - Component or operation being logged
  /// [msg] - The log message content
  void log(LogLevel level, String subject, String msg) {
    switch (level) {
      case LogLevel.error:
        error(subject, msg);
        break;
      case LogLevel.warn:
        warn(subject, msg);
        break;
      case LogLevel.info:
        info(subject, msg);
        break;
      case LogLevel.debug:
        debug(subject, msg);
        break;
      case LogLevel.trace:
        trace(subject, msg);
        break;
    }
  }
}

/// Simple console-based logger implementation.
///
/// Outputs log messages to stdout with level filtering and basic formatting.
/// Used for development and testing of Horda applications.
class SimpleLogger implements Logger {
  /// Creates a simple logger with the specified minimum level.
  const SimpleLogger(this.level);

  @override
  final LogLevel level;

  @override
  void error(String subject, String msg) {
    print(_record('ERROR', subject, msg));
  }

  @override
  void warn(String subject, String msg) {
    if (level.index > LogLevel.warn.index) {
      return;
    }
    print(_record('WARN', subject, msg));
  }

  @override
  void info(String subject, String msg) {
    if (level.index > LogLevel.info.index) {
      return;
    }
    print(_record('INFO', subject, msg));
  }

  @override
  void debug(String subject, String msg) {
    if (level.index > LogLevel.debug.index) {
      return;
    }
    print(_record('DEBUG', subject, msg));
  }

  @override
  void trace(String subject, String msg) {
    if (level.index > LogLevel.trace.index) {
      return;
    }
    print(_record('TRACE', subject, msg));
  }

  /// Formats a log record with level, subject, and message.
  String _record(String level, String subject, String msg) {
    return '$level:$subject: $msg';
  }
}
