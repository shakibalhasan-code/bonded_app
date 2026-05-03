import 'dart:convert';
import 'dart:io';
import 'package:bonded_app/core/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


import 'base_controller.dart';
import '../services/api_service.dart';
import '../services/shared_prefs_service.dart';
import '../core/constants/app_endpoints.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class ProfileController extends BaseController {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  // Profile Building State
  var profileImagePath = ''.obs;
  var isLoadingProfile = false.obs;
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();
  var selectedCountryCode = '+1'.obs;
  var selectedCountryName = 'United States'.obs;
  var dateOfBirth = ''.obs;
  var selectedGender = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInterests();
    
    final authController = Get.find<AuthController>();
    
    // 1. Listen for user changes and update controllers automatically
    // This ensures that whenever the profile is fetched or updated, 
    // the edit fields reflect the latest data.
    ever(authController.currentUser, (UserModel? user) {
      if (user != null) {
        initializeControllers(user);
      }
    });

    // 2. Immediate initialization if data already exists
    if (authController.currentUser.value != null) {
      initializeControllers(authController.currentUser.value!);
    }
    
    // 3. Background refresh to ensure we have the absolute latest data
    authController.fetchUserProfile();
  }

  void initializeControllers(UserModel user) {
    fullNameController.text = user.fullName ?? '';
    usernameController.text = user.username ?? '';
    bioController.text = user.bio ?? '';
    phoneController.text = user.phone ?? '';
    selectedCountryCode.value = user.phoneCountryCode ?? '+1';
    // Format date of birth to YYYY-MM-DD if it's an ISO string
    if (user.dateOfBirth != null && user.dateOfBirth!.contains('T')) {
      try {
        final date = DateTime.parse(user.dateOfBirth!);
        dateOfBirth.value = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } catch (e) {
        dateOfBirth.value = user.dateOfBirth!;
      }
    } else {
      dateOfBirth.value = user.dateOfBirth ?? '';
    }

    final genderDisplayMap = {
      'male': 'Male',
      'female': 'Female',
      'non-binary': 'Non-Binary',
      'prefer-not-to-say': 'Prefer Not to Say'
    };
    selectedGender.value = genderDisplayMap[user.gender?.toLowerCase()] ?? 'Male';
    selectedCountry.value = user.country ?? 'United States of America';
    selectedCity.value = user.city ?? 'New Jersey';
    cityController.text = user.city ?? '';
    currentAddress.value = user.address ?? '';
    latitude.value = user.location?.coordinates[1] ?? 0.0;
    longitude.value = user.location?.coordinates[0] ?? 0.0;

    selectedInterests.clear();
    if (user.interests != null) {
      selectedInterests.addAll(user.interests!.map((e) => e.slug));
    }

    selectedConnectionTypes.clear();
    if (user.connectionType != null) {
      for (var typeSlug in user.connectionType!) {
        // Special case for one-on-one-friendship and plurals
        String displayName;
        if (typeSlug == 'one_on_one_friendship') {
          displayName = 'One-on-One Friendship';
        } else if (typeSlug == 'event_based_meetups') {
          displayName = 'Event Based Meetups';
        } else {
          displayName = typeSlug
              .split('_')
              .map((word) => word.capitalizeFirst)
              .join(' ');
        }
        selectedConnectionTypes.add(displayName);
      }
    }

    notificationsEnabled.value = user.preferences?.notifications ?? true;
  }

  Future<void> refreshProfileData() async {
    try {
      isLoadingProfile.value = true;
      final authController = Get.find<AuthController>();
      await authController.fetchUserProfile();
      // initializeControllers will be called by 'ever' listener
    } finally {
      isLoadingProfile.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.onClose();
  }

  // Validation Errors
  var fullNameError = ''.obs;
  var usernameError = ''.obs;
  var phoneError = ''.obs;

  // Location State
  var selectedCountry = 'United States of America'.obs;
  var selectedCity = 'New Jersey'.obs;
  var currentAddress = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var isLoadingLocation = false.obs;

  // Interests State
  var allInterests = <Interest>[].obs;
  var selectedInterests = <String>[].obs; // Stores slugs
  var isLoadingInterests = false.obs;

  // Connection Type State
  var selectedConnectionTypes = <String>[].obs;

  // Verification & KYC State
  var verificationImagePath = ''.obs;
  var kycFrontPath = ''.obs;
  var kycBackPath = ''.obs;

  // New Profile UI States
  var notificationsEnabled = true.obs;
  var selectedConnectionType = 'Networking'.obs;

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

  Future<void> fetchInterests() async {
    try {
      isLoadingInterests.value = true;
      final response = await _apiService.get(AppUrls.getInterests);
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> interestsJson = data['data'];
        allInterests.value = interestsJson.map((i) => Interest.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching interests: $e");
    } finally {
      isLoadingInterests.value = false;
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImagePath.value = image.path;
    }
  }

  Future<void> pickVerificationImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      verificationImagePath.value = image.path;
    }
  }

  Future<void> captureSelfie() async {
    await pickVerificationImage(ImageSource.camera);
  }

  Future<void> pickKycImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (isFront) {
        kycFrontPath.value = image.path;
      } else {
        kycBackPath.value = image.path;
      }
    }
  }

  Future<void> fetchCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Disabled',
          'Please enable location services in your device settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isLoadingLocation.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permissions are required to fetch your address.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          isLoadingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Restricted',
          'Location permissions are permanently denied. Please enable them in settings.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        isLoadingLocation.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}"
                .trim()
                .replaceAll(RegExp(r'^, |, $'), '');
        selectedCountry.value = place.country ?? selectedCountry.value;
        cityController.text = place.locality ?? '';
        selectedCity.value = place.locality ?? selectedCity.value;
        latitude.value = position.latitude;
        longitude.value = position.longitude;
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
      Get.snackbar(
        'Error',
        'Could not fetch location. Please try manual entry.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  bool validateProfileFields() {
    bool isValid = true;
    if (fullNameController.text.isEmpty) {
      fullNameError.value = "Full name is required";
      isValid = false;
    } else {
      fullNameError.value = "";
    }

    if (usernameController.text.isEmpty) {
      usernameError.value = "Username is required";
      isValid = false;
    } else {
      usernameError.value = "";
    }

    if (phoneController.text.isEmpty) {
      phoneError.value = "Phone number is required";
      isValid = false;
    } else {
      phoneError.value = "";
    }

    if (selectedInterests.length < 5) {
      Get.snackbar('Interests Required', 'Please select at least 5 interests', backgroundColor: Colors.orange, colorText: Colors.white);
      isValid = false;
    }

    if (selectedInterests.length > 10) {
      Get.snackbar('Too Many Interests', 'You can select up to 10 interests', backgroundColor: Colors.orange, colorText: Colors.white);
      isValid = false;
    }

    if (selectedConnectionTypes.isEmpty) {
      Get.snackbar('Connection Type Required', 'Please select at least one connection type', backgroundColor: Colors.orange, colorText: Colors.white);
      isValid = false;
    }

    return isValid;
  }

  void toggleInterest(String slug) {
    if (selectedInterests.contains(slug)) {
      selectedInterests.remove(slug);
    } else {
      selectedInterests.add(slug);
    }
  }

  void toggleConnectionType(String type) {
    if (selectedConnectionTypes.contains(type)) {
      selectedConnectionTypes.remove(type);
    } else {
      selectedConnectionTypes.add(type);
    }
  }

  // Update Profile API Call
  Future<void> updateProfile({bool isInitialFlow = true}) async {
    if (!validateProfileFields()) return;
    
    try {
      setLoading(true);
      final authController = Get.find<AuthController>();
      final user = authController.currentUser.value;

      // 1. Upload Avatar first if available
      if (profileImagePath.value.isNotEmpty) {
        final avatarSuccess = await updateAvatar();
        if (!avatarSuccess) {
          Get.snackbar('Error', 'Failed to upload profile picture');
          setLoading(false);
          return;
        }
      }

      // 2. Prepare Partial Body
      final token = SharedPrefsService.getString('accessToken');
      final body = <String, dynamic>{};

      if (fullNameController.text != user?.fullName) body["fullName"] = fullNameController.text;
      if (usernameController.text != user?.username) body["username"] = usernameController.text;
      if (bioController.text != user?.bio) body["bio"] = bioController.text;
      // Handle Phone & Country Code (Must be provided together per backend schema)
      bool phoneChanged = phoneController.text != user?.phone;
      bool countryCodeChanged = selectedCountryCode.value != user?.phoneCountryCode;

      if (phoneChanged || countryCodeChanged) {
        body["phone"] = phoneController.text;
        body["phoneCountryCode"] = selectedCountryCode.value;
      }
      
      // Compare Date of Birth
      String? userDOB;
      if (user?.dateOfBirth != null && user!.dateOfBirth!.contains('T')) {
        try {
          final date = DateTime.parse(user.dateOfBirth!);
          userDOB = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        } catch (_) {}
      } else {
        userDOB = user?.dateOfBirth;
      }
      if (dateOfBirth.value != userDOB) body["dateOfBirth"] = dateOfBirth.value;

      final genderMap = {
        'Male': 'male',
        'Female': 'female',
        'Non-Binary': 'non-binary',
        'Prefer Not to Say': 'prefer-not-to-say'
      };
      final genderVal = genderMap[selectedGender.value] ?? selectedGender.value.toLowerCase();
      if (genderVal != user?.gender?.toLowerCase()) body["gender"] = genderVal;
      
      if (selectedCountry.value != user?.country) body["country"] = selectedCountry.value;
      if (cityController.text != user?.city) body["city"] = cityController.text;
      
      if (currentAddress.value != user?.address) body["address"] = currentAddress.value;

      // Location Comparison (New Backend Format: {longitude, latitude})
      final currentLat = user?.location?.coordinates[1];
      final currentLng = user?.location?.coordinates[0];
      if (latitude.value != currentLat || longitude.value != currentLng) {
        body["location"] = {
          "longitude": longitude.value,
          "latitude": latitude.value
        };
      }

      // Connection Types
      final connectionTypeSlugs = selectedConnectionTypes
          .map((e) => e.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_'))
          .map((e) => e == 'event_based_meetup' ? 'event_based_meetups' : e) // Align with plural in backend
          .toList()..sort();
      final userConnectionTypes = (user?.connectionType ?? <String>[]).toList()..sort();
      
      if (!listEquals(connectionTypeSlugs, userConnectionTypes)) {
        body["connectionType"] = connectionTypeSlugs;
      }

      // Interests
      final interestsSlugs = selectedInterests.toList()..sort();
      final userInterestsSlugs = (user?.interests?.map((e) => e.slug).toList() ?? <String>[])..sort();
      
      if (!listEquals(interestsSlugs, userInterestsSlugs)) {
        body["interests"] = interestsSlugs;
      }

      if (body.isEmpty && profileImagePath.value.isEmpty) {
        setLoading(false);
        if (!isInitialFlow) Get.back();
        return;
      }

      final response = await _apiService.patch(
        AppUrls.updateProfile,
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Update global user state
        final authController = Get.find<AuthController>();
        authController.currentUser.value = UserModel.fromJson(data['data']['user']);

        Get.snackbar(
          'Success',
          data['message'] ?? 'Profile updated successfully',
        );
        
        if (isInitialFlow) {
          Get.offAllNamed(AppRoutes.KYC_DOCUMENT);
        } else {
          Get.back();
        }
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setLoading(false);
    }
  }

  // Update Avatar API Call
  Future<bool> updateAvatar() async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      final file = File(profileImagePath.value);

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        file.path,
        contentType: MediaType(
          mimeParts.first,
          mimeParts.length > 1 ? mimeParts[1] : 'jpeg',
        ),
      );

      final response = await _apiService.multipartRequest(
        'PATCH',
        AppUrls.updateAvatar,
        headers: {'Authorization': 'Bearer $token'},
        files: [multipartFile], // ✅ now correct type
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        // Update global user state with new avatar
        final authController = Get.find<AuthController>();
        authController.currentUser.value = UserModel.fromJson(data['data']['user']);
      }
      return data['success'] == true;
    } catch (e) {
      debugPrint("Error updating avatar: $e");
      return false;
    }
  }

  Future<void> uploadPickedAvatar() async {
    if (profileImagePath.value.isEmpty) return;
    
    setLoading(true);
    final success = await updateAvatar();
    setLoading(false);

    if (success) {
      profileImagePath.value = '';
      Get.snackbar('Success', 'Profile picture updated successfully');
    } else {
      Get.snackbar('Error', 'Failed to upload profile picture');
    }
  }

  Future<void> updatePreferences({bool? notifications, bool? emailUpdates, bool? locationSharing}) async {
    try {
      final token = SharedPrefsService.getString('accessToken');
      final body = {
        "preferences": {
          if (notifications != null) "notifications": notifications,
          if (emailUpdates != null) "emailUpdates": emailUpdates,
          if (locationSharing != null) "locationSharing": locationSharing,
        }
      };

      final response = await _apiService.patch(
        AppUrls.updateProfile,
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final authController = Get.find<AuthController>();
        authController.currentUser.value = UserModel.fromJson(data['data']['user']);
        if (notifications != null) notificationsEnabled.value = notifications;
      }
    } catch (e) {
      debugPrint("Error updating preferences: $e");
    }
  }
}
