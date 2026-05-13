import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_pages.dart';

import 'package:firebase_core/firebase_core.dart';
import 'services/shared_prefs_service.dart';

import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService.init();

  // Initialize Stripe (Replace with your actual publishable key)
  Stripe.publishableKey =
      'pk_test_51OGSBHFqe3FUEwXBAkBr5YBb43LUyUV7pQ8ZM0w2YX6gIT0hWc98rqncg22uLTlcTF3KFdqVcyUaipV5e9mBcUIu00OhaFQajq'; // Example test key

  // Lock orientation to vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bonded App',
          theme: AppTheme.lightTheme,
          initialBinding: InitialBinding(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          unknownRoute: AppPages.routes.firstWhere((p) => p.name == '/main'),
        );
      },
    );
  }
}
