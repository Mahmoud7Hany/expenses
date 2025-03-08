import 'package:expenses/pages/debt_management_page.dart';
import 'package:expenses/pages/sadaqah_calculator_page.dart';
import 'package:expenses/pages/saving_boxes_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

// هذه صفحة القائمة الجانبية التي في الصفحة الرئيسية
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.cardGradientStart,
                  themeProvider.cardGradientEnd,
                ],
                begin: Alignment
                    .topLeft, // يمكنك تغيير هذه القيمة لتغيير اتجاه التدرج
                end: Alignment
                    .bottomRight, // يمكنك تغيير هذه القيمة لتغيير اتجاه التدرج
              ),
            ),
            child: Center(
              child: Text(
                'المصاريف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.arrow_outward, color: Colors.green),
            title: Text('الديون'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebtManagementPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Colors.green),
            title: const Text('حاسبة الصدقة'),
            onTap: () {
              Navigator.pop(context); // إغلاق الـ Drawer أولاً
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SadaqahCalculatorPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.savings, color: Colors.green),
            title: const Text('صناديق الادخار'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavingBoxesPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
