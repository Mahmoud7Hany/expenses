// ignore_for_file: deprecated_member_use

import 'package:expenses/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/saving_box_provider.dart';
import '../models/saving_box_model.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/appBar_widget.dart';
import 'saving_box_details_page.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:ui';

// هذه الصفحة تعرض جميع صناديق الادخار الموجودة
// وانشاء صندوق ادخار جديد
class SavingBoxesPage extends StatelessWidget {
  const SavingBoxesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _SavingBoxesContent();
  }
}

class _SavingBoxesContent extends StatefulWidget {
  // تغيير إلى StatefulWidget
  const _SavingBoxesContent({Key? key}) : super(key: key);

  @override
  State<_SavingBoxesContent> createState() => _SavingBoxesContentState();
}

class _SavingBoxesContentState extends State<_SavingBoxesContent> {
  bool _showHint = false;
  Timer? _hintTimer;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
      if (_showHint) {
        // إلغاء المؤقت السابق إذا كان موجوداً
        _hintTimer?.cancel();
        // تعيين مؤقت جديد
        _hintTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showHint = false;
            });
          }
        });
      } else {
        // إلغاء المؤقت إذا تم إخفاء التلميح يدوياً
        _hintTimer?.cancel();
      }
    });
  }

  void _showAddBoxDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final initialController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            themeProvider.cardGradientStart,
                            themeProvider.cardGradientEnd,
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: const Text(
                        'إنشاء صندوق ادخار جديد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Form
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              controller: nameController,
                              label: 'اسم الصندوق',
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: targetController,
                              label: 'المبلغ المستهدف',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: initialController,
                              label: 'الرصيد الابتدائي',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Buttons
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: isDark 
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                              ),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  final provider = context.read<SavingBoxProvider>();
                                  final newBox = SavingBox(
                                    id: const Uuid().v4(),
                                    name: nameController.text,
                                    targetAmount: double.parse(targetController.text),
                                    initialBalance: double.parse(initialController.text),
                                    currentBalance: double.parse(initialController.text),
                                  );
                                  provider.addBox(newBox);
                                  Navigator.pop(context);
                                  CustomSnackBar.show(
                                    context: context,
                                    message: 'تم إنشاء صندوق الادخار بنجاح',
                                    type: SnackBarType.success,
                                    showTitle: false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: themeProvider.cardGradientEnd,
                                elevation: isDark ? 4 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'حفظ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white : Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'هذا الحقل مطلوب';
        if (keyboardType == TextInputType.number) {
          if (double.tryParse(value!) == null) return 'الرجاء إدخال رقم صحيح';
          if (double.parse(value) < 0) return 'الرقم يجب أن يكون 0 أو أكبر';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        textAppBar: 'صناديق الادخار',
        actions: [
          IconButton(
            icon: Icon(
              _showHint ? Icons.info : Icons.info_outline,
              color: _showHint ? Colors.amber : Colors.white,
            ),
            onPressed: _toggleHint,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBoxDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          Consumer<SavingBoxProvider>(
            builder: (context, provider, child) {
              if (provider.boxes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد صناديق ادخار حالياً',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اضغط على + لإضافة صندوق جديد',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.boxes.length,
                itemBuilder: (context, index) {
                  final box = provider.boxes[index];
                  return _SavingBoxCard(box: box);
                },
              );
            },
          ),
          // تلميح للمستخدم - سيظهر دائماً بغض النظر عن وجود صناديق
          if (_showHint)
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: AnimatedOpacity(
                opacity: _showHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber[400],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'كيفية الاستخدام',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• اضغط على + لإضافة صندوق ادخار جديد\n'
                        '• اسحب الصندوق لليسار للحذف\n'
                        '• اضغط مطولاً على الصندوق للتعديل\n'
                        '• اضغط على الصندوق للدخول إلى التفاصيل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SavingBoxCard extends StatelessWidget {
  final SavingBox box;

  const _SavingBoxCard({Key? key, required this.box}) : super(key: key);

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: box.name);
    final targetController = TextEditingController(text: box.targetAmount.toString());
    final initialController = TextEditingController(text: box.initialBalance.toString());
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: Navigator.of(context),
      ),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 300),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeProvider.cardGradientStart,
                              themeProvider.cardGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'تعديل الصندوق',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Form
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          _buildEditTextField(
                            context: context,
                            controller: nameController,
                            label: 'اسم الصندوق',
                            icon: Icons.account_balance_wallet_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildEditTextField(
                            context: context,
                            controller: targetController,
                            label: 'المبلغ المستهدف',
                            icon: Icons.money,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildEditTextField(
                            context: context,
                            controller: initialController,
                            label: 'الرصيد الافتتاحي',
                            icon: Icons.account_balance,
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: isDark 
                                        ? Colors.grey[850]
                                        : Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState?.validate() ?? false) {
                                      final provider = context.read<SavingBoxProvider>();
                                      final newInitialBalance = double.parse(
                                        initialController.text,
                                      );
                                      final balanceDifference =
                                          newInitialBalance - box.initialBalance;

                                      final updatedBox = SavingBox(
                                        id: box.id,
                                        name: nameController.text,
                                        targetAmount: double.parse(targetController.text),
                                        initialBalance: newInitialBalance,
                                        currentBalance: box.currentBalance + balanceDifference,
                                        transactions: box.transactions,
                                      );
                                      provider.updateBox(updatedBox);
                                      Navigator.pop(context);
                                      CustomSnackBar.show(
                                        context: context,
                                        message: 'تم تحديث الصندوق بنجاح',
                                        type: SnackBarType.success,
                                        showTitle: false,
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: themeProvider.cardGradientEnd,
                                    elevation: isDark ? 4 : 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'حفظ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label text above the field
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            // إزالة labelText لأننا أضفنا label فوق الحقل
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 60, 16),
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.white : Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'هذا الحقل مطلوب';
            if (keyboardType == TextInputType.number) {
              if (double.tryParse(value!) == null) return 'الرجاء إدخال رقم صحيح';
              if (double.parse(value) < 0) return 'الرقم يجب أن يكون اكبر من 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    // تحديد الألوان بناءً على الوضع
    final cardGradientStart = isDark 
        ? themeProvider.cardGradientStart.withOpacity(0.3)
        : themeProvider.cardGradientStart.withOpacity(0.1);
    final cardGradientEnd = isDark
        ? themeProvider.cardGradientEnd.withOpacity(0.4)
        : themeProvider.cardGradientEnd.withOpacity(0.2);
    final progressColor = isDark ? Colors.greenAccent : Colors.green;
    
    return Dismissible(
      key: Key(box.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red[700],
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text('تأكيد الحذف'),
                ],
              ),
              content: Text('هل أنت متأكد من حذف صندوق "${box.name}"؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('حذف'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        Provider.of<SavingBoxProvider>(
          context,
          listen: false,
        ).deleteBox(box.id);
        CustomSnackBar.show(
          context: context,
          message: 'تم حذف الصندوق بنجاح',
          type: SnackBarType.error,
          showTitle: false,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: isDark ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavingBoxDetailsPage(boxId: box.id),
              ),
            );
          },
          onLongPress: () => _showEditDialog(context),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [cardGradientStart, cardGradientEnd],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          box.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: progressColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${box.progressPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: box.progressPercentage / 100,
                    backgroundColor: isDark ? Colors.grey[850] : Colors.grey[200],
                    color: progressColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                        context,
                        'الرصيد الحالي',
                        '${box.currentBalance}',
                        isDark ? Colors.lightBlueAccent : Colors.blue,
                      ),
                      _buildInfoColumn(
                        context,
                        'المبلغ المستهدف',
                        '${box.targetAmount}',
                        isDark ? Colors.purpleAccent : Colors.purple,
                      ),
                      _buildInfoColumn(
                        context,
                        'متبقي',
                        '${box.remainingAmount.abs()}',
                        isDark ? Colors.amberAccent : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.5 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? color : color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
