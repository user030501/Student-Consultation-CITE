import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// LocalDataProvider loads local JSON assets for the dashboard.
class LocalDataProvider {
  final String assetPath;

  LocalDataProvider({this.assetPath = 'assets/sample_dashboard_data.json'});

  Future<Map<String, dynamic>> load() async {
    final jsonString = await rootBundle.loadString(assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data;
  }
}
