import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'services/app_state.dart';
import 'features/onboarding/device_status_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status bar and navigation bar styling for iQOO devices
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const AegiSynApp(),
    ),
  );
}

class AegiSynApp extends StatelessWidget {
  const AegiSynApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AegiSyn AI - Hyderabad HealthTech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const DeviceStatusScreen(),
    );
  }
}
