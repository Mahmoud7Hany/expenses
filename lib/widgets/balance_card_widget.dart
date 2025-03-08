// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

// بطاقة الرصيد اللي في اول الصفحه لما تفتح التطبيق
class BalanceCardWidget extends StatefulWidget {
  final IconData icon;
  final IconData hiddenIcon;
  final String totalBalance;
  final String expenses;
  final String income;
  final String totalBalanceLabel;
  final String expensesLabel;
  final String incomeLabel;

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
  }) : super(key: key);

  @override
  _BalanceCardWidgetState createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isBalanceHidden = false;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = _prefs.getBool('isBalanceHidden') ?? false;
      _isInitialized = true;
    });
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceHidden = !_isBalanceHidden;
      _prefs.setBool('isBalanceHidden', _isBalanceHidden);
    });
  }

  // تحديث دالة _buildAnimatedText لتتجاهل التأثير إذا لم تكتمل التهيئة
  Widget _buildAnimatedText(String text, TextStyle style) {
    if (!_isInitialized) {
      return Text(
        '*******',
        style: style,
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Text(
        _isBalanceHidden ? '*******' : text,
        key: ValueKey<String>(_isBalanceHidden ? 'hidden' : text),
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.cardGradientStart,
              themeProvider.cardGradientMiddle,
              themeProvider.cardGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.totalBalanceLabel,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildAnimatedText(
                      widget.totalBalance,
                      TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isBalanceHidden ? widget.hiddenIcon : widget.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: _toggleBalanceVisibility,
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBalanceItem(
                    Icons.shopping_cart_outlined,
                    widget.expensesLabel,
                    !_isInitialized ? '*******' : (_isBalanceHidden ? '*******' : widget.expenses),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _buildBalanceItem(
                    Icons.account_balance_wallet_outlined,
                    widget.incomeLabel,
                    !_isInitialized ? '*******' : (_isBalanceHidden ? '*******' : widget.income),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(IconData icon, String label, String amount) {
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
