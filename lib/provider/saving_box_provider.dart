import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/saving_box_model.dart';

class SavingBoxProvider with ChangeNotifier {
  List<SavingBox> _boxes = [];
  final String _storageKey = 'saving_boxes';

  List<SavingBox> get boxes => _boxes;

  SavingBoxProvider() {
    _loadBoxes();
  }

  Future<void> _loadBoxes() async {
    final prefs = await SharedPreferences.getInstance();
    final boxesJson = prefs.getStringList(_storageKey) ?? [];
    _boxes = boxesJson.map((json) => SavingBox.fromMap(jsonDecode(json))).toList();
    notifyListeners();
  }

  Future<void> _saveBoxes() async {
    final prefs = await SharedPreferences.getInstance();
    final boxesJson = _boxes.map((box) => jsonEncode(box.toMap())).toList();
    await prefs.setStringList(_storageKey, boxesJson);
  }

  Future<void> addBox(SavingBox box) async {
    _boxes.add(box);
    await _saveBoxes();
    notifyListeners();
  }

  Future<void> updateBox(SavingBox box) async {
    final index = _boxes.indexWhere((b) => b.id == box.id);
    if (index != -1) {
      _boxes[index] = box;
      await _saveBoxes();
      notifyListeners();
    }
  }

  Future<void> deleteBox(String id) async {
    _boxes.removeWhere((box) => box.id == id);
    await _saveBoxes();
    notifyListeners();
  }

  Future<void> addTransaction(String boxId, SavingBoxTransaction transaction) async {
    final box = _boxes.firstWhere((b) => b.id == boxId);
    box.transactions.add(transaction);
    box.currentBalance += transaction.isDeposit ? transaction.amount : -transaction.amount;
    await _saveBoxes();
    notifyListeners();
  }
}
