import 'package:bonded_app/models/home_models.dart';
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
        isCreator: true,
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
        price: "\$5.00",
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
        price: "\$5.00",
        address: "Grand city St. 100, New York, United States.",
        detailedMembers: mockedDetailedMembers,
      ),
    ];

    // My Joined Circles
    final mockPosts = [
      PostModel(
        id: 'p1',
        userName: 'anny_wilson',
        userBio: 'Wine Nights, Game Nights',
        userImage: 'https://i.pravatar.cc/150?u=anny',
        postText: 'Wine Nights, Game Nights',
        images: [
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=500&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=500&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=500&auto=format&fit=crop',
        ],
        likesCount: 10389,
        commentsCount: 5,
        sharesCount: 7,
        comments: [
          CommentModel(
            id: 'c1',
            userName: 'Aniy Wilson',
            userImage: 'https://i.pravatar.cc/150?u=aniyw',
            text: 'Welcome! Really nice to meet you.',
            timestamp: '1h',
          ),
          CommentModel(
            id: 'c2',
            userName: 'Robert Fox',
            userImage: 'https://i.pravatar.cc/150?u=rob',
            text: 'Can\'t wait to meet you',
            timestamp: '22 m',
          ),
        ],
      ),
    ];

    publicCircles.forEach((c) => c.posts.addAll(mockPosts));
    privateCircles.forEach((c) => c.posts.addAll(mockPosts));
    myCreatedCircles.forEach((c) => c.posts.addAll(mockPosts));
    myJoinedCircles.value = [
      CircleModel(
        id: 'myj1',
        name: "Beach Volleyball Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse fermentum, risus pellentesque eleifend pulvinar, tortor mauris dignissim felis, et mattis sapien diam non ex. Sed vitae convallis nulla, sit amet interdum urna. Proin luctus lorem diam, eget finibus nisi commodo ac. Mauris mattis in odio eget interdum. Nunc interdum dui eu mi mollis volutpat.",
        image:
            "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        memberAvatars: sharedAvatars,
        tags: ["Sports", "Fitness"],
        isJoined: true,
        isOwner: false,
        detailedMembers: mockedDetailedMembers,
        posts: mockPosts,
      ),
      CircleModel(
        id: 'myj2',
        name: "Tech & Startup Circle",
        description:
            "Join our community of developers, designers, and entrepreneurs. We discuss the latest in tech, share startup tips, and network with like-minded individuals.",
        image:
            "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1740&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Tech", "Networking", "Startups"],
        isJoined: true,
        isOwner: true,
        detailedMembers: mockedDetailedMembers,
        posts: mockPosts,
      ),
      CircleModel(
        id: 'myj3',
        name: "Digital Nomad Circle",
        description:
            "A group for those who work while traveling. Share tips on best co-working spaces, visas, and travel hacks.",
        image:
            "https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?q=80&w=1740&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Travel", "Remote Work", "Lifestyle"],
        isJoined: true,
        isOwner: true,
        detailedMembers: mockedDetailedMembers,
        posts: mockPosts,
      ),
    ];
  }

  // Feed Interaction Methods
  void toggleLikePost(PostModel post) {
    if (post.reactionType.value != "none") {
      updatePostReaction(post, "none");
    } else {
      updatePostReaction(post, "like");
    }
  }

  void updatePostReaction(PostModel post, String type) {
    // If transitioning from none to a reaction
    if (post.reactionType.value == "none" && type != "none") {
      post.likesCount.value++;
      post.isLiked.value = true;
    }
    // If transitioning from a reaction to none
    else if (post.reactionType.value != "none" && type == "none") {
      post.likesCount.value--;
      post.isLiked.value = false;
    }
    
    post.reactionType.value = type;
  }

  void toggleCommentInput(PostModel post) {
    post.isCommenting.toggle();
  }

  void addComment(PostModel post, String text) {
    if (text.isEmpty) return;

    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Me',
      userImage: 'https://i.pravatar.cc/150?u=me',
      text: text,
      timestamp: 'Just now',
    );

    post.comments.add(newComment);
    post.commentsCount.value++;
    post.isCommenting.value = false;
  }

  void toggleLikeComment(CommentModel comment) {
    if (comment.isLiked.value) {
      comment.isLiked.value = false;
      comment.likesCount.value--;
    } else {
      comment.isLiked.value = true;
      comment.likesCount.value++;
    }
  }

  void toggleReplyInput(CommentModel comment) {
    comment.showReplyInput.toggle();
  }

  void addReply(CommentModel comment, String text) {
    if (text.isEmpty) return;

    final newReply = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Me',
      userImage: 'https://i.pravatar.cc/150?u=me',
      text: text,
      timestamp: 'Just now',
    );

    comment.replies.add(newReply);
    comment.showReplyInput.value = false;
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
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
            child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
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
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
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

  void createPost(
    CircleModel circle,
    String text, {
    List<String> images = const [],
  }) {
    if (text.isEmpty && images.isEmpty) return;

    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Andrew Ainsley', // Matches the screenshot profile
      userBio: 'Bonded User',
      userImage: 'https://i.pravatar.cc/150?u=andrew',
      postText: text,
      images: images,
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
    );

    circle.posts.insert(0, newPost);
    Get.back(); // Close the sheet
    Get.snackbar(
      "Post Created",
      "Your post has been shared in ${circle.name}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }
}
