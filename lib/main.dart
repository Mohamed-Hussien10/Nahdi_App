import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nahdy/components/cart_provider.dart';
import 'package:nahdy/components/app_localizations.dart';
import 'package:nahdy/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Cart(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default language is English

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  // Load the saved language from SharedPreferences
  Future<void> _loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode =
        prefs.getString('languageCode'); // Retrieve saved language code
    setState(() {
      _locale =
          Locale(languageCode ?? 'en'); // Default to 'en' if no language saved
    });
  }

  // Save the selected language in SharedPreferences
  Future<void> _saveLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
  }

  // Set the app's locale and save it
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    _saveLocale(locale.languageCode); // Save the selected language
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alnahdi Est',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      home: const LoginPage(),
    );
  }
}
