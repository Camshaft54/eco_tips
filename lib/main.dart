import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:carbon_tracker/settings/transport_type.dart';
import 'package:carbon_tracker/tips/tip_loader.dart';
import 'package:carbon_tracker/tips/tip_selection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'homepage.dart';

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DailySurveyAdapter());
  Hive.registerAdapter(TransportTypeAdapter());
  Hive.registerAdapter(TipSelectionAdapter());
  await Hive.openBox('daily');
  await Hive.openBox('transport');
  await Hive.openBox('tips');
  // Load tips from file
  TipLoader();

  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      }
    ),
  );
}

class Main {
  static var firstInstallDate = DateTime(2021, 12, 25);
}
