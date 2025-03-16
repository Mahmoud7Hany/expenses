// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// بطاقة الرصيد اللي في اول الصفحه لما تفتح التطبيق
class BalanceCardWidget extends StatelessWidget {
  final IconData icon;
  final IconData hiddenIcon;
  final Widget totalBalance; // تغيير النوع إلى Widget
  final Widget expenses; // تغيير النوع إلى Widget
  final Widget income; // تغيير النوع إلى Widget
  final String totalBalanceLabel;
  final String expensesLabel;
  final String incomeLabel;
  final bool isVisible; // إضافة متغير جديد
  final VoidCallback onVisibilityChanged; // إضافة دالة جديدة

  const BalanceCardWidget({
    Key? key,
    required this.icon,
    required this.hiddenIcon,
    required this.totalBalance,
    required this.expenses,
    required this.income,
    required this.totalBalanceLabel,
    required this.expensesLabel,
    required this.incomeLabel,
    required this.isVisible, // إضافة للمتغير
    required this.onVisibilityChanged, // إضافة للدالة
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // تقليل الارتفاع
      shadowColor: Colors.black12, // تغيير لون الظل ليكون أخف
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8E2DE2), // لون أفتح
              Color(0xFF4A00E0), // لون أفتح
            ],
            stops: [0.2, 0.9], // تحسين توزيع التدرج
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
              spreadRadius: -2, // إضافة spreadRadius سالب للحصول على ظل أنعم
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        totalBalanceLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onVisibilityChanged,
                  icon: Icon(
                    isVisible ? icon : hiddenIcon,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            totalBalance,
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBalanceItem(
                    Icons.shopping_cart_outlined,
                    expensesLabel,
                    expenses,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildBalanceItem(
                    Icons.account_balance_wallet_outlined,
                    incomeLabel,
                    income,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(IconData icon, String label, Widget amount) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
        SizedBox(height: 4),
        amount,
      ],
    );
  }
}
