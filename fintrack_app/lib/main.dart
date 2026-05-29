import 'package:flutter/material.dart';
import 'package:fintrack_app/core/theme/app_theme.dart';

void main() {
  runApp(const FinTrackApp());
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Dark mode first
      darkTheme: AppTheme.darkTheme,
      home: const DashboardPlaceholder(),
    );
  }
}

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack Command Center'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Total Net Worth',
              style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            const Text(
              '\$124,500.00',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('Glassmorphic Card Setup Successful!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
