import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:hive/hive.dart';

part 'tip_selection.g.dart';

@HiveType(typeId: 3)
class TipSelection extends HiveObject {
  @HiveField(0)
  List<String> tips;
  @HiveField(1)
  List<List<int>> points = [
    for (int i = 0; i < 7; i++) [0, 0, 0]
  ];
  @HiveField(2)
  List<bool> dailyCheckCompleted = List.filled(7, false);

  @HiveField(3)
  int totalPoints = 0;

  TipSelection(this.tips);

  @override
  String toString() {
    return "Tips: ${tips.join(", ")} - $points pts";
  }

}

extension TipBoxFuncs on Box<TipSelection> {
  // ignore: avoid_init_to_null
  String? getWeekKey({DateTime? specificDate = null}) {
    var key = getWeekStartDate(specificDate: specificDate)
        .millisecondsSinceEpoch
        .toString();
    return containsKey(key) ? key : null;
  }

  String generateWeekKey() =>
      getWeekStartDate().millisecondsSinceEpoch.toString();

  List<String> getKeysForMonth(DateTime lastDate) {
    const maxWeeks = 5;
    DateTime currDate = getWeekStartDate(specificDate: lastDate);
    List<String> keys = [];
    // Loop for up to five weeks (max number of weeks in one month) until current month has changed
    // During each iteration, add a new key for the current week, then subtract 7 days from date
    for (int i = 0; i < maxWeeks; i++) {
      if (currDate.month != lastDate.month) break;
      var currWeekKey = getWeekKey(specificDate: currDate);
      if (currWeekKey != null) keys.add(currWeekKey);
      currDate = currDate.subtract(const Duration(days: 7));
    }
    return keys;
  }
}
