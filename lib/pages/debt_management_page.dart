// ignore_for_file: unused_element, deprecated_member_use, unused_local_variable

import 'package:expenses/models/Debt_data.dart';
import 'package:expenses/theme/app_theme.dart';
import 'package:expenses/widgets/elevated_button_widget.dart';
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
  // إضافة GlobalKey
  final GlobalKey _addEditCardKey = GlobalKey();
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
          backgroundColor:
              themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Colors.white,
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 28),
              SizedBox(width: 10),
              Text(
                'خطأ',
                style: TextStyle(
                  color:
                      themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          elevation: 24,
          actions: [
            Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
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
          lastEditTime: DateTime.now(), // إضافة وقت التعديل
        );
        // نقل العنصر المعدل إلى أعلى القائمة
        final editedDebt = _debts.removeAt(_editingIndex!);
        _debts.insert(0, editedDebt);
        _editingIndex = null;
      } else {
        _debts.insert(
          0,
          Debt(
            description: description,
            amount: amount,
            dueDate: _dueDate!,
            receiptDate: _receiptDate!,
          ),
        );
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
      message:
          _editingIndex != null
              ? 'تم تحديث الدين بنجاح'
              : 'تم إضافة الدين بنجاح',
      type: SnackBarType.success,
    );
  }

  // دالة مساعدة لتنسيق وقت التعديل
  String _formatLastEditTime(DateTime? lastEditTime) {
    if (lastEditTime == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final editDate = DateTime(lastEditTime.year, lastEditTime.month, lastEditTime.day);
    
    if (editDate == today) {
      // تحويل إلى نظام 12 ساعة
      int hour = lastEditTime.hour;
      final String period = hour >= 12 ? 'م' : 'ص';
      
      // تحويل الساعة إلى نظام 12
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      final String hourStr = hour.toString().padLeft(2, '0');
      final String minute = lastEditTime.minute.toString().padLeft(2, '0');
      return 'تم التعديل اليوم الساعة $hourStr:$minute $period';
    } else {
      final day = lastEditTime.day.toString().padLeft(2, '0');
      final month = lastEditTime.month.toString().padLeft(2, '0');
      final year = lastEditTime.year;
      
      // إضافة الوقت للتاريخ السابق أيضاً
      int hour = lastEditTime.hour;
      final String period = hour >= 12 ? 'م' : 'ص';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      final String hourStr = hour.toString().padLeft(2, '0');
      final String minute = lastEditTime.minute.toString().padLeft(2, '0');
      
      return 'تم التعديل في $day/$month/$year الساعة $hourStr:$minute $period';
    }
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
      _editingIndex = _debts.indexOf(debt);
      _isSearching = false;
      _searchQuery = '';
      _filterDebts();
    });
    
    // تحسين التمرير التلقائي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // التحقق من موقع البطاقة في الشاشة
      final RenderBox? cardBox = _addEditCardKey.currentContext?.findRenderObject() as RenderBox?;
      if (cardBox != null) {
        final cardPosition = cardBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;
        
        // إذا كانت البطاقة خارج نطاق الرؤية، قم بالتمرير
        if (cardPosition.dy < 0 || cardPosition.dy > screenHeight * 0.5) {
          Scrollable.ensureVisible(
            _addEditCardKey.currentContext!,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.0, // تمرير للأعلى تماماً
          );
        }
      }
    });
  }

  void _filterDebts() {
    setState(() {
      _filteredDebts.clear();
      // نضيف العناصر المفلترة بنفس الترتيب
      _filteredDebts.addAll(
        _debts.where(
          (debt) => debt.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
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
                    onPressed:
                        _toggleSearch, // استخدام دالة واحدة للتعامل مع كل الحالات
                  ),
                ],
              ),
            ),
        ],
        automaticallyImplyLeading:
            !_isSearching, // إخفاء زر الرجوع عند تفعيل البحث
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isSearching) ...[
                    Card(
                      key: _addEditCardKey, // إضافة المفتاح هنا
                      elevation: 12,
                      shadowColor: Colors.blue.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container( // تصحيح هنا
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFFFFA6C1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // عنوان البطاقة
                            Container(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _editingIndex != null
                                          ? Icons.edit_note
                                          : Icons.add_chart,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    _editingIndex != null
                                        ? 'تعديل الدين'
                                        : 'إضافة دين جديد',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // حقل الوصف
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _descriptionController,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'الوصف',
                                  labelStyle: TextStyle(color: Color(0xFF2193b0)),
                                  prefixIcon: Icon(
                                    Icons.description_outlined,
                                    color: Color(0xFF2193b0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                            // حقل المبلغ
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'المبلغ',
                                  labelStyle: TextStyle(color: Color(0xFF2193b0)),
                                  prefixIcon: Icon(
                                    Icons.attach_money,
                                    color: Color(0xFF2193b0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                              ),
                            ),
                            // أزرار التاريخ
                            Container(
                              margin: EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildAnimatedDateButton(
                                      label: 'تاريخ الاستلام',
                                      value: _receiptDate,
                                      onPressed: _selectReceiptDate,
                                      icon: Icons.calendar_today,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildAnimatedDateButton(
                                      label: 'تاريخ الدفع',
                                      value: _dueDate,
                                      onPressed: _selectDueDate,
                                      icon: Icons.event,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // زر الإضافة/التحديث
                            Container(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _addOrUpdateDebt,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _editingIndex != null
                                          ? Icons.edit
                                          : Icons.add_circle_outline,
                                      color: Color(0xFF2193b0),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      _editingIndex != null
                                          ? 'تحديث الدين'
                                          : 'إضافة دين',
                                      style: TextStyle(
                                        color: Color(0xFF2193b0),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // بطاقة الإجمالي
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Card(
                            elevation: 12,
                            shadowColor: Colors.purple.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                    spreadRadius:
                                        -2, // إضافة spreadRadius سالب للحصول على ظل أنعم
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.account_balance_wallet,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'إجمالي الديون',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          '${_filteredDebts.length} دين',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(
                                      begin: 0,
                                      end: _calculateTotalAmount(),
                                    ),
                                    duration: Duration(milliseconds: 1200),
                                    builder: (context, double value, child) {
                                      return Text(
                                        '${value.toStringAsFixed(2)} جنيه',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'المبلغ المستحق الدفع',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            // قائمة الديون (بدون Container محدد الارتفاع)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: List.generate(
                  _filteredDebts.length,
                  (index) => _buildDebtItem(_filteredDebts[index], index),
                ),
              ),
            ),
            SizedBox(height: 16.0), // مسافة في نهاية القائمة
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
                  style: TextStyle(fontSize: 13.0, color: Colors.white),
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

  // أضف هذه الدالة المساعدة للأزرار
  Widget _buildAnimatedDateButton({
    required String label,
    required DateTime? value,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Color(0xFF2193b0)),
                  SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Color(0xFF2193b0),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (value != null) ...[
                SizedBox(height: 4),
                Text(
                  value.toShortDateString(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // تعديل جزء عرض العنصر في القائمة
  Widget _buildDebtItem(Debt debt, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SlideFadeTransition(
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: Slidable(
        // ...existing Slidable code...
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
          child: Stack(
            children: [
              ListTile(
                // ...existing ListTile code...
                contentPadding: EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.payment, color: Colors.blue[900]),
                ),
                title: Text(
                  debt.description,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ...existing subtitle items...
                    SizedBox(height: 8),
                    _buildDebtInfoRow(
                      icon: Icons.attach_money,
                      text: 'المبلغ: ${debt.amount}',
                      themeProvider: themeProvider,
                    ),
                    SizedBox(height: 4),
                    _buildDebtInfoRow(
                      icon: Icons.calendar_today,
                      text: 'تاريخ الاستلام: ${debt.receiptDate.toLocal().toShortDateString()}',
                      themeProvider: themeProvider,
                    ),
                    SizedBox(height: 4),
                    _buildDebtInfoRow(
                      icon: Icons.event,
                      text: 'تاريخ الدفع: ${debt.dueDate.toLocal().toShortDateString()}',
                      themeProvider: themeProvider,
                    ),
                    if (debt.lastEditTime != null) ...[
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.edit_calendar,
                            size: 16,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatLastEditTime(debt.lastEditTime),
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (debt.lastEditTime != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      size: 16,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء صف معلومات الدين
  Widget _buildDebtInfoRow({
    required IconData icon,
    required String text,
    required ThemeProvider themeProvider,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
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
