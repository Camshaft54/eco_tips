import 'dart:convert';

import 'package:flutter/services.dart';

class TipLoader {
  static late Future<Map<String, Tip>> allTipsFuture;

  TipLoader() {
    allTipsFuture = loadTips();
  }

  Future<Map<String, Tip>> loadTips() async {
    var json = jsonDecode(
            await rootBundle.loadString('assets/tips.json'))
        as List<dynamic>;

    var tipsList = json.map((tip) {
      var tipMap = tip as Map<String, dynamic>;
      return Tip((tipMap["id"] as int).toString(), tipMap["name"] as String,
          tipMap["description"] as String, tipMap["difficulty"] as int);
    }).toList();

    var tipsMap = {for (var tip in tipsList) tip.id: tip};
    return tipsMap;
  }
}

class Tip {
  String id;
  String name;
  String description;
  int difficulty;

  Tip(this.id, this.name, this.description, this.difficulty);
}
