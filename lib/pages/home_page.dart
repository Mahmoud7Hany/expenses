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
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController expensesController = TextEditingController();
    TextEditingController budgetController = TextEditingController();
    TextEditingController expensesNameController = TextEditingController();

    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider(),
      child: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // متغير للتحكم في ظهور حقل الإدخال وزر التحديث
          bool isBudgetSet = expenseProvider.totalBudget > 0;

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
                      totalBalance:
                          '${formatAmount(expenseProvider.totalBudget - expenseProvider.expenses)}',
                      expenses: '${formatAmount(expenseProvider.expenses)}',
                      income: '${expenseProvider.lastEnteredBudget} جنيه',
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
                          TextFormFieldWidget(
                            controller: expensesNameController,
                            labelText: 'اسم المصروف',
                          ),
                          const SizedBox(height: 10),
                          TextFormFieldWidget(
                            controller: expensesController,
                            keyboardType: TextInputType.number,
                            labelText: 'مبلغ المصروف',
                          ),
                          const SizedBox(height: 10),
                          ElevatedButtonWidget(
                            onPressed: () {
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
                                  throw FormatException();
                                }
                              } catch (e) {
                                CustomSnackBar.show(
                                  context: context,
                                  message: 'الرجاء إدخال قيمة صحيحة وموجبة',
                                  type: SnackBarType.error,
                                );
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
                            },
                            buttonText: 'أضف المصروف',
                          ),
                          const SizedBox(height: 10),
                        ],
                        // إظهار حقل الإدخال وزر التحديث فقط إذا لم يتم تعيين الميزانية
                        if (!isBudgetSet) ...[
                          TextFormFieldWidget(
                            controller: budgetController,
                            keyboardType: TextInputType.number,
                            labelText: 'أدخل الرصيد الإجمالي',
                          ),
                          const SizedBox(height: 10),
                          ElevatedButtonWidget(
                            onPressed: () {
                              if (budgetController.text.isNotEmpty) {
                                double budget =
                                    double.parse(budgetController.text);
                                expenseProvider.updateBudget(budget);
                                budgetController.clear();
                                // إخفاء حقل الإدخال وزر التحديث بعد تعيين الميزانية
                                isBudgetSet = true;
                              } else {
                                CustomSnackBar.show(
                                  context: context,
                                  message: 'يجب إدخال قيمة الرصيد أولاً',
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
                            subtitle: Text(
                              formatAmount(expense.amount),
                              style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkMode ? Colors.white70 : Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
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
}
