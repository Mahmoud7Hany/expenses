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

  void _showTransactionDialog(
    BuildContext context,
    bool isDeposit,
    SavingBox box,
  ) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isDeposit ? 'إيداع مبلغ' : 'سحب مبلغ'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'المبلغ',
                      prefixIcon: Icon(Icons.attach_money),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
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
                      type:
                          isDeposit ? SnackBarType.success : SnackBarType.error,
                      showTitle: false,
                    );
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
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
          appBar: CustomAppBar(textAppBar: box.name),
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
