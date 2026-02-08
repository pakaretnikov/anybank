import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/bank.dart';
import 'bank_constants.dart';

class BankStorageService {
  static const String _storageKey = 'myBanks';

  Future<List<Bank>> loadBanks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null) {
        return List.from(initialBanks);
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Bank.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      return List.from(initialBanks);
    }
  }

  Future<void> saveBanks(List<Bank> banks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = banks.map((bank) => bank.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      // Handle error silently
    }
  }
}
