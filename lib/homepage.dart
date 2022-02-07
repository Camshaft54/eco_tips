import 'package:carbon_tracker/main.dart';
import 'package:carbon_tracker/settings/settings_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'daily_survey/daily_survey.dart';
import 'daily_survey/daily_survey_form.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime currDate = getCurrentDate();
  AxisDirection dayCardDirection = AxisDirection.left;

  @override
  Widget build(BuildContext context) {
    var firstDayInWeek = currDate.add(Duration(days: -currDate.weekday + 1));
    var weeklyCarbonEmissions =
        calculateWeeklyCarbonEmissions(firstDayInWeek).toStringAsFixed(1);
    if (weeklyCarbonEmissions == "-1.0") {
      weeklyCarbonEmissions = "N/A";
    }

    return MaterialApp(
        title: 'Carbon Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
            appBar: AppBar(title: const Text("Surveys"), actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()));
                },
              )
            ]),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weeklyCarbonEmissions,
                        style: const TextStyle(fontSize: 84)),
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
                      text:
                          "Week of ${DateFormat.yMd().format(firstDayInWeek)} ",
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
                        currChild: DayCard(
                            key: ValueKey(currDate), currDate: currDate))),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: (currDate == Main.firstInstallDate)
                          ? null
                          : () {
                              setState(() {
                                dayCardDirection = AxisDirection.left;
                                currDate =
                                    currDate.add(const Duration(days: -1));
                              });
                            }),
                  ElevatedButton(
                      child: Text(formatDate(currDate)),
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
                                currDate =
                                    currDate.add(const Duration(days: 1));
                              });
                            }),
                ])
              ]),
            )));
  }
}

class DayCard extends StatelessWidget {
  final DateTime currDate;
  final bool hasCompletedDaily;

  DayCard({Key? key, required this.currDate})
      : hasCompletedDaily =
            Hive.box("daily").containsKey(currDate.toIso8601String()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.black12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        buildSurveyButton(
            (hasCompletedDaily) ? "Redo daily survey" : "Complete daily survey",
            color: (hasCompletedDaily)
                ? Colors.grey
                : (currDate != getCurrentDate())
                    ? Colors.red
                    : const Color.fromARGB(255, 34, 150, 243), onPressed: () {
          var transport = Hive.box('transport');
          if (transport.get(0) == null || !transport.get(0)!.isComplete) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                        title: const Text("Missing Transportation Settings"),
                        content: const Text(
                            "Finish transportation survey in settings before completing surveys"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          )
                        ]));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DailySurveyPage(date: currDate)));
          }
        }),
      ]),
    );
  }
}

Widget buildSurveyButton(String label,
    {Color color = const Color.fromARGB(255, 34, 150, 243),
    VoidCallback? onPressed,
    includePadding = true}) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: (includePadding) ? 5.0 : 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            child: Text(label),
            onPressed: onPressed,
            style:
                ButtonStyle(backgroundColor: MaterialStateProperty.all(color))),
      ));
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

String formatDate(DateTime date) {
  return DateFormat.yMEd().format(date);
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

IconButton buildHelpButton(
    {required BuildContext context,
    required String alertTitle,
    required String description,
    EdgeInsets padding = const EdgeInsets.all(8.0)}) {
  return IconButton(
      icon: const Icon(Icons.help),
      padding: padding,
      constraints: const BoxConstraints(),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text(alertTitle),
                    content: Text(description),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Close'),
                        child: const Text('Close'),
                      )
                    ]));
      });
}
