import 'package:get/get.dart';
import '../models/event_model.dart';

class EventController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0: Events, 1: My Events
  final RxInt selectedCategory = 0.obs; // 0: In-Person, 1: Virtual, 2: Highlights

  final RxList<EventModel> events = <EventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockEvents();
  }

  void _loadMockEvents() {
    events.addAll([
      EventModel(
        id: '1',
        title: 'National Music Festival',
        imageUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        date: 'Dec 12',
        time: '12:00 - 13:00PM',
        category: EventCategory.inPerson,
      ),
      EventModel(
        id: '2',
        title: 'Jazz Music Fest',
        imageUrl: 'https://images.unsplash.com/photo-1514525253361-9f93ee74a89a',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        date: 'Dec 12',
        time: '12:00 - 13:00PM',
        category: EventCategory.inPerson,
      ),
      EventModel(
        id: '3',
        title: 'DJ Music Competition',
        imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        date: 'Dec 12',
        time: '12:00 - 13:00PM',
        category: EventCategory.inPerson,
      ),
      EventModel(
        id: '4',
        title: 'International Music...',
        imageUrl: 'https://images.unsplash.com/photo-1459749411177-042180ce673c',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        date: 'Dec 12',
        time: '12:00 - 13:00PM',
        category: EventCategory.inPerson,
      ),
      // Highlights Mock Data
      EventModel(
        id: '5',
        title: 'Brunch Vibes',
        imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205',
        highlightsCount: 12,
        category: EventCategory.highlights,
      ),
      EventModel(
        id: '6',
        title: 'NYC Introverts Meetup',
        imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
        highlightsCount: 9,
        category: EventCategory.highlights,
      ),
      EventModel(
        id: '7',
        title: 'Fitness Run Club',
        imageUrl: 'https://images.unsplash.com/photo-1475721027185-4048477792ec',
        highlightsCount: 15,
        category: EventCategory.highlights,
      ),
      EventModel(
        id: '8',
        title: 'Brunch Vibes',
        imageUrl: 'https://images.unsplash.com/photo-1528605248644-14dd04cb21c7',
        highlightsCount: 12,
        category: EventCategory.highlights,
      ),
    ]);
  }

  List<EventModel> get filteredEvents {
    if (selectedTab.value == 1) {
      return events.where((e) => e.isMyEvent).toList();
    }
    
    EventCategory targetCategory;
    switch (selectedCategory.value) {
      case 0:
        targetCategory = EventCategory.inPerson;
        break;
      case 1:
        targetCategory = EventCategory.virtual;
        break;
      case 2:
        targetCategory = EventCategory.highlights;
        break;
      default:
        targetCategory = EventCategory.inPerson;
    }
    
    return events.where((e) => e.category == targetCategory).toList();
  }

  void changeTab(int tabIndex) {
    selectedTab.value = tabIndex;
  }

  void changeCategory(int categoryIndex) {
    selectedCategory.value = categoryIndex;
  }
}
