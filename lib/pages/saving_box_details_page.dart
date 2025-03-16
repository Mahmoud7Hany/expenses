// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // إضافة مكتبة تنسيق التاريخ
import '../provider/saving_box_provider.dart';
import '../models/saving_box_model.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/appBar_widget.dart';
import 'saving_boxes_page.dart';

// صفحة عرض الصناديق
class SavingBoxDetailsPage extends StatelessWidget {
  final String boxId;

  const SavingBoxDetailsPage({Key? key, required this.boxId}) : super(key: key);

  void _showTransactionDialog(BuildContext context, bool isDeposit, SavingBox box) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: isDeposit ? 'إيداع' : 'سحب',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation1, curve: Curves.easeInOutCubic),
          child: FadeTransition(
            opacity: animation1,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (isDeposit ? Colors.green : Colors.red).withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDeposit 
                                  ? [Colors.green.shade400, Colors.green.shade600]
                                  : [Colors.red.shade400, Colors.red.shade600],
                              ),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isDeposit ? Icons.add_circle : Icons.remove_circle,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    isDeposit ? 'إيداع مبلغ' : 'سحب مبلغ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Form Content
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  // Amount Field
                                  TextFormField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'المبلغ',
                                      labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                      prefixIcon: Icon(
                                        Icons.attach_money,
                                        color: isDeposit ? Colors.green : Colors.red,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: isDeposit ? Colors.green : Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                                    ),
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) return 'الرجاء إدخال المبلغ';
                                      final amount = double.tryParse(value!);
                                      if (amount == null) return 'الرجاء إدخال رقم صحيح';
                                      if (amount <= 0) return 'المبلغ يجب أن يكون أكبر من 0';
                                      if (!isDeposit && amount > box.currentBalance) {
                                        return 'المبلغ المتاح للسحب ${box.currentBalance}';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  // Notes Field
                                  TextFormField(
                                    controller: noteController,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'ملاحظات (اختياري)',
                                      labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                      prefixIcon: Icon(
                                        Icons.note_alt_outlined,
                                        color: theme.iconTheme.color,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      filled: true,
                                      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Actions
                          Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.surface,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'إلغاء',
                                      style: TextStyle(
                                        color: theme.textTheme.bodyLarge?.color,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState?.validate() ?? false) {
                                        final amount = double.parse(amountController.text);
                                        final provider = context.read<SavingBoxProvider>();
                                        
                                        final transaction = SavingBoxTransaction(
                                          amount: amount,
                                          date: DateTime.now(),
                                          isDeposit: isDeposit,
                                          note: noteController.text,
                                        );

                                        provider.addTransaction(box.id, transaction);
                                        Navigator.pop(context);

                                        CustomSnackBar.show(
                                          context: context,
                                          message: 'تم ${isDeposit ? 'الإيداع' : 'السحب'} بنجاح',
                                          type: isDeposit ? SnackBarType.success : SnackBarType.error,
                                          showTitle: false,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDeposit ? Colors.green : Colors.red,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'تأكيد',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStatisticsDialog(BuildContext context, SavingBox box) {
    final theme = Theme.of(context);
    final totalDeposits = box.transactions
        .where((t) => t.isDeposit)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalWithdrawals = box.transactions
        .where((t) => !t.isDeposit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final depositCount = box.transactions.where((t) => t.isDeposit).length;
    final withdrawalCount = box.transactions.where((t) => !t.isDeposit).length;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "إحصائيات",
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation1, animation2, child) {
        var curve = Curves.easeInOutCubic;
        var tween = Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: curve),
        );
        return ScaleTransition(
          scale: animation1.drive(tween),
          child: FadeTransition(
            opacity: animation1,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.primaryColor, theme.primaryColor.withGreen(150)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Text(
                                'إحصائيات الصندوق',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            _buildAnimatedStatCard(
                              animation1,
                              'الإيداعات',
                              totalDeposits,
                              depositCount,
                              [Color(0xFF00C853), Color(0xFF69F0AE)],
                              Icons.arrow_upward,
                              delay: 200,
                            ),
                            SizedBox(height: 15),
                            _buildAnimatedStatCard(
                              animation1,
                              'السحوبات',
                              totalWithdrawals,
                              withdrawalCount,
                              [Color(0xFFD50000), Color(0xFFFF5252)],
                              Icons.arrow_downward,
                              delay: 400,
                            ),
                            SizedBox(height: 15),
                            _buildAnimatedStatCard(
                              animation1,
                              'الإيداع الصافي',
                              (totalDeposits - totalWithdrawals),
                              null,
                              [Color(0xFF1976D2), Color(0xFF64B5F6)],
                              Icons.account_balance,
                              delay: 600,
                            ),
                            SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [theme.primaryColor, theme.primaryColor.withGreen(150)],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'إغلاق',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatCard(
    Animation<double> animation,
    String title,
    double amount,
    int? count,
    List<Color> colors,
    IconData icon, {
    int delay = 0,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final adjustedColors = colors.map((c) => 
          theme.brightness == Brightness.dark ? c.withOpacity(0.7) : c
        ).toList();

        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: adjustedColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: adjustedColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 30),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${amount.toStringAsFixed(2)} جنيه',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (count != null) ...[
                              SizedBox(height: 5),
                              Text(
                                'عدد العمليات: $count',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // تنسيق التاريخ والوقت بنظام 12 ساعة باللغة العربية
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final formattedDate = dateFormat.format(dateTime);
    final formattedTime = timeFormat
        .format(dateTime)
        .replaceAll('AM', 'ص')
        .replaceAll('PM', 'م');
    return '$formattedDate - $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingBoxProvider>(
      builder: (context, provider, child) {
        final boxExists = provider.boxes.any((b) => b.id == boxId);
        if (!boxExists) {
          // نرجع للصفحة السابقة بشكل مباشر
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SavingBoxesPage()),
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final box = provider.boxes.firstWhere((b) => b.id == boxId);

        return Scaffold(
          appBar: CustomAppBar(
            textAppBar: box.name,
            actions: [
              IconButton(
                icon: Icon(Icons.analytics_outlined),
                onPressed: () => _showStatisticsDialog(context, box),
                tooltip: 'عرض الإحصائيات',
              ),
            ],
          ),
          body: Column(
            children: [
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              'الرصيد الحالي',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${box.currentBalance.toStringAsFixed(2)} جنيه',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      _buildInfoRow(
                        'الرصيد الافتتاحي',
                        box.initialBalance,
                      ),
                      _buildInfoRow('المبلغ المستهدف', box.targetAmount),
                      _buildInfoRow('المبلغ المتبقي', box.remainingAmount.abs()),
                      SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: box.progressPercentage / 100,
                        backgroundColor: Colors.grey[200],
                        color: Colors.green,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${box.progressPercentage.toStringAsFixed(1)}% من الهدف',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                () =>
                                    _showTransactionDialog(context, true, box),
                            icon: Icon(Icons.add),
                            label: Text(
                              'إيداع',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed:
                                () =>
                                    _showTransactionDialog(context, false, box),
                            icon: Icon(Icons.remove),
                            label: Text(
                              'سحب',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // قائمة العمليات
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: box.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction =
                        box.transactions[box.transactions.length - 1 - index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              transaction.isDeposit
                                  ? Colors.green[100]
                                  : Colors.red[100],
                          child: Icon(
                            transaction.isDeposit ? Icons.add : Icons.remove,
                            color:
                                transaction.isDeposit
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction.isDeposit ? 'إيداع' : 'سحب',
                              style: TextStyle(
                                color:
                                    transaction.isDeposit
                                        ? Colors.green
                                        : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${transaction.amount} جنيه',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (transaction.note.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  transaction.note,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(transaction.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${value.toStringAsFixed(2)} جنيه',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
