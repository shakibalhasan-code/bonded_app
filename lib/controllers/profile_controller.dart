import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

import 'base_controller.dart';

class ProfileController extends BaseController {
  final ImagePicker _picker = ImagePicker();
  
  // Profile Building State
  var profileImagePath = ''.obs;
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();
  var selectedCountryCode = '+1'.obs;
  var selectedCountryName = 'United States'.obs;
  var dateOfBirth = ''.obs;
  var selectedGender = ''.obs;

  // Validation Errors
  var fullNameError = ''.obs;
  var usernameError = ''.obs;
  var phoneError = ''.obs;

  // Location State
  var selectedCountry = 'United States of America'.obs;
  var selectedCity = 'New Jersey'.obs;
  var currentAddress = ''.obs;
  var isLoadingLocation = false.obs;

  // Interests State
  var selectedInterests = <String>[].obs;

  // Connection Type State
  var selectedConnectionType = 'One-on-One Friendship'.obs;

  // Verification & KYC State
  var verificationImagePath = ''.obs;
  var kycFrontPath = ''.obs;
  var kycBackPath = ''.obs;

  // New Profile UI States
  var notificationsEnabled = true.obs;
  var profileVisibility = 'Public'.obs;
  var availableInterests = [
    "Brunch Lovers", "Wine Nights", "Game Nights", "Movie Lovers",
    "Foodies", "Coffee Dates", "Picnic & Outdoor Chill", "Book Clubs",
    "Fashion & Style", "Pet Lovers", "Photography"
  ].obs;

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
        currentAddress.value = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}".trim().replaceAll(RegExp(r'^, |, $'), '');
        selectedCountry.value = place.country ?? selectedCountry.value;
        selectedCity.value = place.locality ?? selectedCity.value;
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

    return isValid;
  }

  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }
}
