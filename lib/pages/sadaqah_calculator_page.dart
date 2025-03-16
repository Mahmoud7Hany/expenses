// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../provider/sadaqah_provider.dart';
import '../models/sadaqah_model.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_snackbar.dart';

class SadaqahCalculatorPage extends StatefulWidget {
  const SadaqahCalculatorPage({Key? key}) : super(key: key);

  @override
  State<SadaqahCalculatorPage> createState() => _SadaqahCalculatorPageState();
}

class _SadaqahCalculatorPageState extends State<SadaqahCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _customPercentageController = TextEditingController();
  double _selectedPercentage = 2.5;
  final List<double> _percentageOptions = [2.5, 5.0, 10.0];
  bool _isCustomPercentage = false;

  // تحديث قائمة الأذكار مع إضافة المزيد من العبارات التشجيعية
  final List<String> _sadaqahQuotes = [
    'صدقة المال تطهر المال وتزكيه',
    'الصدقة تطفئ غضب الرب وتدفع ميتة السوء',
    'ما نقص مال من صدقة',
    'الصدقة برهان',
    'سبعة يظلهم الله في ظله منهم رجل تصدق بصدقة فأخفاها',
    'داووا مرضاكم بالصدقة',
    'تصدقوا ولو بشق تمرة',
    'اتقوا النار ولو بشق تمرة',
    'الصدقة تقي مصارع السوء',
    'كل معروف صدقة',
    'الصدقة تظل صاحبها يوم القيامة',
    'الصدقة تطفئ الخطيئة كما يطفئ الماء النار',
    'سبعة يظلهم الله في ظله منهم رجل تصدق بصدقة فأخفاها',
  ];

  // تحديث دالة اختيار الذكر العشوائي
  String _getRandomQuote() {
    final random =
        DateTime.now().millisecondsSinceEpoch % _sadaqahQuotes.length;
    return _sadaqahQuotes[random];
  }

  // تخزين الذكر الحالي
  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _getRandomQuote();
  }

  @override
  void dispose() {
    _customPercentageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة الصدقة'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeProvider.cardGradientStart,
                themeProvider.cardGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]!
                  : Colors.grey[900]!,
              Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // بطاقة معلومات الصدقة
                  Card(
                    elevation: 8,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? null
                            : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeProvider.cardGradientStart.withOpacity(0.7),
                            themeProvider.cardGradientEnd.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.volunteer_activism,
                            size: 48,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'الصدقة باب من أبواب الخير',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // حقل إدخال المبلغ
                  Card(
                    elevation: 4,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'المبلغ الإجمالي',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[50]
                                  : Colors.grey[700],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال المبلغ';
                          }
                          try {
                            final number = double.parse(value);
                            if (number <= 0) {
                              return 'الرجاء إدخال مبلغ أكبر من صفر';
                            }
                          } catch (e) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                        // تنسيق النص أثناء الكتابة
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // اختيار النسبة
                  Card(
                    elevation: 4,
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'نسبة الصدقة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ..._percentageOptions.map((percentage) {
                                return ChoiceChip(
                                  label: Text('$percentage%'),
                                  selected:
                                      !_isCustomPercentage &&
                                      _selectedPercentage == percentage,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _isCustomPercentage = false;
                                        _selectedPercentage = percentage;
                                        _customPercentageController.clear();
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                              ChoiceChip(
                                label: const Text('تحديد نسبة أخرى'),
                                selected: _isCustomPercentage,
                                onSelected: (selected) {
                                  setState(() {
                                    _isCustomPercentage = selected;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_isCustomPercentage) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customPercentageController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'أدخل النسبة المئوية',
                                suffixText: '%',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey[50]
                                        : Colors.grey[700],
                              ),
                              validator: (value) {
                                if (_isCustomPercentage) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال النسبة';
                                  }
                                  try {
                                    final percentage = double.parse(value);
                                    if (percentage <= 0 || percentage > 100) {
                                      return 'الرجاء إدخال نسبة بين 0 و 100';
                                    }
                                  } catch (e) {
                                    return 'الرجاء إدخال رقم صحيح';
                                  }
                                }
                                return null;
                              },
                              // تنسيق النص أثناء الكتابة
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  try {
                                    final percentage = double.parse(value);
                                    if (percentage > 0 && percentage <= 100) {
                                      setState(() {
                                        _selectedPercentage = percentage;
                                      });
                                    }
                                  } catch (e) {
                                    // تجاهل القيم غير الصالحة
                                  }
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // زر الحساب
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors:
                            Theme.of(context).brightness == Brightness.light
                                ? [
                                  themeProvider.cardGradientStart,
                                  themeProvider.cardGradientEnd,
                                ]
                                : [Colors.teal[700]!, Colors.teal[900]!],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _calculateSadaqah,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calculate_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'احسب الصدقة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _calculateSadaqah() {
    if (_isCustomPercentage && _customPercentageController.text.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'الرجاء إدخال النسبة المئوية',
        type: SnackBarType.warning,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      CustomSnackBar.show(
        context: context,
        message: 'الرجاء التأكد من صحة البيانات المدخلة',
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      final provider = Provider.of<SadaqahProvider>(context, listen: false);

      final percentage =
          _isCustomPercentage
              ? double.parse(_customPercentageController.text)
              : _selectedPercentage;

      final sadaqahAmount = provider.calculateSadaqah(amount, percentage);

      final sadaqah = SadaqahModel(
        totalAmount: amount,
        percentage: percentage,
        sadaqahAmount: sadaqahAmount,
        date: DateTime.now(),
      );

      provider.addSadaqah(sadaqah);

      // CustomSnackBar.show(
      //   context: context,
      //   message: 'تم حساب الصدقة بنجاح',
      //   type: SnackBarType.success,
      // );

      setState(() {
        _currentQuote = _getRandomQuote();
      });

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder:
            (context) => Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey[850],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.volunteer_activism,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نتيجة حساب الصدقة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ResultCard(
                    title: 'المبلغ الإجمالي',
                    value: amount.toStringAsFixed(2),
                    icon: Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 8),
                  ResultCard(
                    title: 'مبلغ الصدقة',
                    value: sadaqahAmount.toStringAsFixed(2),
                    icon: Icons.favorite,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  ResultCard(
                    title: 'المبلغ المتبقي',
                    value: (amount - sadaqahAmount).toStringAsFixed(2),
                    icon: Icons.account_balance,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuote, // استخدام الذكر المخزن
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.teal,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
      );
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: 'حدث خطأ في حساب الصدقة',
        type: SnackBarType.error,
      );
    }
  }
}

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const ResultCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color:
          Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
