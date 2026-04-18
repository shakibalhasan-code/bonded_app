import 'package:bonded_app/screens/profile/connection_type_screen.dart';
import 'package:bonded_app/screens/profile/picture_verification_screen.dart';
import 'package:bonded_app/screens/events/event_filter_screen.dart';
import 'package:bonded_app/screens/profile/profile_screen.dart';
import 'package:bonded_app/screens/profile/edit_profile_screen.dart';
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
import '../../screens/profile/kyc_document_screen.dart';
import '../../screens/notification/notification_screen.dart';
import '../../screens/circles/circle_details_screen.dart';
import '../../screens/circles/circle_members_screen.dart';
import '../../screens/circles/add_members_screen.dart';
import '../../screens/circles/create_circle_screen.dart';
import '../../screens/circles/all_circles_screen.dart';
import '../../screens/events/event_highlight_details_screen.dart';
import '../../screens/events/event_details_screen.dart';
import '../../screens/events/reviews_screen.dart';
import '../../screens/events/write_review_screen.dart';
import '../../screens/events/host_details_screen.dart';
import '../../screens/events/book_event_screen.dart';
import '../../screens/events/create_event_screen.dart';
import '../../screens/events/event_kyc_screen.dart';
import '../../screens/bond/bond_profile_screen.dart';
import '../../screens/messages/chat_screen.dart';
import '../../screens/bond/nearby_people_screen.dart';
import 'app_routes.dart';




class AppPages {
  static const INITIAL = AppRoutes.INITIAL;

  static final routes = [
    GetPage(name: AppRoutes.INITIAL, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.ONBOARDING, page: () => const OnboardingScreen()),
    GetPage(name: AppRoutes.WELCOME, page: () => const WelcomeScreen()),
    GetPage(name: AppRoutes.SIGNUP, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.LOGIN, page: () => const LoginScreen()),
    GetPage(
      name: AppRoutes.VERIFICATION,
      page: () => const OtpVerificationScreen(),
    ),
    GetPage(
      name: AppRoutes.PROFILE_READY,
      page: () => const ProfileReadyScreen(),
    ),
    GetPage(name: AppRoutes.MAIN, page: () => const MainWrapper()),
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
    GetPage(name: AppRoutes.ADD_CARD, page: () => const AddCardScreen()),

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
    GetPage(
      name: AppRoutes.NOTIFICATION,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppRoutes.CIRCLE_DETAILS,
      page: () => const CircleDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.CIRCLE_MEMBERS,
      page: () => const CircleMembersScreen(),
    ),
    GetPage(
      name: AppRoutes.ADD_MEMBERS,
      page: () => const AddMembersScreen(),
    ),
    GetPage(
      name: AppRoutes.CREATE_CIRCLE,
      page: () => const CreateCircleScreen(),
    ),
    GetPage(
      name: AppRoutes.ALL_CIRCLES,
      page: () => const AllCirclesScreen(),
    ),
    GetPage(
      name: AppRoutes.BOND_PROFILE,
      page: () => const BondProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatScreen(),
    ),
    GetPage(
      name: AppRoutes.NEARBY_PEOPLE,
      page: () => const NearbyPeopleScreen(),
    ),
    GetPage(
      name: AppRoutes.EVENT_HIGHLIGHT_DETAILS,
      page: () => const EventHighlightDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.EVENT_DETAILS,
      page: () => const EventDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.REVIEWS,
      page: () => const ReviewsScreen(),
    ),
    GetPage(
      name: AppRoutes.WRITE_REVIEW,
      page: () => const WriteReviewScreen(),
    ),
    GetPage(
      name: AppRoutes.HOST_DETAILS,
      page: () => const HostDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.BOOK_EVENT,
      page: () => const BookEventScreen(),
    ),
    GetPage(
      name: AppRoutes.CREATE_EVENT,
      page: () => const CreateEventScreen(),
    ),
    GetPage(
      name: AppRoutes.EVENT_KYC,
      page: () => const EventKYCScreen(),
    ),
    GetPage(
      name: AppRoutes.EVENT_FILTER,
      page: () => const EventFilterScreen(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfileScreen(),
    ),
  ];
}



