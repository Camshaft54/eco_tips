import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:carbon_tracker/settings/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'homepage.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DailySurveyAdapter());
  Hive.registerAdapter(TransportTypeAdapter());
  await Hive.openBox('daily');
  // Hive.deleteBoxFromDisk("transport");
  await Hive.openBox('transport');

  runApp(
    const MaterialApp(
      home: HomePage(),
    ),
  );
}

class Main {
  static var firstInstallDate = DateTime(2021, 12, 25);
}
