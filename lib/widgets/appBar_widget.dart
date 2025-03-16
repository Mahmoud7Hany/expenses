import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String textAppBar;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool showThemeIcon; // إضافة متغير جديد للتحكم في ظهور أيقونة السمة

  const CustomAppBar({
    Key? key,
    required this.textAppBar,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.showThemeIcon = false, // القيمة الافتراضية هي عدم إظهار الأيقونة
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return AppBar(
      title: Text(textAppBar),
      automaticallyImplyLeading: automaticallyImplyLeading,
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
      actions: [
        if (showThemeIcon) // إظهار أيقونة السمة فقط إذا كان showThemeIcon صحيحاً
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
