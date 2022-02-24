import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'daily_survey/daily_survey.dart';
import 'daily_survey/daily_survey_form.dart';
import 'homepage.dart';
import 'main.dart';

class TrackerHome extends StatefulWidget {
  const TrackerHome({Key? key}) : super(key: key);

  @override
  State<TrackerHome> createState() => _TrackerHomeState();
}

class _TrackerHomeState extends State<TrackerHome> {
  DateTime currDate = getCurrentDate();
  AxisDirection dayCardDirection = AxisDirection.left;
  late bool hasCompletedDaily;

  @override
  Widget build(BuildContext context) {
    var firstDayInWeek = currDate.add(Duration(days: -currDate.weekday + 1));
    var weeklyCarbonEmissions =
        calculateWeeklyCarbonEmissions(firstDayInWeek).toStringAsFixed(1);
    if (weeklyCarbonEmissions == "-1.0") {
      weeklyCarbonEmissions = "N/A";
    }
    hasCompletedDaily =
        Hive.box("daily").containsKey(currDate.toIso8601String());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(weeklyCarbonEmissions, style: const TextStyle(fontSize: 84)),
            buildHelpButton(
                context: context,
                alertTitle: "Carbon Emissions",
                description:
                    "Weekly carbon emissions reflects your average carbon emissions per day for a certain week. The more days you submit surveys for, the more accurate the average will be.",
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10))
          ],
        ),
        RichText(
          text: TextSpan(
              text: "Week of ${DateFormat.yMd().format(firstDayInWeek)} ",
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
              children: const [
                TextSpan(
                    text: "daily average CO₂e/kg",
                    style: TextStyle(fontWeight: FontWeight.normal))
              ]),
        ),
        const SizedBox(width: 10, height: 20),
        Expanded(
            child: SlideAnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                direction: dayCardDirection,
                currChild: Card(
                  key: ValueKey(currDate),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        buildSurveyButton(
                            (hasCompletedDaily)
                                ? "Redo daily survey"
                                : "Complete daily survey",
                            color: (hasCompletedDaily)
                                ? Colors.grey
                                : (currDate != getCurrentDate())
                                    ? Colors.red
                                    : const Color.fromARGB(255, 34, 150, 243),
                            onPressed: () async {
                          var transport = Hive.box('transport');
                          if (transport.get(0) == null ||
                              !transport.get(0)!.isComplete) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: const Text(
                                            "Missing Transportation Settings"),
                                        content: const Text(
                                            "Finish transportation survey in settings before completing surveys"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'OK'),
                                            child: const Text('OK'),
                                          )
                                        ]));
                          } else {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DailySurveyPage(date: currDate)));
                            setState(() {});
                          }
                        }),
                      ]),
                ))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: (currDate == Main.firstInstallDate)
                  ? null
                  : () {
                      setState(() {
                        dayCardDirection = AxisDirection.left;
                        currDate = currDate.add(const Duration(days: -1));
                      });
                    }),
          ElevatedButton(
              child: Text(DateFormat.yMEd().format(currDate)),
              onPressed: () async {
                var newDate = await showDatePicker(
                    context: context,
                    initialDate: currDate,
                    firstDate: Main.firstInstallDate,
                    lastDate: getCurrentDate());
                if (newDate != null) {
                  setState(() {
                    dayCardDirection = (newDate.isAfter(currDate))
                        ? AxisDirection.right
                        : AxisDirection.left;
                    currDate = newDate;
                  });
                }
              }),
          IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: (currDate ==
                      getCurrentDate()) // Disable button if the current day is today
                  ? null
                  : () {
                      setState(() {
                        dayCardDirection = AxisDirection.right;
                        currDate = currDate.add(const Duration(days: 1));
                      });
                    }),
        ])
      ]),
    );
  }
}

double calculateWeeklyCarbonEmissions(DateTime weekStart) {
  var dailyBox = Hive.box("daily");
  var currDay = weekStart;
  var total = 0.0;
  var completeDays = 0;
  for (int i = 0; i < 7; i++) {
    if (dailyBox.containsKey(currDay.toIso8601String())) {
      total += dailyBox.get(currDay.toIso8601String()).totalEmissions;
      completeDays++;
    }
    currDay = currDay.add(const Duration(days: 1));
  }
  if (completeDays == 0) {
    return -1;
  } else {
    return total / completeDays;
  }
}

class SlideAnimatedSwitcher extends AnimatedSwitcher {
  SlideAnimatedSwitcher(
      {Key? key,
      required Duration duration,
      required currChild,
      required AxisDirection direction,
      double startOffset = -1.5,
      double endOffset = 1.5})
      : super(
            key: key,
            duration: duration,
            child: currChild,
            transitionBuilder: (Widget child, Animation<double> animation) {
              var currChildOffset = (direction == AxisDirection.left)
                  ? Tween<Offset>(
                      begin: Offset(startOffset, 0.0),
                      end: Offset.zero,
                    )
                  : Tween<Offset>(
                      begin: Offset(endOffset, 0.0),
                      end: Offset.zero,
                    );

              var prevChildOffset = (direction == AxisDirection.left)
                  ? Tween<Offset>(
                      begin: Offset(endOffset, 0.0),
                      end: Offset.zero,
                    )
                  : Tween<Offset>(
                      begin: Offset(startOffset, 0.0),
                      end: Offset.zero,
                    );

              var _offsetAnimation = ((child.key == currChild.key)
                      ? currChildOffset
                      : prevChildOffset)
                  .animate(animation);
              return SlideTransition(position: _offsetAnimation, child: child);
            });
}
