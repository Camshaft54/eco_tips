import 'dart:math';

import 'package:carbon_tracker/daily_survey/daily_survey.dart';
import 'package:carbon_tracker/settings/transport_type.dart';
import 'package:carbon_tracker/tips/tip_loader.dart';
import 'package:carbon_tracker/tips/tip_selection.dart';
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
  // Load tips from file
  TipLoader();

  runApp(
  MaterialApp(
  initialRoute: '/',
  routes: {
  '/': (context) => const HomePage(),
  }
  )
  ,
  );
}

class Main {
  static var firstInstallDate = DateTime(2021, 12, 25);
}

void generateTipData(Box<TipSelection> box) {
  var dateIterator = DateTime(2022, 8, 22);
  final rand = Random();
  for (int i = 0; i < 12; i++) {
    dateIterator = dateIterator.add(const Duration(days: 7));
    var tipSelection = TipSelection(["0", "1", "2"]);
    tipSelection.totalPoints = rand.nextInt(10);
    box.put(dateIterator.millisecondsSinceEpoch.toString(), tipSelection);
  }
}
