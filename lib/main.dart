import 'package:app_install_date/app_install_date_imp.dart';
import 'package:eco_tips/daily_survey/daily_survey.dart';
import 'package:eco_tips/settings/transport_type.dart';
import 'package:eco_tips/tips/tip_loader.dart';
import 'package:eco_tips/tips/tip_selection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'homepage.dart';

Future<void> main() async {
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DailySurveyAdapter());
  Hive.registerAdapter(TransportTypeAdapter());
  Hive.registerAdapter(TipSelectionAdapter());
  await Hive.openBox<DailySurvey>('daily');
  await Hive.openBox<TransportType>('transport');
  await Hive.openBox<TipSelection>('tips');
  Main.firstInstallDate.then((date) => print(date));
  // Load tips from file
  TipLoader();
  runApp(
    MaterialApp(initialRoute: '/', routes: {
      '/': (context) => const HomePage(),
    }),
  );
}

class Main {
  static Future<DateTime> firstInstallDate = getFirstInstallDate();

  static Future<DateTime> getFirstInstallDate() async {
    try {
      return AppInstallDate().installDate;
    } catch (e, st) {
      debugPrint("$e $st");
      return DateTime(2022, 10, 15);
    }
  }
}