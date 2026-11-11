import 'dart:convert';
import 'package:flutter/services.dart';

class JsonService {
  static Future<Map<String, dynamic>> loadAppData() async {
    final String response =
        await rootBundle.loadString('assets/data/wali_data.json');
    return json.decode(response);
  }
}
