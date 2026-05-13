import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
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
  final RxList<BookedEventModel> bookedEvents = <BookedEventModel>[].obs;
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
  final RxnDouble lat = RxnDouble();
  final RxnDouble lng = RxnDouble();
  final RxBool isLocationLoading = false.obs;

  // Search
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  void updateSearch(String query) => searchQuery.value = query.trim();
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
    fetchEvents();
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
    // searchController.dispose();
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

  final RxBool isFilterApplied = false.obs;

  void applyFilters() {
    isFilterApplied.value = true;
    fetchEvents();
  }

  Future<void> fetchEvents({
    bool showLoader = true,
    String? searchTerm,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (showLoader) isLoading.value = true;

      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add Search Term
      final actualSearch = searchTerm ?? searchController.text;
      if (actualSearch.isNotEmpty) {
        queryParams['searchTerm'] = actualSearch;
      }

      if (isFilterApplied.value) {
        // Add Price Range
        if (priceRange.value.start > 0 || priceRange.value.end < 100) {
          queryParams['minPrice'] = priceRange.value.start.round().toString();
          queryParams['maxPrice'] = priceRange.value.end.round().toString();
        }

        // Add Distance/Location
        queryParams['radiusKm'] = distanceRange.value.end.round().toString();

        // Use dynamic location if available
        if (lat.value != null && lng.value != null) {
          queryParams['lat'] = lat.value.toString();
          queryParams['lng'] = lng.value.toString();
        }

        // Add Date Filters
        if (selectedDate.value != null) {
          final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate.value!);
          queryParams['startDate'] = dateStr;
          queryParams['endDate'] = DateFormat('dd/MM/yyyy').format(selectedDate.value!.add(const Duration(days: 30)));
        }

        // Add Time Filters
        if (selectedTime.value != null) {
          final timeStr = "${selectedTime.value!.hour.toString().padLeft(2, '0')}:${selectedTime.value!.minute.toString().padLeft(2, '0')}";
          queryParams['startTime'] = timeStr;
          queryParams['endTime'] = "23:59"; // Default end time
        }

        // Add Category Filters
        if (activeFilterCategories.isNotEmpty) {
          queryParams['category'] = activeFilterCategories.join(',');
        }
      }

      // Build Query String
      final uri = Uri(queryParameters: queryParams);
      final url =
          "${AppUrls.events}${uri.query.isEmpty ? '' : '?${uri.query}'}";

      debugPrint("Fetching events with URL: $url");

      final response = await _apiService.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> eventList = data['data'];
        final List<EventModel> fetchedEvents = eventList
            .map((e) => EventModel.fromJson(e))
            .toList();

        if (fetchedEvents.every(
          (e) => e.category != EventCategory.highlights,
        )) {
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
        base = events
            .where((e) => e.category == EventCategory.inPerson)
            .toList();
      } else if (selectedCategory.value == 1) {
        base = events
            .where((e) => e.category == EventCategory.virtual)
            .toList();
      } else if (selectedCategory.value == 2) {
        base = events
            .where((e) => e.category == EventCategory.highlights)
            .toList();
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
        publicHighlights.value = list
            .map((e) => HighlightModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching public highlights: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> fetchBookedEvents({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final response = await _apiService.get(AppUrls.bookedEvents);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['data'] ?? [];
        bookedEvents.value = list
            .map((e) => BookedEventModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching booked events: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> fetchTickets({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      final response = await _apiService.get(AppUrls.myTickets);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> list = data['data'] ?? [];
        tickets.value = list.map((e) => TicketModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  void changeMyEventTab(int tabIndex) {
    selectedMyEventTab.value = tabIndex;
    isOnboardingStripe.value = false;
    if (tabIndex == 0) {
      fetchMyEvents();
    } else if (tabIndex == 1) {
      fetchBookedEvents();
    } else if (tabIndex == 2) {
      fetchTickets();
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
    isFilterApplied.value = false;
  }

  void toggleFilterCategory(String category) {
    if (activeFilterCategories.contains(category)) {
      activeFilterCategories.remove(category);
    } else {
      activeFilterCategories.add(category);
    }
  }

  void _loadMockTickets() {
    // tickets.addAll([...]); // Removed as real API is used
  }

  void _loadMockTransactions() {
    transactions.clear();
  }

  Future<void> refreshData() async {
    if (selectedTab.value == 0) {
      await fetchEvents(showLoader: false);
    } else {
      if (selectedMyEventTab.value == 0) {
        await fetchMyEvents(showLoader: false);
      } else if (selectedMyEventTab.value == 1) {
        await fetchBookedEvents(showLoader: false);
      } else if (selectedMyEventTab.value == 2) {
        await fetchTickets(showLoader: false);
      } else if (selectedMyEventTab.value == 3) {
        await fetchWallet();
        await checkStripeStatus();
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Error", "Location services are disabled.");
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Error", "Location permissions are denied.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Error", "Location permissions are permanently denied.");
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      lat.value = position.latitude;
      lng.value = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        selectedLocation.value = "${pm.street}, ${pm.locality}, ${pm.country}";
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      Get.snackbar("Error", "Failed to get current location.");
    } finally {
      isLocationLoading.value = false;
    }
  }
}
