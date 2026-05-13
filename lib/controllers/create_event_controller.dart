import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../core/constants/app_endpoints.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import '../models/user_model.dart';
import '../core/utils/app_messenger.dart';
import 'base_controller.dart';

class CreateEventController extends BaseController {
  final ApiService _apiService = ApiService();

  // Form Fields
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final fbController = TextEditingController();
  final twitterController = TextEditingController();
  final locationController = TextEditingController();
  final seatsController = TextEditingController();
  final virtualLinkController = TextEditingController();
  final priceController = TextEditingController();

  var coverImagePath = ''.obs;
  var selectedCategory = RxnString();
  var selectedDate = Rxn<DateTime>();
  var selectedTime = Rxn<TimeOfDay>();
  var selectedEndTime = Rxn<TimeOfDay>();
  var isVirtual = false.obs;
  var isPaid = false.obs;
  var showPhone = true.obs;
  var showSocial = true.obs;
  var countryCode = '880'.obs;
  var countryFlag = '🇧🇩'.obs;

  // Interests State
  var allInterests = <Interest>[].obs;
  var selectedInterests = <String>[].obs; // Stores slugs
  var selectedInterestNames = <String>[].obs; // Stores names
  var isLoadingInterests = false.obs;

  // Interest Images related state
  var categoryImages = <String>[].obs;
  var isLoadingImages = false.obs;
  var selectedCoverImageUrl = RxnString();

  Map<String, List<Interest>> get interestsByCategory {
    final Map<String, List<Interest>> grouped = {};
    for (var interest in allInterests) {
      final category = _capitalizeCategory(interest.category);
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(interest);
    }
    return grouped;
  }

  String _capitalizeCategory(String category) {
    return category.split('-').map((word) => word.capitalizeFirst).join(' ');
  }

  String? get selectedInterestCategory {
    if (selectedInterests.isEmpty) return null;
    final firstSlug = selectedInterests.first;
    final interest = allInterests.firstWhereOrNull((i) => i.slug == firstSlug);
    return interest?.category;
  }

  // Location Data (Mocked or from Geolocator)
  var city = 'Dhaka'.obs;
  var country = 'Bangladesh'.obs;
  var venueName = 'BICC'.obs;
  var latitude = 23.7772.obs;
  var longitude = 90.3795.obs;

  var circleId = RxnString();
  var isLocating = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['isVirtual'] == true) {
        isVirtual.value = true;
      }
      if (args['category'] != null) {
        selectedCategory.value = args['category'];
        fetchEventInterestImages(args['category']);
      }
      if (args['circleId'] != null) {
        circleId.value = args['circleId'];
      }
    }
    fetchInterests();
    fetchSuggestedVenues();
  }

  Future<void> fetchInterests() async {
    try {
      isLoadingInterests.value = true;
      final response = await _apiService.get(AppUrls.getInterests);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> interestsJson = data['data'];
        allInterests.value = interestsJson
            .map((i) => Interest.fromJson(i))
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching interests: $e");
    } finally {
      isLoadingInterests.value = false;
    }
  }

  Future<void> fetchEventInterestImages(String category) async {
    try {
      isLoadingImages.value = true;
      final url = '${AppUrls.eventImages}?category=$category';
      final response = await _apiService.get(url);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> images = data['data']['images'];
        categoryImages.assignAll(
          images.map((i) => i['url'] as String).toList(),
        );
      }
    } catch (e) {
      debugPrint("Error fetching event interest images: $e");
    } finally {
      isLoadingImages.value = false;
    }
  }

  void toggleInterest(Interest interest) {
    final slug = interest.slug;
    final category = interest.category;

    if (selectedInterests.contains(slug)) {
      selectedInterests.remove(slug);
    } else {
      // Rule 1: Only single category allowed
      final currentCategory = selectedInterestCategory;
      if (currentCategory != null && currentCategory != category) {
        AppMessenger.warning(
          'You can only select interests from one category.',
          title: 'Limit Reached',
        );
        return;
      }

      // Rule 2: Max 2 interests
      if (selectedInterests.length >= 2) {
        AppMessenger.warning(
          'You can only select up to 2 interests.',
          title: 'Limit Reached',
        );
        return;
      }

      selectedInterests.add(slug);
    }
  }

  @override
  void onClose() {
    // searchController.dispose(); // Removed to prevent 'used after disposed' error
    super.onClose();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppMessenger.error('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppMessenger.error('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppMessenger.error(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return;
      }

      isLocating.value = true;

      // Try to get last known position first for speed
      Position? position = await Geolocator.getLastKnownPosition();

      // If no last known position or it's old, get current position with a timeout
      if (position == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
      }

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Reverse geocoding to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}";
        locationController.text = address;
        city.value = place.locality ?? 'Dhaka';
        country.value = place.country ?? 'Bangladesh';

        // Fetch suggested venues for this location
        fetchSuggestedVenues();
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      // If high accuracy fails/times out, try once more with low accuracy
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        // ... (can repeat reverse geocoding if needed, but let's keep it simple for now)
      } catch (_) {
        AppMessenger.error('Failed to get current location');
      }
    } finally {
      isLocating.value = false;
    }
  }

  // Suggested Venues related state
  var suggestedVenues = <Map<String, dynamic>>[].obs;
  var isLoadingVenues = false.obs;
  var selectedVenueIndex = (-1).obs;

  Future<void> fetchSuggestedVenues() async {
    try {
      isLoadingVenues.value = true;
      final token = SharedPrefsService.getString('accessToken');

      // Use current lat/lon from the controller (filled by getCurrentLocation)
      final url =
          '${AppUrls.events}/suggested-venues?lat=${latitude.value}&lon=${longitude.value}';

      final response = await _apiService.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        suggestedVenues.assignAll(
          List<Map<String, dynamic>>.from(data['data']),
        );
      }
    } catch (e) {
      debugPrint("Error fetching suggested venues: $e");
    } finally {
      isLoadingVenues.value = false;
    }
  }

  void selectVenue(int index) {
    if (index == selectedVenueIndex.value) {
      // Deselect
      selectedVenueIndex.value = -1;
      venueName.value = '';
      // Reset if needed, or keep what was typed
    } else {
      selectedVenueIndex.value = index;
      final venue = suggestedVenues[index];
      venueName.value = venue['venueName'] ?? '';
      locationController.text = venue['address'] ?? '';
      city.value = venue['city'] ?? '';
      country.value = venue['country'] ?? '';

      if (venue['location'] != null &&
          venue['location']['coordinates'] != null) {
        final coords = venue['location']['coordinates'];
        longitude.value = (coords[0] as num).toDouble();
        latitude.value = (coords[1] as num).toDouble();
      }
    }
  }

  Future<void> createEvent(BuildContext context) async {
    if (!_validateForm()) return;

    try {
      setLoading(true);

      final token = SharedPrefsService.getString('accessToken');

      // Prepare body
      String eventDate = "";
      String eventTime = "";
      if (selectedDate.value != null &&
          selectedTime.value != null &&
          selectedEndTime.value != null) {
        final d = selectedDate.value!;
        final start = selectedTime.value!;
        final end = selectedEndTime.value!;

        eventDate =
            "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

        final startH = start.hour.toString().padLeft(2, '0');
        final startM = start.minute.toString().padLeft(2, '0');
        final endH = end.hour.toString().padLeft(2, '0');
        final endM = end.minute.toString().padLeft(2, '0');

        eventTime = "$startH:$startM-$endH:$endM";
      }

      final bool isCircleEvent = circleId.value != null;

      final Map<String, dynamic> body = {
        "title": nameController.text,
        "description": descriptionController.text,
        "category": selectedCategory.value ?? 'Celebrations',
        "type": isVirtual.value ? "virtual" : "in-person",
        "eventDate": eventDate,
        "eventTime": eventTime,
        "totalSeats": int.tryParse(seatsController.text) ?? 100,
      };

      if (!isCircleEvent) {
        body["isPaid"] = isPaid.value;
        body["currency"] = "USD";
        body["phoneCountryCode"] = "+${countryCode.value}";
        body["phoneNumber"] = phoneController.text;
        body["showPhoneToAttendees"] = showPhone.value;
        body["facebookLink"] = fbController.text;
        body["twitterLink"] = twitterController.text;
        body["showSocialLinksToAttendees"] = showSocial.value;
      }

      if (!isVirtual.value) {
        body["address"] = locationController.text;
        body["location"] = {
          "longitude": longitude.value,
          "latitude": latitude.value,
          "address": locationController.text,
          "city": city.value,
          "country": country.value,
        };
        if (!isCircleEvent && venueName.value.isNotEmpty) {
          body["venueName"] = venueName.value;
        }
      }

      if (!isCircleEvent && isPaid.value) {
        body["ticketPrice"] = double.tryParse(priceController.text) ?? 0;
      }

      if (isVirtual.value) {
        body["virtualLink"] = virtualLinkController.text;
      }

      if (selectedCoverImageUrl.value != null) {
        body["coverImage"] = selectedCoverImageUrl.value;
      }

      final path = circleId.value != null
          ? AppUrls.circleEvents(circleId.value!)
          : AppUrls.events;
      final fullUrl = '${AppUrls.baseUrl}$path';

      http.Response response;

      if (coverImagePath.value.isEmpty) {
        // Use JSON POST if no file is picked
        response = await _apiService.post(path, body);
      } else {
        // Use Multipart if a file is picked
        final request = http.MultipartRequest('POST', Uri.parse(fullUrl));
        request.headers.addAll({'Authorization': 'Bearer $token'});

        // Add all fields from body to the request
        body.forEach((key, value) {
          if (value is Map || value is List) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });

        final file = File(coverImagePath.value);
        if (await file.exists()) {
          final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
          final mimeParts = mimeType.split('/');
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              file.path,
              contentType: MediaType(mimeParts[0], mimeParts[1]),
            ),
          );
        }

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      }

      debugPrint("Response Status: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        AppMessenger.success('Event created successfully');
        Get.offNamedUntil(AppRoutes.MAIN, (route) => false);
      } else {
        AppMessenger.error(data['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      debugPrint("Error creating event: $e");
      AppMessenger.showError(e);
    } finally {
      setLoading(false);
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      AppMessenger.error('Event name is required');
      return false;
    }
    if (selectedCategory.value == null) {
      AppMessenger.error('Category is required');
      return false;
    }
    if (selectedDate.value == null ||
        selectedTime.value == null ||
        selectedEndTime.value == null) {
      AppMessenger.error('Date, Start Time and End Time are required');
      return false;
    }
    final startMinutes =
        selectedTime.value!.hour * 60 + selectedTime.value!.minute;
    final endMinutes =
        selectedEndTime.value!.hour * 60 + selectedEndTime.value!.minute;
    if (endMinutes <= startMinutes) {
      AppMessenger.error('End time must be after start time');
      return false;
    }
    if (selectedCoverImageUrl.value == null && coverImagePath.value.isEmpty) {
      AppMessenger.error('Cover image is required');
      return false;
    }

    if (isVirtual.value) {
      if (virtualLinkController.text.isEmpty) {
        AppMessenger.error('Virtual link is required for virtual events');
        return false;
      }
    } else {
      if (seatsController.text.isEmpty) {
        AppMessenger.error('Total seats quantity is required');
        return false;
      }
      if (locationController.text.isEmpty) {
        AppMessenger.error('Address/Location is required');
        return false;
      }
      if (latitude.value == 0 || longitude.value == 0) {
        AppMessenger.error('Please pin a location on the map');
        return false;
      }
    }
    return true;
  }
}
