import 'package:carbon_tracker/tips/daily_tip_check.dart';
import 'package:carbon_tracker/tips/tip_loader.dart';
import 'package:carbon_tracker/tips/tip_selection.dart';
import 'package:carbon_tracker/tips/weekly_tip_selector.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'tips/tip_selection.dart';
import 'homepage.dart';

class TipsHome extends StatefulWidget {
  const TipsHome({Key? key}) : super(key: key);

  @override
  State<TipsHome> createState() => _TipsHomeState();
}

class _TipsHomeState extends State<TipsHome> {
  @override
  Widget build(BuildContext context) {
    Box<TipSelection> tipsBox = Hive.box<TipSelection>("tips");
    var areTipsSelected = tipsBox.getWeekKey() != null;

    // Get the keys for this month (function returns map by date, but we only want keys)
    var monthKeys = tipsBox.getKeysForMonth(DateTime.now()).values;
    var pointsTotal = (monthKeys.isNotEmpty)
        ? monthKeys
            .map((key) => tipsBox.get(key)!.totalPoints)
            .reduce((a, b) => a + b)
        : 0;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pointsTotal.toString(), style: const TextStyle(fontSize: 84)),
          buildHelpButton(
              context: context,
              alertTitle: "Tips",
              description:
                  "Tips will provide various suggestions for how you can reduce your carbon footprint. The month's total points reflects the points you have earned from completing tips this month so far.",
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10))
        ],
      ),
      RichText(
        text: TextSpan(
            text: "${DateFormat("MMMM").format(DateTime.now())} ",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            children: const [
              TextSpan(
                  text: "points (to date)",
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
      ),
      Expanded(
          child: ListView(children: [
        TipSelectionCard(
            context: context,
            setStateCallback: setState,
            toEdit: !areTipsSelected),
        TipCheckCard(
            completed: areTipsSelected &&
                !tipsBox
                    .get(tipsBox.getWeekKey())!
                    .dailyCheckCompleted[DateTime.now().weekday - 1],
            setStateCallback: setState,
            context: context),
        TipsStatusCard()
      ]))
    ]);
  }
}

class TipSelectionCard extends Card {
  TipSelectionCard(
      {Key? key,
      required BuildContext context,
      required Function setStateCallback,
      bool toEdit = true})
      : super(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const ListTile(
                leading: Icon(Icons.checklist),
                title: Text("Weekly Tip Selection"),
                subtitle:
                    Text("Select which tips you want to focus on this week"),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    child: (toEdit) ? const Text("Start") : const Text("View"),
                    onPressed: () async {
                      if (toEdit) {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WeeklyTipSelector()));
                        setStateCallback.call(() {});
                      } else {
                        viewTipsDialog(context);
                      }
                    })
              ])
            ]));
}

class TipCheckCard extends Card {
  TipCheckCard(
      {Key? key,
      required BuildContext context,
      required setStateCallback,
      bool completed = false})
      : super(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Daily Tip Check"),
                  subtitle: Text(
                      "Did you work on your weekly tips today? If so, you can earn points based on each tip's difficulty!"),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      child: const Text("Start"),
                      onPressed: (!completed)
                          ? null
                          : () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const DailyTipCheck()));
                              setStateCallback.call(() {});
                            })
                ])
              ],
            ));
}

viewTipsDialog(BuildContext context) {
  TipLoader.allTipsFuture.then((allTips) {
    Box<TipSelection> tipsBox = Hive.box<TipSelection>("tips");
    var tipSelection = tipsBox.get(tipsBox.getWeekKey())!;
    showDialog(
        context: context,
        builder: (context) =>
            SimpleDialog(title: const Text("Your Tip Selection"), children: [
              for (String tipId in tipSelection.tips)
                SimpleDialogOption(
                    onPressed: () {},
                    child: Text.rich(TextSpan(
                        text: allTips[tipId]!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                              text:
                                  " (${allTips[tipId]!.difficulty} star${allTips[tipId]!.difficulty > 1 ? "s" : ""})",
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal))
                        ])))
            ]));
  });
}

class TipsStatusCard extends Card {
  TipsStatusCard({Key? key, bool completed = false})
      : super(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const ListTile(
                leading: Icon(Icons.bar_chart),
                title: Text("Tips Activity"),
                subtitle: Text("Track your progress over the past few weeks."),
              ),
              Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 12),
                  child: SizedBox(height: 200, child: TimeSeriesBar.withData()))
            ]));
}

class TimeSeriesBar extends StatelessWidget {
  final List<charts.Series<TimeSeriesStars, DateTime>> seriesList;

  TimeSeriesBar(this.seriesList);

  factory TimeSeriesBar.withData() {
    return TimeSeriesBar(_generateTipsData());
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      domainAxis: const charts.DateTimeAxisSpec(
        tickProviderSpec: charts.AutoDateTimeTickProviderSpec(includeTime: false),
        tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
          day: charts.TimeFormatterSpec(
            format: 'dd',
            transitionFormat: 'MMM dd',
          ),
          month: charts.TimeFormatterSpec(
            format: 'MMM dd',
            transitionFormat: 'MMM dd'
          )
        ),
      ),
      animate: true,
      // Set the default renderer to a bar renderer.
      // This can also be one of the custom renderers of the time series chart.
      defaultRenderer: charts.BarRendererConfig<DateTime>(),
      // It is recommended that default interactions be turned off if using bar
      // renderer, because the line point highlighter is the default for time
      // series chart.
      defaultInteractions: false,
      // If default interactions were removed, optionally add select nearest
      // and the domain highlighter that are typical for bar charts.
      behaviors: [charts.SelectNearest(), charts.DomainHighlighter()],
    );
  }

  static List<charts.Series<TimeSeriesStars, DateTime>> _generateTipsData() {
    Box<TipSelection> tipsBox = Hive.box<TipSelection>("tips");
    // Get the last date of the month that was 3 months ago
    DateTime monthIterator = DateTime(
        DateTime.now().year, DateTime.now().month - 2, 0);
    // The last date of the last month to check
    final lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    List<TimeSeriesStars> data = [];
    // Continue while month iterator is before (or at the same moment as) last date
    while (!monthIterator.isAfter(lastDate)) {
      // For each key that month, add a TimeSeriesStar datapoint to the data list
      tipsBox.getKeysForMonth(monthIterator, nullKeyForMissingWeeks: false).forEach((date, key) =>
          data.add(TimeSeriesStars(date, (key != "") ? tipsBox.get(key)!.totalPoints : 0)));
      // Get last date of next month
      monthIterator = DateTime(monthIterator.year, monthIterator.month + 2, 0);
    }

    return [
      charts.Series<TimeSeriesStars, DateTime>(
        id: 'Stars',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesStars point, _) => point.time,
        measureFn: (TimeSeriesStars point, _) => point.stars,
        data: data,
      )
    ];
  }
}

class TimeSeriesStars {
  final DateTime time;
  final int stars;

  TimeSeriesStars(this.time, this.stars);

  @override
  String toString() {
    return "TimeSeriesStars(time=$time, stars=$stars)";
  }
}
