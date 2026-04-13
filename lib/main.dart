import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/subscription/subscription_plan_screen.dart';
import 'screens/subscription/payment_method_screen.dart';
import 'screens/subscription/add_card_screen.dart';

void main() {
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
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const SplashScreen()),
            GetPage(name: '/home', page: () => const HomeScreen()),
            GetPage(name: '/subscription_plan', page: () => const SubscriptionPlanScreen()),
            GetPage(name: '/payment_method', page: () => const PaymentMethodScreen()),
            GetPage(name: '/add_card', page: () => const AddCardScreen()),
          ],
          unknownRoute: GetPage(name: '/notfound', page: () => const HomeScreen()),
        );
      },
    );
  }
}
