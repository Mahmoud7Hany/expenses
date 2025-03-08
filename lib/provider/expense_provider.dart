import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/add_Expense.dart';

// Home Page
// Provider
//  هي فئة تدير حالة التطبيق وتتعامل مع النفقات والميزانية`ExpenseProvider`
class ExpenseProvider extends ChangeNotifier {
  // المتغيرات لتخزين البيانات
  double totalBudget = 0; // إجمالي الميزانية المتاحة
  double expenses = 0; // إجمالي المصروفات الحالية
  double lastEnteredBudget = 0; // آخر قيمة تم إدخالها للرصيد
  
  List<Expense> expensesList = []; // قائمة النفقات
  late SharedPreferences _prefs; //SharedPreferences لتخزين واسترجاع البيانات من

  // المنشئ يقوم بتحميل البيانات عند إنشاء الكائن
  ExpenseProvider() {
    _loadData();
  }

  // SharedPreferences دالة غير متزامنة لتحميل البيانات من
  Future<void> _loadData() async {
    _prefs = await SharedPreferences
        .getInstance(); //SharedPreferences الحصول على كائن
    // تحميل القيم من SharedPreferences أو تعيينها إلى 0 إذا لم تكن موجودة
    totalBudget = _prefs.getDouble('totalBudget') ?? 0;
    expenses = _prefs.getDouble('expenses') ?? 0;
    lastEnteredBudget = _prefs.getDouble('lastEnteredBudget') ?? 0;

    // تحميل قائمة النفقات وتحويلها من JSON إلى قائمة كائنات Expense
    List<String>? expensesJsonList = _prefs.getStringList('expensesList');
    if (expensesJsonList != null) {
      expensesList = expensesJsonList.map((json) {
        Map<String, dynamic> expenseMap = jsonDecode(json);
        return Expense(expenseMap['name'], expenseMap['amount']);
      }).toList();
    }

    notifyListeners(); // إعلام جميع المستمعين بتغيير البيانات
  }

  // SharedPreferences دالة لحفظ البيانات في 
  void _saveData() {
    _prefs.setDouble('totalBudget', totalBudget);
    _prefs.setDouble('expenses', expenses);
    _prefs.setDouble('lastEnteredBudget', lastEnteredBudget);
  }

  // SharedPreferences دالة لحفظ قائمة النفقات في 
  void _saveExpensesList() {
    List<String> expensesJsonList = expensesList.map((expense) {
      return jsonEncode(expense.toJson()); // تحويل النفقات إلى JSON
    }).toList();
    _prefs.setStringList('expensesList', expensesJsonList);
  }

  // دالة لتحديث إجمالي المصروفات
  void updateExpenses(double value) {
    expenses = value;
    _saveData(); // حفظ البيانات المحدثة
    notifyListeners(); // إعلام المستمعين بالتحديث
  }

  // دالة لتحديث الميزانية وإدخال القيمة الأخيرة للرصيد
  void updateBudget(double value) {
    totalBudget += value; // إضافة القيمة إلى الميزانية الحالية
    lastEnteredBudget = value; // تحديث آخر قيمة تم إدخالها للرصيد
    _saveData(); // حفظ البيانات المحدثة
    notifyListeners(); // إعلام المستمعين بالتحديث
  }

  // دالة لإضافة مصروف جديد
  void addExpense(String name, double amount) {
    double newTotalExpenses = expenses + amount;

    // التحقق مما إذا كان المصروف لا يتجاوز الميزانية
    if (newTotalExpenses <= totalBudget) {
      expensesList.add(Expense(name, amount)); // إضافة المصروف إلى القائمة
      _saveExpensesList(); // حفظ قائمة النفقات المحدثة
      updateExpenses(newTotalExpenses); // تحديث إجمالي المصروفات
    } else {
      // معالجة حالة تجاوز الميزانية (يمكنك إضافة رسالة خطأ هنا)
    }
  }

  // دالة لحذف مصروف من القائمة
  void deleteExpense(int index) {
    Expense deletedExpense = expensesList.removeAt(index); // حذف المصروف
    updateExpenses(expenses - deletedExpense.amount); // تحديث إجمالي المصروفات
    _saveExpensesList(); // حفظ قائمة النفقات المحدثة
  }

  // دالة لمسح جميع البيانات
  void clearData() {
    totalBudget = 0; // إعادة تعيين الميزانية إلى 0
    expenses = 0; // إعادة تعيين المصروفات إلى 0
    lastEnteredBudget = 0; // إعادة تعيين آخر قيمة دخل إلى 0
    expensesList.clear(); // مسح قائمة النفقات
    _saveData(); // حفظ البيانات المحدثة
    _saveExpensesList(); // حفظ قائمة النفقات المحدثة
    notifyListeners(); // إعلام المستمعين بالتحديث
  }
}
