import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(ChangeNotifierProvider.value(value: state, child: const PosApp()));
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final seed = Color(s.themeColor);
    return MaterialApp(
      title: 'POS Retail Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, primary: seed),
        scaffoldBackgroundColor: const Color(0xFFF6F8FC),
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.black87),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)))),
        cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200))),
      ),
      home: const SplashScreen(),
    );
  }
}
