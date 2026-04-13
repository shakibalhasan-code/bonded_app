import 'package:get/get.dart';
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
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void changeMyCircleSubTab(int index) {
    myCircleSubTab.value = index;
  }

  void _loadMockData() {
    final mockedDetailedMembers = [
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
    ];

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
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Brunch Lovers", "Wine Nights", "Game Nights", "Movie L"],
      ),
      CircleModel(
        id: 'pub2',
        name: "Food Lovers Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Foodies", "Coffee Dates", "Picnic & Outdoor Chill"],
      ),
      CircleModel(
        id: 'pub3',
        name: "Book & Coffee Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=387&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Book Clubs", "Coffee Dates"],
      ),
    ];

    // Private Circles
    privateCircles.value = [
      CircleModel(
        id: 'pri1',
        name: "Weekend Hangout Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isLocked: true,
        price: "${4.99}",
        address: "Grand city St. 100, New York, United States.",
        detailedMembers: mockedDetailedMembers,
      ),
      CircleModel(
        id: 'pri2',
        name: "Book & Coffee Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=387&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isLocked: true,
        price: "${4.99}",
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
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isLocked: true,
        isOwner: true,
      ),
      CircleModel(
        id: 'myc2',
        name: "Food Lovers Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1528605248644-14dd04022da1?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isLocked: true,
        isOwner: true,
      ),
    ];

    // My Joined Circles
    myJoinedCircles.value = [
      CircleModel(
        id: 'myj1',
        name: "Weekend Hangout Circle",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
        image:
            "https://images.unsplash.com/photo-1511632765486-a01980e01a18?q=80&w=870&auto=format&fit=crop",
        memberAvatars: sharedAvatars,
        tags: ["Hiking", "Sports", "Outdoor Fitness", "Dance", "Game"],
        isJoined: true,
      ),
    ];
  }
}
