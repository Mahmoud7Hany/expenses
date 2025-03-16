import 'package:flutter/foundation.dart';
import '../models/sadaqah_model.dart';

class SadaqahProvider with ChangeNotifier {
  List<SadaqahModel> _sadaqahHistory = [];
  
  List<SadaqahModel> get sadaqahHistory => _sadaqahHistory;

  void addSadaqah(SadaqahModel sadaqah) {
    _sadaqahHistory.add(sadaqah);
    notifyListeners();
  }

  double calculateSadaqah(double amount, double percentage) {
    return (amount * percentage) / 100;
  }
}
