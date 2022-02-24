import 'package:hive_flutter/hive_flutter.dart';

part 'daily_survey.g.dart';

@HiveType(typeId: 1)
class DailySurvey extends HiveObject {
  @HiveField(0)
  Map<String, int> foodTypes;
  @HiveField(1)
  double totalEmissions = 0;
  @HiveField(2)
  double commuteDistance;
  @HiveField(3)
  double emissionsFromAdditionalTravel;

  DailySurvey(this.foodTypes, this.commuteDistance, this.emissionsFromAdditionalTravel);

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

// getCurrentWeekStartDate
// Start date of week is Monday
DateTime getCurrentWeekStartDate() {
  var now = DateTime.now();
  return now.subtract(Duration(
    days: now.weekday - 1,
    hours: now.hour,
    minutes: now.minute,
    seconds: now.second,
    milliseconds: now.millisecond,
    microseconds: now.microsecond
  ));
}
