import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const NusaInfoApp());
}

class NusaInfoApp extends StatelessWidget {
  const NusaInfoApp({super.key});

  // Palet pink burgundy soft
  static const Color _burgundy = Color(0xFF70213F);
  static const Color _rose = Color(0xFFC96B8A);
  static const Color _softPink = Color(0xFFFADCE4);
  static const Color _bg = Color(0xFFFFF3F6);
  static const Color _ink = Color(0xFF3B1F28);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: _burgundy).copyWith(
      primary: _burgundy,
      onPrimary: Colors.white,
      primaryContainer: _softPink,
      onPrimaryContainer: const Color(0xFF4A1325),
      secondary: _rose,
      surface: _bg,
      onSurface: _ink,
    );

    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return MaterialApp(
      title: 'NusaInfo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: _burgundy,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _burgundy,
            letterSpacing: 0.2,
          ),
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: _burgundy),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _burgundy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _burgundy,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          labelStyle: const TextStyle(color: _rose),
          floatingLabelStyle: const TextStyle(color: _burgundy),
          border: border(_softPink),
          enabledBorder: border(_softPink),
          focusedBorder: border(_burgundy, 2),
          errorBorder: border(Colors.red.shade300),
          focusedErrorBorder: border(Colors.red.shade400, 2),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          closeIconColor: Colors.white,
          backgroundColor: _burgundy,
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
