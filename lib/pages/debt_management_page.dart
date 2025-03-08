// ignore_for_file: unused_element, deprecated_member_use

import 'package:expenses/models/Debt_data.dart';
import 'package:expenses/theme/app_theme.dart';
import 'package:expenses/widgets/elevated_button_widget.dart';
import 'package:expenses/widgets/text_formField_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON
import 'package:expenses/widgets/appBar_widget.dart';
import '../animations/slide_fade_transition.dart';
import '../widgets/custom_snackbar.dart';

// صفحة إدارة الديون
class DebtManagementPage extends StatefulWidget {
  @override
  _DebtManagementPageState createState() => _DebtManagementPageState();
}

class _DebtManagementPageState extends State<DebtManagementPage> {
  final List<Debt> _debts = [];
  final List<Debt> _filteredDebts = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _dueDate;
  DateTime? _receiptDate;
  int? _editingIndex;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtList = prefs.getStringList('debts') ?? [];
    setState(() {
      _debts.clear();
      _filteredDebts.clear();
      for (var debtString in debtList) {
        final debtMap = jsonDecode(debtString) as Map<String, dynamic>;
        _debts.add(Debt.fromMap(debtMap));
      }
      _filterDebts();
    });
  }

  Future<void> _saveDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtList = _debts.map((debt) => jsonEncode(debt.toMap())).toList();
    await prefs.setStringList('debts', debtList);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) {
        final themeProvider = Provider.of<ThemeProvider>(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: themeProvider.isDarkMode 
              ? Color(0xFF2D2D2D)
              : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red[700],
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'خطأ',
                style: TextStyle(
                  color: themeProvider.isDarkMode 
                      ? Colors.white 
                      : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode 
                  ? Colors.white70 
                  : Colors.black87,
            ),
          ),
          elevation: 24,
          actions: [
            Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[700]!,
                    Colors.blue[500]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'موافق',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addOrUpdateDebt() {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text);

    if (description.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'يرجى إدخال الوصف',
        type: SnackBarType.error,
      );
      return;
    }

    if (amount == null || amount <= 0) {
      CustomSnackBar.show(
        context: context,
        message: 'يرجى إدخال مبلغ أكبر من 0',
        type: SnackBarType.error,
      );
      return;
    }
    if (_receiptDate == null) {
      CustomSnackBar.show(
        context: context,
        message: 'يرجى اختيار تاريخ الاستلام',
        type: SnackBarType.error,
      );
      return;
    }
    if (_dueDate == null) {
      CustomSnackBar.show(
        context: context,
        message: 'يرجى اختيار تاريخ الدفع',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() {
      if (_editingIndex != null) {
        _debts[_editingIndex!] = Debt(
          description: description,
          amount: amount,
          dueDate: _dueDate!,
          receiptDate: _receiptDate!,
        );
        _editingIndex = null;
      } else {
        _debts.add(Debt(
          description: description,
          amount: amount,
          dueDate: _dueDate!,
          receiptDate: _receiptDate!,
        ));
      }
      _descriptionController.clear();
      _amountController.clear();
      _dueDate = null;
      _receiptDate = null;
      _filterDebts();
    });
    _saveDebts();
    CustomSnackBar.show(
      context: context,
      message: _editingIndex != null ? 'تم تحديث الدين بنجاح' : 'تم إضافة الدين بنجاح',
      type: SnackBarType.success,
    );
  }

  void _selectDueDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _dueDate) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  void _selectReceiptDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != _receiptDate) {
      setState(() {
        _receiptDate = selectedDate;
      });
    }
  }

  void _deleteDebt(int index) {
    setState(() {
      _debts.removeAt(index);
      _filterDebts();
    });
    _saveDebts();
  }

  void _editDebt(int index) {
    final debt = _filteredDebts[index];
    _descriptionController.text = debt.description;
    _amountController.text = debt.amount.toString();
    _dueDate = debt.dueDate;
    _receiptDate = debt.receiptDate;
    setState(() {
      _editingIndex = _debts.indexOf(debt); // Update the editing index
      _isSearching = false; // Exit search mode
      _searchQuery = ''; // Clear search query
      _filterDebts(); // Update the filtered debts list
    });
  }

  void _filterDebts() {
    setState(() {
      _filteredDebts.clear();
      _filteredDebts.addAll(
        _debts.where(
          (debt) => debt.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()),
        ),
      );
    });
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterDebts();
    });
  }

  // تحديث الدالة لمسح محتوى حقل البحث
  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filterDebts();
    });
  }

  // تحديث الدالة للتبديل بين حالة البحث
  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        // إذا كنا في وضع البحث، نتحقق من وجود نص
        if (_searchQuery.isNotEmpty) {
          _searchQuery = ''; // مسح النص
          _filterDebts();
        } else {
          _isSearching = false; // إغلاق البحث
        }
      } else {
        _isSearching = true; // تفعيل البحث
      }
    });
  }

  double _calculateTotalAmount() {
    return _filteredDebts.fold(0.0, (sum, debt) => sum + debt.amount);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        textAppBar: _isSearching ? '' : 'إدارة الديون',
        actions: [
          // عرض أيقونة البحث عندما لا يكون البحث نشطاً
          if (!_isSearching) ...[
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              onPressed: _toggleSearch,
            ),
          ],
          // عرض حقل البحث وزر الإغلاق عندما يكون البحث نشطاً
          if (_isSearching)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: 'بحث...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.white70),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: _onSearchQueryChanged,
                      controller: TextEditingController(text: _searchQuery),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.white,
                    onPressed: _toggleSearch, // استخدام دالة واحدة للتعامل مع كل الحالات
                  ),
                ],
              ),
            ),
        ],
        automaticallyImplyLeading: !_isSearching, // إخفاء زر الرجوع عند تفعيل البحث
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isSearching) ...[
              // بطاقة إضافة دين جديد
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        themeProvider.cardGradientStart,
                        themeProvider.cardGradientEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      TextFormFieldWidget(
                        controller: _descriptionController,
                        labelText: 'الوصف',
                        prefixIcon: Icons.description_outlined,
                      ),
                      SizedBox(height: 16.0),
                      TextFormFieldWidget(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        labelText: 'المبلغ',
                        prefixIcon: Icons.attach_money,
                      ),
                      SizedBox(height: 16.0),
                      // حقول التاريخ
                      _buildDateRow(
                        label: _receiptDate != null
                            ? 'تاريخ الاستلام: ${_receiptDate!.toLocal().toShortDateString()}'
                            : 'تاريخ الاستلام',
                        onPressed: _selectReceiptDate,
                        buttonText: 'تاريخ الاستلام',
                        icon: Icons.calendar_today,
                      ),
                      SizedBox(height: 16.0),
                      _buildDateRow(
                        label: _dueDate != null
                            ? 'تاريخ الدفع: ${_dueDate!.toLocal().toShortDateString()}'
                            : 'تاريخ الدفع',
                        onPressed: _selectDueDate,
                        buttonText: 'تاريخ الدفع',
                        icon: Icons.event,
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButtonWidget(
                        onPressed: _addOrUpdateDebt,
                        buttonText: _editingIndex != null ? 'تحديث الدين' : 'إضافة دين',
                        icon: _editingIndex != null ? Icons.edit : Icons.add_circle_outline,
                        color: Colors.green[600],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // بطاقة الإجمالي
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[700]!,
                        Colors.purple[500]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'الإجمالي:',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_calculateTotalAmount().toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 16.0),
            // قائمة الديون
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDebts.length,
                itemBuilder: (ctx, index) {
                  final debt = _filteredDebts[index];
                  return SlideFadeTransition(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: 'تعديل',
                            onPressed: (context) => _editDebt(index),
                          ),
                          SlidableAction(
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'حذف',
                            onPressed: (context) => _deleteDebt(index),
                          ),
                        ],
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Icon(Icons.payment, color: Colors.blue[900]),
                          ),
                          title: Text(
                            debt.description,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.attach_money, size: 16, 
                                       color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'المبلغ: ${debt.amount}',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16,
                                       color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'تاريخ الاستلام: ${debt.receiptDate.toLocal().toShortDateString()}',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.event, size: 16,
                                       color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    'تاريخ الدفع: ${debt.dueDate.toLocal().toShortDateString()}',
                                    style: TextStyle(
                                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// خاص باضافه تاريخ 
  Widget _buildDateRow({
    required String label,
    required VoidCallback onPressed,
    required String buttonText,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: Colors.white70, size: 17),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.0),
        ElevatedButtonWidget(
          onPressed: onPressed,
          buttonText: buttonText,
          icon: icon,
          color: Colors.blue[700],
        ),
      ],
    );
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
