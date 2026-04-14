import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/routes/app_routes.dart';
import '../models/circle_model.dart';

class CircleController extends GetxController {
  final selectedTab = 0.obs; // 0: Public, 1: Private, 2: My Circle
  final myCircleSubTab = 0.obs; // 0: Created Circle, 1: Joined Circle

  final publicCircles = <CircleModel>[].obs;
  final privateCircles = <CircleModel>[].obs;
  final myCreatedCircles = <CircleModel>[].obs;
  final myJoinedCircles = <CircleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    _loadAvailableMembers();
    _loadMockData();
  }

  final availableMembers = <MemberModel>[].obs;

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void changeMyCircleSubTab(int index) {
    myCircleSubTab.value = index;
  }

  void _loadAvailableMembers() {
    availableMembers.value = [
      MemberModel(
        id: '1',
        name: 'Matthias Huckestein',
        image: 'https://i.pravatar.cc/150?u=1',
        role: 'Brunch lover, Wine Nights, Game Nights',
      ),
      MemberModel(
        id: '2',
        name: 'Samantha Uhlemann',
        image: 'https://i.pravatar.cc/150?u=2',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '3',
        name: 'Maike Rother',
        image: 'https://i.pravatar.cc/150?u=3',
        role: 'Brunch lover, Wine Nights, Game Nights',
      ),
      MemberModel(
        id: '4',
        name: 'Josephin Stengl',
        image: 'https://i.pravatar.cc/150?u=4',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '5',
        name: 'Azra Stolz',
        image: 'https://i.pravatar.cc/150?u=5',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '6',
        name: 'Betty Günther',
        image: 'https://i.pravatar.cc/150?u=6',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '7',
        name: 'Marie Spelmeyer',
        image: 'https://i.pravatar.cc/150?u=7',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '8',
        name: 'Marten Demut',
        image: 'https://i.pravatar.cc/150?u=8',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '9',
        name: 'Markus Kinzel',
        image: 'https://i.pravatar.cc/150?u=9',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '10',
        name: 'Nevio Zschunke',
        image: 'https://i.pravatar.cc/150?u=10',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
      MemberModel(
        id: '11',
        name: 'Neele Göhler',
        image: 'https://i.pravatar.cc/150?u=11',
        role:
            'Brunch lover, Wine Nights, Game Nights, Movie Lovers, Game Nights',
      ),
    ];
  }

  void _loadMockData() {
    final mockedDetailedMembers = availableMembers;

    final sharedAvatars = [
      'https://i.pravatar.cc/150?u=a',
      'https://i.pravatar.cc/150?u=b',
      'https://i.pravatar.cc/150?u=c',
      'https://i.pravatar.cc/150?u=d',
      'https://i.pravatar.cc/150?u=e',
    ];

    // Public Circles
    publicCircles.value = [
      CircleModel(
        id: 'pub1',
        name: "Weekend Hangout Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fermentum, risus pellentesque eleifend pulvinar, tortor mauris dignissim felis, et mattis sapien diam non ex. Sed vitae convallis nulla, sit amet interdum urna. Proin luctus lorem diam, eget finibus nisi commodo ac. Mauris mattis in odio eget interdum. Nunc interdum dui eu mi mollis volutpat.",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Brunch Lovers", "Wine Nights", "Game Nights", "Movie L"],
        detailedMembers: mockedDetailedMembers,
      ),
      CircleModel(
        id: 'pub2',
        name: "Food Lovers Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fermentum, risus pellentesque eleifend pulvinar, tortor mauris dignissim felis, et mattis sapien diam non ex. Sed vitae convallis nulla, sit amet interdum urna. Proin luctus lorem diam, eget finibus nisi commodo ac. Mauris mattis in odio eget interdum. Nunc interdum dui eu mi mollis volutpat.",
        image:
            "https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Foodies", "Coffee Dates", "Picnic & Outdoor Chill"],
        detailedMembers: mockedDetailedMembers,
      ),
    ];

    // Private Circles
    privateCircles.value = [
      CircleModel(
        id: 'pri1',
        name: "Weekend Hangout Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fermentum, risus pellentesque eleifend pulvinar, tortor mauris dignissim felis, et mattis sapien diam non ex. Sed vitae convallis nulla, sit amet interdum urna. Proin luctus lorem diam, eget finibus nisi commodo ac. Mauris mattis in odio eget interdum. Nunc interdum dui eu mi mollis volutpat.",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isLocked: true,
        price: "${5.00}",
        address: "Grand city St. 100, New York, United States.",
        detailedMembers: mockedDetailedMembers,
      ),
    ];

    // My Created Circles
    myCreatedCircles.value = [
      CircleModel(
        id: 'myc1',
        name: "Weekend Hangout Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fermentum, risus pellentesque eleifend pulvinar, tortor mauris dignissim felis, et mattis sapien diam non ex. Sed vitae convallis nulla, sit amet interdum urna. Proin luctus lorem diam, eget finibus nisi commodo ac. Mauris mattis in odio eget interdum. Nunc interdum dui eu mi mollis volutpat.",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isLocked: true,
        isOwner: true,
        price: "${5.00}",
        address: "Grand city St. 100, New York, United States.",
        detailedMembers: mockedDetailedMembers,
      ),
    ];

    // My Joined Circles
    myJoinedCircles.value = [
      CircleModel(
        id: 'myj1',
        name: "Beach Volleyball Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fermentum, risus pellentesque eleifend pulvinar, tortor mauris dignissim felis, et mattis sapien diam non ex. Sed vitae convallis nulla, sit amet interdum urna. Proin luctus lorem diam, eget finibus nisi commodo ac. Mauris mattis in odio eget interdum. Nunc interdum dui eu mi mollis volutpat.",
        image:
            "https://images.unsplash.com/photo-1550929555-5c2494191fe8?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Sports", "Fitness"],
        isJoined: true,
        detailedMembers: mockedDetailedMembers,
      ),
    ];
  }

  void editCircle(CircleModel circle) {
    Get.snackbar(
      "Action",
      "Opening edit screen for ${circle.name}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }

  void deleteCircle(CircleModel circle) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "Delete Circle",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete '${circle.name}'? This action cannot be undone.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Deleted",
                "Circle '${circle.name}' has been deleted",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.1),
              );
            },
            child: Text(
              "Delete",
              style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void lockCircle(CircleModel circle) {
    // Navigate to subscription plan for unlocking/locking logic
    Get.toNamed(AppRoutes.SUBSCRIPTION_PLAN); 
    
    Get.snackbar(
      "Subscription",
      "Redirecting to subscription plan to manage circle status",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }

  void addMemberToCircle(CircleModel circle, MemberModel member) {
    Get.snackbar(
      "Success",
      "${member.name} has been added to ${circle.name}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
    );
  }
}
