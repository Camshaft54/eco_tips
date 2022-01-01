import 'dart:ui';

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

  @override
  Widget build(BuildContext context) {
    var firstDayInWeek = currDate.add(Duration(days: -currDate.weekday + 1));
    var weeklyCarbonEmissions =
        calculateWeeklyCarbonEmissions(firstDayInWeek).toStringAsFixed(1);
    if (weeklyCarbonEmissions == "-1.0") {
      weeklyCarbonEmissions = "N/A";
    }
    var hasCompletedDaily =
        Hive.box("daily").containsKey(currDate.toIso8601String());

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
                    builder: (context) =>
                    const SettingsPage()));
              },
            )
          ]),
          body: Column(children: [
            Expanded(
              child: Container(
                color: Colors.black12,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(weeklyCarbonEmissions,
                              style: const TextStyle(fontSize: 84))),
                      RichText(
                        text: TextSpan(
                            text:
                                "Week of ${DateFormat.yMd().format(firstDayInWeek)} ",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            children: const [
                              TextSpan(
                                  text: "total CO₂e/kg emissions",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal))
                            ]),
                      ),
                      const SizedBox(width: 10, height: 20),
                      _buildSurveyButton(
                          (hasCompletedDaily)
                              ? "Redo daily survey"
                              : "Complete daily survey",
                          color: (hasCompletedDaily)
                              ? Colors.grey
                              : (currDate != getCurrentDate())
                                  ? Colors.red
                                  : const Color.fromARGB(255, 34, 150, 243),
                          onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DailySurveyPage(date: currDate)));
                      }),
                    ]),
              ),
            ),
            Container(
              color: Colors.white,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: (currDate == Main.firstInstallDate)
                        ? null
                        : () {
                            setState(() {
                              currDate = currDate.add(const Duration(days: -1));
                            });
                          }),
                Text(formatDate(currDate)),
                IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: (currDate ==
                            getCurrentDate()) // Disable button if the current day is today
                        ? null
                        : () {
                            setState(() {
                              currDate = currDate.add(const Duration(days: 1));
                            });
                          }),
              ]),
            )
          ]),
        ));
  }
}

Widget _buildSurveyButton(String label,
    {Color color = const Color.fromARGB(255, 34, 150, 243),
    VoidCallback? onPressed}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
        child: Text(label),
        onPressed: onPressed,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(color))),
  );
}

double calculateWeeklyCarbonEmissions(DateTime weekStart) {
  var dailyBox = Hive.box("daily");
  var currDay = weekStart;
  var total = 0.0;
  var incompleteDays = 0;
  for (int i = 0; i < 7; i++) {
    if (dailyBox.containsKey(currDay.toIso8601String())) {
      total += dailyBox.get(currDay.toIso8601String()).emissions;
    } else {
      incompleteDays += 1;
    }
    currDay = currDay.add(const Duration(days: 1));
  }
  if (incompleteDays > 2) {
    return -1;
  } else {
    return total;
  }
}

String formatDate(DateTime date) {
  return DateFormat.yMEd().format(date);
}
