import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:period_tracker_flutter/screens/period_tracker_page.dart';
import 'package:period_tracker_flutter/utils/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Period Tracker',
          theme: themeProvider.theme,
          debugShowCheckedModeBanner: false,
          home: const PeriodTrackerPage(),
        );
      },
    );
  }
}
