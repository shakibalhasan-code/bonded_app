import 'package:get/get.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/profile/profile_ready_screen.dart';
import '../../screens/main_wrapper.dart';
import '../../screens/subscription/subscription_plan_screen.dart';
import '../../screens/subscription/payment_method_screen.dart';
import '../../screens/subscription/add_card_screen.dart';
import '../../screens/profile/profile_building_screen.dart';
import '../../screens/profile/add_location_screen.dart';
import '../../screens/profile/choose_interest_screen.dart';
import '../../screens/profile/connection_type_screen.dart';
import '../../screens/profile/picture_verification_screen.dart';
import '../../screens/profile/kyc_document_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;

  static final routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: AppRoutes.WELCOME,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.VERIFICATION,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.PROFILE_READY,
      page: () => const ProfileReadyScreen(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainWrapper(),
    ),
    GetPage(
      name: '/home', // Alias for MAIN
      page: () => const MainWrapper(),
    ),
    GetPage(
      name: AppRoutes.SUBSCRIPTION_PLAN,
      page: () => const SubscriptionPlanScreen(),
    ),
    GetPage(
      name: AppRoutes.PAYMENT_METHOD,
      page: () => const PaymentMethodScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_CARD,
      page: () => const AddCardScreen(),
    ),
    
    // Profile Flow
    GetPage(
      name: AppRoutes.PROFILE_BUILDING,
      page: () => const ProfileBuildingScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_LOCATION,
      page: () => const AddLocationScreen(),
    ),
    GetPage(
      name: AppRoutes.CHOOSE_INTEREST,
      page: () => const ChooseInterestScreen(),
    ),
    GetPage(
      name: AppRoutes.CONNECTION_TYPE,
      page: () => const ConnectionTypeScreen(),
    ),
    GetPage(
      name: AppRoutes.PICTURE_VERIFICATION,
      page: () => const PictureVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.KYC_DOCUMENT,
      page: () => const KYCDocumentScreen(),
    ),
  ];
}
