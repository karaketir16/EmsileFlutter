import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

class EmsileRepository {
  const EmsileRepository._();

  static Future<AppData> load() async {
    final rawJson = await rootBundle.loadString('assets/data/emsile_seed.json');
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    return AppData.fromJson(decoded);
  }
}
