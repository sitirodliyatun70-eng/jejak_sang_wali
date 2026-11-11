import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wali_model.dart';
import 'json_service.dart';

class StorageService {
  static int unlockedLevel = 1;
  static int totalStars = 0;
  static bool isAdmin = false;

  static List<WaliModel> waliList = [];
  static List<WaliModel> recentWali = [];

  static const String _waliKey = 'wali_data_list';
  static const String _recentKey = 'recent_wali_data_list';

  static Future<void> initData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedJson = prefs.getString(_waliKey);

      // 1. CEK ATAU LOAD DATA UTAMA WALI
      if (savedJson != null && savedJson.isNotEmpty) {
        final List decoded = jsonDecode(savedJson);
        waliList = decoded.map((e) => WaliModel.fromJson(e)).toList();
      } else {
        await _loadFromDefaultJson();
        await saveData();
      }

      // 2. LOAD DATA RECENT WALI TERKINI
      final String? savedRecentJson = prefs.getString(_recentKey);
      if (savedRecentJson != null && savedRecentJson.isNotEmpty) {
        final List recentDecoded = jsonDecode(savedRecentJson);
        final loadedRecent =
            recentDecoded.map((e) => WaliModel.fromJson(e)).toList();

        // Sinkronkan gambar & konten recent dengan waliList terbaru
        recentWali = loadedRecent.map((recentItem) {
          return waliList.firstWhere(
            (w) => w.id == recentItem.id,
            orElse: () => recentItem,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error saat memuat storage: $e');
      await _loadFromDefaultJson();
    }
  }

  static Future<void> _loadFromDefaultJson() async {
    try {
      final data = await JsonService.loadAppData();
      final List list = data['ebook'] ?? [];
      waliList = list.map((e) => WaliModel.fromJson(e)).toList();
    } catch (_) {
      waliList = [];
    }
  }

  static Future<bool> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(waliList.map((e) => e.toJson()).toList());
      return await prefs.setString(_waliKey, encoded);
    } catch (e) {
      debugPrint('Gagal menyimpan ke LocalStorage: $e');
      return false;
    }
  }

  static Future<void> _saveRecentToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded =
          jsonEncode(recentWali.map((e) => e.toJson()).toList());
      await prefs.setString(_recentKey, encoded);
    } catch (e) {
      debugPrint('Gagal menyimpan Recent: $e');
    }
  }

  static void addRecent(WaliModel wali) {
    // Ambil versi wali paling update dari waliList jika ada
    final currentWali = waliList.firstWhere(
      (item) => item.id == wali.id,
      orElse: () => wali,
    );

    recentWali.removeWhere((item) => item.id == currentWali.id);
    recentWali.insert(0, currentWali);

    if (recentWali.length > 5) {
      recentWali = recentWali.sublist(0, 5);
    }

    _saveRecentToStorage();
  }

  // METHOD BANTUAN UNTUK MANAJEMEN ADMIN (TAMBAH, EDIT, HAPUS)
  static Future<void> addWali(WaliModel wali) async {
    waliList.add(wali);
    await saveData();
  }

  static Future<void> updateWali(WaliModel wali) async {
    final index = waliList.indexWhere((element) => element.id == wali.id);
    if (index != -1) {
      waliList[index] = wali;

      // Update data di Recent jika ada
      final recentIndex =
          recentWali.indexWhere((element) => element.id == wali.id);
      if (recentIndex != -1) {
        recentWali[recentIndex] = wali;
        await _saveRecentToStorage();
      }

      await saveData();
    }
  }

  static Future<void> deleteWali(int id) async {
    waliList.removeWhere((element) => element.id == id);
    recentWali.removeWhere((element) => element.id == id);
    await saveData();
    await _saveRecentToStorage();
  }
}
