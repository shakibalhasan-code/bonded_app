import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_model.dart';
import '../models/highlight_model.dart';
import '../services/api_service.dart';
import '../core/constants/app_endpoints.dart';

class EventController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxBool isLoading = false.obs;

  final RxInt selectedTab = 0.obs; // 0: Events, 1: My Events
  final RxInt selectedCategory =
      0.obs; // 0: In-Person, 1: Virtual, 2: Highlights
  final RxInt selectedMyEventTab =
      0.obs; // 0: Created, 1: Booked, 2: Tickets, 3: Wallet

  final RxList<EventModel> events = <EventModel>[].obs;
  final RxList<HighlightModel> publicHighlights = <HighlightModel>[].obs;
  final RxList<TicketModel> tickets = <TicketModel>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isStripeConnected = false.obs;
  final RxBool isCheckingStripe = false.obs;
  final RxBool isOnboardingStripe = false.obs;
  final Rxn<WalletModel> wallet = Rxn<WalletModel>();
  final RxBool isLoadingWallet = false.obs;

  // Filter States
  final Rx<RangeValues> priceRange = const RangeValues(0, 100).obs;
  final Rx<RangeValues> distanceRange = const RangeValues(0, 50).obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();
  final RxList<String> activeFilterCategories = <String>[].obs;
  final RxString selectedLocation = '2464 Royal Ln. Mesa, New Jersey 45463'.obs;

  // Search
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  void updateSearch(String query) => searchQuery.value = query.trim();
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  final List<String> availableFilterCategories = [
    "Fitness",
    "Networking",
    "Food & Drinks",
    "Celebration",
    "Music",
    "Education",
  ];

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    _loadMockTickets();
    fetchWallet();
    checkStripeStatus();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> checkStripeStatus() async {
    try {
      isCheckingStripe.value = true;
      final response = await _apiService.get(AppUrls.stripeStatus);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        bool connected = data['data']['connected'] ?? false;
        
        if (connected) {
          if (!isStripeConnected.value) {
            Get.snackbar(
              'Success',
              'Stripe account connected successfully!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            fetchWallet();
          }
          isStripeConnected.value = true;
          isOnboardingStripe.value = false;
        } else {
          isStripeConnected.value = false;
          isOnboardingStripe.value = false;
        }
      }
    } catch (e) {
      debugPrint("Error checking stripe status: $e");
    } finally {
      isCheckingStripe.value = false;
    }
  }

  Future<void> fetchWallet() async {
    try {
      isLoadingWallet.value = true;
      final response = await _apiService.get(AppUrls.myWallet);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        wallet.value = WalletModel.fromJson(data['data']);
        _loadMockTransactions();
      }
    } catch (e) {
      debugPrint("Error fetching wallet: $e");
    } finally {
      isLoadingWallet.value = false;
    }
  }

  Future<void> connectStripe() async {
    try {
      isLoading.value = true;
      final response = await _apiService.post(AppUrls.stripeOnboard, {});
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final onboardingUrl = data['data']['onboardingUrl'];
        if (onboardingUrl != null) {
          final uri = Uri.parse(onboardingUrl);
          try {
            bool launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (launched) {
              isOnboardingStripe.value = true;
            } else {
              Get.snackbar('Error', 'Could not launch onboarding URL');
            }
          } catch (e) {
            debugPrint("Error launching URL: $e");
            Get.snackbar('Error', 'Could not launch onboarding URL: $e');
          }
        }
      }
    } catch (e) {
      debugPrint("Error connecting stripe: $e");
      Get.snackbar('Error', 'Failed to generate onboarding link');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEvents({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final response = await _apiService.get(AppUrls.events);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> eventList = data['data'];
        final List<EventModel> fetchedEvents =
            eventList.map((e) => EventModel.fromJson(e)).toList();

        if (fetchedEvents.every((e) => e.category != EventCategory.highlights)) {
          _addMockHighlights(fetchedEvents);
        }

        events.value = fetchedEvents;
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> fetchMyEvents({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final response = await _apiService.get(AppUrls.myEvents);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> eventList = data['data'];
        events.value = eventList.map((e) {
          return EventModel.fromJson(e);
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching my events: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  void _addMockHighlights(List<EventModel> list) {
    list.addAll([
      EventModel(
        id: 'h1',
        title: 'Brunch Vibes',
        imageUrl:
            'https://images.unsplash.com/photo-1517457373958-b7bdd4587205',
        highlightsCount: 12,
        category: EventCategory.highlights,
      ),
      EventModel(
        id: 'h2',
        title: 'NYC Introverts Meetup',
        imageUrl:
            'https://images.unsplash.com/photo-1492684223066-81342ee5ff30',
        highlightsCount: 9,
        category: EventCategory.highlights,
      ),
    ]);
  }

  List<EventModel> get filteredEvents {
    final query = searchQuery.value.toLowerCase();

    List<EventModel> base;
    if (selectedTab.value == 0) {
      if (selectedCategory.value == 0) {
        base = events.where((e) => e.category == EventCategory.inPerson).toList();
      } else if (selectedCategory.value == 1) {
        base = events.where((e) => e.category == EventCategory.virtual).toList();
      } else if (selectedCategory.value == 2) {
        base = events.where((e) => e.category == EventCategory.highlights).toList();
      } else {
        base = events.toList();
      }
    } else {
      base = events.toList();
    }

    if (query.isEmpty) return base;

    return base.where((e) {
      return e.title.toLowerCase().contains(query) ||
          (e.city ?? '').toLowerCase().contains(query) ||
          (e.venueName ?? '').toLowerCase().contains(query) ||
          (e.description ?? '').toLowerCase().contains(query) ||
          e.category.name.toLowerCase().contains(query);
    }).toList();
  }

  void changeTab(int tabIndex) {
    selectedTab.value = tabIndex;
    isOnboardingStripe.value = false;
    if (tabIndex == 0) {
      fetchEvents();
    } else {
      fetchMyEvents();
    }
  }

  void changeCategory(int categoryIndex) {
    selectedCategory.value = categoryIndex;
    if (categoryIndex == 2) {
      fetchPublicHighlights();
    }
  }

  List<HighlightModel> get filteredHighlights {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return publicHighlights;

    return publicHighlights.where((h) {
      return (h.event?.title ?? '').toLowerCase().contains(query) ||
          (h.caption ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> fetchPublicHighlights({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final response = await _apiService.get(AppUrls.publicHighlights);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['data'];
        publicHighlights.value = list.map((e) => HighlightModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching public highlights: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  void changeMyEventTab(int tabIndex) {
    selectedMyEventTab.value = tabIndex;
    isOnboardingStripe.value = false;
    if (tabIndex < 2) {
      fetchMyEvents();
    } else if (tabIndex == 3) {
      fetchWallet();
      checkStripeStatus();
    }
  }

  List<TicketModel> get filteredTickets {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return tickets;

    return tickets.where((t) {
      return t.title.toLowerCase().contains(query);
    }).toList();
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

  void _loadMockTickets() {
    tickets.addAll([
      TicketModel(
        id: 't1',
        title: 'National Music Fest',
        imageUrl:
            'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3',
        price: 50.00,
        seats: 1,
      ),
      TicketModel(
        id: 't2',
        title: 'National Music Fest',
        imageUrl:
            'https://images.unsplash.com/photo-1514525253361-9f93ee74a89a',
        price: 50.00,
        seats: 1,
      ),
      TicketModel(
        id: 't3',
        title: 'National Music Fest',
        imageUrl:
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
        price: 50.00,
        seats: 1,
      ),
    ]);
  }

  void _loadMockTransactions() {
    transactions.clear();
  }

  Future<void> refreshData() async {
    if (selectedTab.value == 0) {
      await fetchEvents(showLoader: false);
    } else {
      if (selectedMyEventTab.value < 2) {
        await fetchMyEvents(showLoader: false);
      } else if (selectedMyEventTab.value == 3) {
        await fetchWallet();
        await checkStripeStatus();
      }
    }
  }
}
