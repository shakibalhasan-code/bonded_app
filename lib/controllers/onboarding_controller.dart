import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/onboarding_model.dart';
import '../core/routes/app_routes.dart';
import '../core/constants/app_assets.dart';
import '../screens/auth/welcome_screen.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<OnboardingStep> steps = [
    OnboardingStep(
      title: 'Discover Genuine Friendships Through Shared Interests',
      subtitle: 'Move beyond small talk and connect with people who truly get you. Explore real activities and circles that bring like-minded individuals together — online or in person.',
      imagePath: AppAssets.onboarding1,
    ),
    OnboardingStep(
      title: 'Join Vibrant Circles and Local Communities',
      subtitle: 'Whether you love hiking, gaming, or brunching — there’s a circle for you. Bonded helps you find your tribe and grow meaningful friendships within your area and beyond.',
      imagePath: AppAssets.onboarding2,
    ),
    OnboardingStep(
      title: 'Experience Real Events, Not Endless Scrolling',
      subtitle: 'Say goodbye to passive feeds. With Bonded, your home screen is filled with real events, meetups, and gatherings happening near you — designed to bring people together.',
      imagePath: AppAssets.onboarding3,
    ),
    OnboardingStep(
      title: 'Chat, Engage, and Build Lasting Bonds',
      subtitle: 'Join group discussions, plan activities, and stay connected with your community even after the event ends. Every chat in Bonded helps friendships grow stronger.',
      imagePath: AppAssets.onboarding4,
    ),
    OnboardingStep(
      title: 'Let AI Help You Build Your Perfect Social Circle',
      subtitle: 'Bonded’s intelligent AI suggests new friends, circles, and local meetups that match your interests — making it easier than ever to turn shared passions into genuine connections.',
      imagePath: AppAssets.onboarding5,
    ),
  ];

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < steps.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() {
    Get.offAllNamed(AppRoutes.WELCOME);
  }

  void skipOnboarding() {
    Get.offAllNamed(AppRoutes.WELCOME);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
