import 'package:expenses/pages/home_page.dart';
import 'package:expenses/provider/expense_provider.dart';
import 'package:expenses/provider/sadaqah_provider.dart';
import 'package:expenses/provider/saving_box_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => SadaqahProvider()),
        ChangeNotifierProvider(create: (_) => SavingBoxProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (!themeProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'AE'),
          ],
          locale: const Locale('ar', 'AE'),
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          darkTheme: themeProvider.themeData,
          home: const MyHomePage(),
        );
      },
    );
  }
}
