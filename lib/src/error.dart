/// Error class for exceptions within the Horda platform.
/// 
/// Used to represent system errors, validation failures, and other
/// exceptional conditions that occur during entity command processing,
/// business process execution, or message handling.
class FluirError extends Error {
  /// Creates a Horda platform error with the specified message.
  FluirError(this.msg);

  /// Human-readable error message describing what went wrong.
  final String msg;

  @override
  String toString() => msg;

  /// Converts the error to JSON representation for network transmission.
  Map<String, dynamic> toJson() {
    return {'msg': msg};
  }
}
