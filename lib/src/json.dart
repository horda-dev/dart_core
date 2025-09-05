import 'package:json_annotation/json_annotation.dart';

/// JSON converter for Duration objects in the Horda platform.
///
/// Converts Duration objects to/from integer values representing seconds
/// for efficient network transmission and storage.
class DurationJsonConverter implements JsonConverter<Duration, int> {
  /// Creates a duration JSON converter.
  const DurationJsonConverter();

  /// Converts JSON integer (seconds) to Duration object.
  @override
  Duration fromJson(int json) => Duration(milliseconds: json);

  /// Converts Duration object to JSON integer (seconds).
  @override
  int toJson(Duration object) => object.inSeconds;
}

/// JSON converter for DateTime objects in the Horda platform.
///
/// Converts DateTime objects to/from integer values representing
/// milliseconds since epoch for consistent time handling across the system.
class DateTimeJsonConverter implements JsonConverter<DateTime, int> {
  /// Creates a DateTime JSON converter.
  const DateTimeJsonConverter();

  /// Converts JSON integer (milliseconds since epoch) to DateTime object.
  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  /// Converts DateTime object to JSON integer (milliseconds since epoch).
  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}
