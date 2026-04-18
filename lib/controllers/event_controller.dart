import 'package:get/get.dart';
import '../models/event_model.dart';

class EventController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0: Events, 1: My Events
  final RxInt selectedCategory = 0.obs; // 0: In-Person, 1: Virtual, 2: Highlights
  final RxInt selectedMyEventTab = 0.obs; // 0: Created, 1: Booked, 2: Tickets, 3: Wallet

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  // Filter States
  final Rx<RangeValues> priceRange = const RangeValues(0, 100).obs;
  final Rx<RangeValues> distanceRange = const RangeValues(0, 50).obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();
  final RxList<String> activeFilterCategories = <String>[].obs;
  final RxString selectedLocation = '2464 Royal Ln. Mesa, New Jersey 45463'.obs;

  final List<String> availableFilterCategories = [
    "Fitness",
    "Networking",
    "Food & Drinks",
    "Celebration",
    "Music",
    "Education"
  ];

  @override
  void onInit() {
    super.onInit();
    _loadMockEvents();
    _loadMockTickets();
    _loadMockTransactions();
  }

  void _loadMockEvents() {
    events.addAll([
      // ... same as before but adding isMyEvent for some
      EventModel(
        id: '1',
        title: 'National Music Festival',
        imageUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        date: 'Dec 12',
        time: '12:00 - 13:00PM',
        category: EventCategory.inPerson,
        isMyEvent: true, // Created by me
      ),
      EventModel(
        id: '9',
        title: 'Jazz Music Fest',
        imageUrl: 'https://images.unsplash.com/photo-1514525253361-9f93ee74a89a',
        address: '2464 Royal Ln. Mesa, New Jersey 45463',
        date: 'Dec 12',
        time: '12:00 - 13:00PM',
        category: EventCategory.inPerson,
        isMyEvent: false, // Booked by me (I'll handle this in logic)
      ),
      // ... keep other mock events
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
    ]);
  }

  void _loadMockTickets() {
    tickets.addAll([
      TicketModel(
        id: 't1',
        title: 'National Music Fest',
        imageUrl: 'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
        price: 50.00,
        seats: 1,
      ),
      TicketModel(
        id: 't2',
        title: 'National Music Fest',
        imageUrl: 'https://images.unsplash.com/photo-1514525253361-9f93ee74a89a',
        price: 50.00,
        seats: 1,
      ),
      TicketModel(
        id: 't3',
        title: 'National Music Fest',
        imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
        price: 50.00,
        seats: 1,
      ),
    ]);
  }

  void _loadMockTransactions() {
    transactions.addAll([
      TransactionModel(
        id: 'tr1',
        title: 'Prosperity Pioneers',
        transactionId: '0817239419528913',
        date: 'Dec 12, 2023',
        amount: -500,
        isCredit: false,
      ),
      TransactionModel(
        id: 'tr2',
        title: 'Prosperity Pioneers',
        transactionId: '0817239419528913',
        date: 'Jan 01, 2024',
        amount: 500,
        isCredit: true,
      ),
      TransactionModel(
        id: 'tr3',
        title: 'Prosperity Pioneers',
        transactionId: '0817239419528913',
        date: 'Dec 12, 2023',
        amount: -500,
        isCredit: false,
      ),
    ]);
  }

  List<EventModel> get filteredEvents {
    if (selectedTab.value == 1) {
      if (selectedMyEventTab.value == 0) {
        return events.where((e) => e.isMyEvent).toList();
      } else {
        // Booked events - mocking with all events for now
        return events.where((e) => !e.isMyEvent).toList();
      }
    }
    
    EventCategory targetCategory;
    switch (selectedCategory.value) {
      case 0: targetCategory = EventCategory.inPerson; break;
      case 1: targetCategory = EventCategory.virtual; break;
      case 2: targetCategory = EventCategory.highlights; break;
      default: targetCategory = EventCategory.inPerson;
    }
    
    return events.where((e) => e.category == targetCategory).toList();
  }

  void changeTab(int tabIndex) {
    selectedTab.value = tabIndex;
  }

  void changeCategory(int categoryIndex) {
    selectedCategory.value = categoryIndex;
  }

  void changeMyEventTab(int tabIndex) {
    selectedMyEventTab.value = tabIndex;
  }

  void resetFilters() {
    priceRange.value = const RangeValues(0, 100);
    distanceRange.value = const RangeValues(0, 50);
    selectedDate.value = null;
    selectedTime.value = null;
    activeFilterCategories.clear();
  }

  void toggleFilterCategory(String category) {
    if (activeFilterCategories.contains(category)) {
      activeFilterCategories.remove(category);
    } else {
      activeFilterCategories.add(category);
    }
  }
}
