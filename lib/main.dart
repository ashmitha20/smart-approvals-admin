import 'package:flutter/material.dart';
import 'src/app_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue.shade700;
    final accent = Colors.blue.shade600;

    final textTheme = ThemeData.light().textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Approval Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        primaryColor: primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
        ),
       cardTheme: CardThemeData(
  elevation: 1.5,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  margin: const EdgeInsets.all(8),
),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            elevation: 2,
          ),
        ),
        textTheme: textTheme.copyWith(
          titleLarge: textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium: textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16),
          bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14, color: Colors.black87),
        ),
      ),
      home: const AppShell(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'src/screens/basic_details_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Smart Approval Admin',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//         useMaterial3: true,
//         scaffoldBackgroundColor: Colors.white,
//       ),
//       home: const BasicDetailsScreen(), // ⬅ First screen of the admin flow
//     );
//   }
// }


