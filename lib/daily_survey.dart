import 'package:hive_flutter/hive_flutter.dart';

part 'daily_survey.g.dart';

@HiveType(typeId: 1)
class DailySurvey extends HiveObject {
  @HiveField(0)
  Map<String, int> foodTypes;
  @HiveField(1)
  double emissions;

  DailySurvey(this.foodTypes, this.emissions);

  @override
  String toString() {
    return foodTypes.toString();
  }
}

DateTime getCurrentDate() {
  var now = DateTime.now();
  return now.subtract(Duration(
      hours: now.hour,
      minutes: now.minute,
      seconds: now.second,
      milliseconds: now.millisecond,
      microseconds: now.microsecond));
}
