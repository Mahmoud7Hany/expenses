// ignore_for_file: unused_local_variable

import 'package:expenses/models/format_amount.dart';
import 'package:expenses/theme/app_theme.dart';
import 'package:expenses/widgets/appBar_widget.dart';
import 'package:expenses/widgets/balance_card_widget.dart';
import 'package:expenses/widgets/drawer_widget.dart';
import 'package:expenses/widgets/elevated_button_widget.dart';
import 'package:expenses/widgets/text_formField_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../provider/expense_provider.dart';
import '../animations/slide_fade_transition.dart';
import '../widgets/custom_snackbar.dart';

// Home Page
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // تعريف متغيرات التحكم
  late TextEditingController expensesController;
  late TextEditingController budgetController;
  late TextEditingController expensesNameController;
  
  // تعريف نقاط التركيز
  late FocusNode expensesFocusNode;
  late FocusNode budgetFocusNode;
  late FocusNode expensesNameFocusNode;

  // إضافة متغير لتتبع الحالة السابقة
  bool _previousBudgetState = false;

  @override
  void initState() {
    super.initState();
    // تهيئة المتغيرات
    expensesController = TextEditingController();
    budgetController = TextEditingController();
    expensesNameController = TextEditingController();
    
    // تهيئة نقاط التركيز
    expensesFocusNode = FocusNode();
    budgetFocusNode = FocusNode();
    expensesNameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // تنظيف الموارد
    expensesController.dispose();
    budgetController.dispose();
    expensesNameController.dispose();
    
    expensesFocusNode.dispose();
    budgetFocusNode.dispose();
    expensesNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          final themeProvider = Provider.of<ThemeProvider>(context); // إضافة هنا
          // متغير للتحكم في ظهور حقل الإدخال وزر التحديث
          bool isBudgetSet = expenseProvider.totalBudget > 0;
          // إضافة متغير للتحكم في إظهار/إخفاء الأرقام
          ValueNotifier<bool> isAmountVisible = ValueNotifier(true);

          // إضافة فحص للتغيير في الحالة
          if (isBudgetSet != _previousBudgetState) {
            _previousBudgetState = isBudgetSet;
            // إعادة تهيئة نقاط التركيز عند تغيير الحالة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              expensesNameFocusNode.unfocus();
              expensesFocusNode.unfocus();
              budgetFocusNode.unfocus();
            });
          }

          return Scaffold(
            appBar: CustomAppBar(
              textAppBar: 'المصاريف',
              showThemeIcon: true, // إظهار أيقونة الوضع الليلي والنهار في الصفحة الرئيسية فقط
              actions: [
                if (expenseProvider.expensesList.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      if (expenseProvider.expensesList.isNotEmpty) {
                        List<String> clipboardData = [];

                        // إعداد بيانات النسخ مع التحقق من الأرقام العشرية
                        for (var expense in expenseProvider.expensesList) {
                          if (expense.amount % 1 != 0) {
                            clipboardData.add(
                                '${expense.name} : ${expense.amount.toStringAsFixed(2)}');
                          } else {
                            clipboardData.add(
                                '${expense.name} : ${expense.amount.toInt()}');
                          }
                        }

                        // إضافة المجموع إلى البيانات
                        double expenses = expenseProvider.expenses;
                        if (expenses % 1 != 0) {
                          clipboardData
                              .add('المجموع : ${expenses.toStringAsFixed(2)}');
                        } else {
                          clipboardData.add('المجموع : ${expenses.toInt()}');
                        }

                        // حساب الرصيد المتبقي وإضافته إلى البيانات
                        double remaining =
                            expenseProvider.totalBudget - expenses;
                        if (remaining % 1 != 0) {
                          clipboardData
                              .add('باقي : ${remaining.toStringAsFixed(2)}');
                        } else {
                          clipboardData.add('باقي : ${remaining.toInt()}');
                        }

                        // نسخ البيانات إلى الحافظة
                        Clipboard.setData(
                            ClipboardData(text: clipboardData.join('\n')));

                        CustomSnackBar.show(
                          context: context,
                          message: 'تم نسخ البيانات إلى الحافظة',
                          type: SnackBarType.info,
                        );
                      } else {
                        CustomSnackBar.show(
                          context: context,
                          message: 'لا يوجد بيانات لنسخها',
                          type: SnackBarType.error,
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 24),
                    color: Colors.amber[600],
                  ),
                if (expenseProvider.expensesList.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final themeProvider = Provider.of<ThemeProvider>(context);
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
                                  Icons.warning_amber_rounded, 
                                  color: Colors.red[700],
                                  size: 28
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'تأكيد المسح',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.isDarkMode 
                                        ? Colors.white
                                        : Colors.black87,
                                  )
                                ),
                              ],
                            ),
                            content: Text(
                              'هل أنت متأكد أنك تريد مسح جميع البيانات؟',
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkMode 
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                            ),
                            elevation: 24,
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('إلغاء',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () {
                                  expenseProvider.clearData();
                                  Navigator.of(context).pop();
                                  isBudgetSet = false;
                                },
                                child: Text('مسح',
                                    style: TextStyle(color: Colors.white)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.red),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever, size: 26),
                    color: Colors.red,
                  ),
              ],
            ),
            drawer: const DrawerWidget(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: BalanceCardWidget(
                      icon: Icons.remove_red_eye,
                      hiddenIcon: Icons.remove_red_eye_outlined,
                      isVisible: expenseProvider.isAmountVisible,
                      onVisibilityChanged: () {
                        expenseProvider.toggleAmountVisibility();
                      },
                      totalBalance: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 800), // تسريع التأثير
                        curve: Curves.easeOutCubic, // إضافة حركة سلسة واحترافية
                        tween: Tween<double>(
                          begin: 0,
                          end: (expenseProvider.totalBudget - expenseProvider.expenses).roundToDouble(),
                        ),
                        builder: (context, value, _) => 
                          Text(
                            expenseProvider.isAmountVisible 
                              ? formatAmount(value)
                              : '* * * * *',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ),
                      expenses: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: expenseProvider.expenses.roundToDouble(),
                        ),
                        builder: (context, value, _) => 
                          Text(
                            expenseProvider.isAmountVisible 
                              ? formatAmount(value)
                              : '* * * * *',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withAlpha(204), // Replace withOpacity(0.8)
                            ),
                          ),
                      ),
                      income: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        tween: Tween<double>(
                          begin: 0,
                          end: expenseProvider.lastEnteredBudget.roundToDouble(),
                        ),
                        builder: (context, value, _) => 
                          Text(
                            expenseProvider.isAmountVisible 
                              ? formatAmount(value)
                              : '* * * * *',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withAlpha(204), // Replace withOpacity(0.8)
                            ),
                          ),
                      ),
                      totalBalanceLabel: 'إجمالي الرصيد',
                      expensesLabel: 'مصروف',
                      incomeLabel: 'دخل',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        
                        // إظهار حقل "اسم المصروف" و"مبلغ المصروف" وزر "أضف المصروف" فقط إذا تم تعيين الميزانية
                        if (isBudgetSet) ...[
                          TextFormField(
                            controller: expensesNameController,
                            focusNode: expensesNameFocusNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            enabled: (expenseProvider.totalBudget - expenseProvider.expenses) > 0,
                            onTap: () => expensesNameFocusNode.requestFocus(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: "اسم المصروف",
                              labelStyle: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.text_fields,
                                color: themeProvider.isDarkMode ? Colors.blue[400] : Colors.blue[700],
                              ),
                              filled: true,
                              fillColor: themeProvider.isDarkMode ? Color(0xFF2D2D2D) : Colors.grey[50],
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: themeProvider.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: themeProvider.isDarkMode ? Colors.blue[400]! : Colors.blue[700]!,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormFieldWidget(
                            controller: expensesController,
                            focusNode: expensesFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            labelText: 'مبلغ المصروف',
                            enabled: (expenseProvider.totalBudget - expenseProvider.expenses) > 0,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButtonWidget(
                            onPressed: (expenseProvider.totalBudget - expenseProvider.expenses) > 0
                                ? () {
                                    // التحقق من أن الحقول غير فارغة
                                    if (expensesController.text.isEmpty || expensesNameController.text.isEmpty) {
                                      CustomSnackBar.show(
                                        context: context,
                                        message: 'يجب ملء جميع الحقول',
                                        type: SnackBarType.error,
                                      );
                                      return;
                                    }

                                    // التحقق من صحة القيمة المدخلة
                                    double? amount;
                                    try {
                                      amount = double.parse(expensesController.text);
                                      if (amount <= 0) {
                                        CustomSnackBar.show(
                                          context: context,
                                          message: 'الرجاء إدخال قيمة موجبة',
                                          type: SnackBarType.error,
                                        );
                                        expensesController.clear();
                                        return;
                                      }
                                    } catch (e) {
                                      CustomSnackBar.show(
                                        context: context,
                                        message: 'الرجاء إدخال قيمة صحيحة',
                                        type: SnackBarType.error,
                                      );
                                      expensesController.clear();
                                      return;
                                    }

                                    // التحقق من الرصيد المتاح
                                    double remainingBalance = expenseProvider.totalBudget - expenseProvider.expenses;
                                    if (amount > remainingBalance) {
                                      CustomSnackBar.show(
                                        context: context,
                                        message: 'المبلغ يتجاوز الرصيد المتاح (${formatAmount(remainingBalance)})',
                                        type: SnackBarType.warning,
                                      );
                                      return;
                                    }

                                    // إضافة المصروف إذا تم اجتياز جميع الفحوصات
                                    String name = expensesNameController.text;
                                    expenseProvider.addExpense(name, amount);
                                    expensesController.clear();
                                    expensesNameController.clear();

                                    // عرض رسالة نجاح
                                    CustomSnackBar.show(
                                      context: context,
                                      message: 'تم إضافة المصروف بنجاح',
                                      type: SnackBarType.success,
                                      showTitle: false,
                                    );
                                  }
                                : () => _showInsufficientBalanceDialog(context),
                            buttonText: 'أضف المصروف',
                            color: (expenseProvider.totalBudget - expenseProvider.expenses) > 0
                                ? null
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 10),
                        ],
                        // إظهار حقل الإدخال وزر التحديث فقط إذا لم يتم تعيين الميزانية
                        if (!isBudgetSet) ...[
                          TextFormFieldWidget(
                            controller: budgetController,
                            focusNode: budgetFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            labelText: 'أدخل الرصيد الإجمالي',
                          ),
                          const SizedBox(height: 10),
                          ElevatedButtonWidget(
                            onPressed: () {
                              if (budgetController.text.isEmpty) {
                                CustomSnackBar.show(
                                  context: context,
                                  message: 'يجب إدخال قيمة الرصيد أولاً',
                                  type: SnackBarType.error,
                                );
                                return;
                              }

                              try {
                                double value = double.parse(budgetController.text);
                                expenseProvider.updateBudget(value);
                                budgetController.clear();
                                isBudgetSet = true;
                              } catch (e) {
                                CustomSnackBar.show(
                                  context: context,
                                  message: 'الرجاء إدخال رقم صحيح',
                                  type: SnackBarType.error,
                                );
                              }
                            },
                            buttonText: 'إضافة الرصيد',
                          ),
                        ],
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  if (expenseProvider.expensesList.isNotEmpty)
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ...expenseProvider.expensesList.asMap().entries.map((entry) {
                    final expense = entry.value;
                    final index = entry.key;
                    final themeProvider = Provider.of<ThemeProvider>(context);
                    
                    return SlideFadeTransition(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                expenseProvider.deleteExpense(expenseProvider
                                    .expensesList
                                    .indexOf(expense));
                              },
                              backgroundColor: Colors.red,
                              icon: Icons.delete,
                              label: 'حذف',
                            )
                          ],
                        ),
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            title: Text(
                              expense.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatAmount(expense.amount),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(expense.dateTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: themeProvider.isDarkMode ? Colors.white60 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode ? Colors.blue[900] : Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.blue[900],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // إضافة دالة لتنسيق التاريخ والوقت
  String _formatDateTime(DateTime dateTime) {
    final period = dateTime.hour >= 12 ? 'م' : 'ص';
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    
    return '$hour:$minute $period - $day/$month/${dateTime.year}';
  }

  // إضافة دالة جديدة لعرض رسالة عندما يكون الرصيد غير كافي
  void _showInsufficientBalanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.white,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: Colors.amber,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'الرصيد غير كافي',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'لا يمكن إضافة مصروفات جديدة حتى يتم إضافة رصيد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
