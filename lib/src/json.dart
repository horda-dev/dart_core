import 'package:json_annotation/json_annotation.dart';

class DurationJsonConverter implements JsonConverter<Duration, int> {
  const DurationJsonConverter();

  @override
  Duration fromJson(int json) => Duration(milliseconds: json);

  @override
  int toJson(Duration object) => object.inSeconds;
}

class DateTimeJsonConverter implements JsonConverter<DateTime, int> {
  const DateTimeJsonConverter();

  @override
  DateTime fromJson(int json) => DateTime.fromMillisecondsSinceEpoch(json);

  @override
  int toJson(DateTime object) => object.millisecondsSinceEpoch;
}
