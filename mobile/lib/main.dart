import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'src/themes/app_theme.dart';
import 'src/widgets/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.initApiConfig();
  runApp(const SasyaDrishtiApp());
}

class SasyaDrishtiApp extends StatelessWidget {
  const SasyaDrishtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SasyaDrishti',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BottomNav(),
    );
  }
}
