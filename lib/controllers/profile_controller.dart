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

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImagePath.value = image.path;
    }
  }

  Future<void> fetchCurrentLocation() async {
    isLoadingLocation.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('Error', 'Location services are disabled.');
        isLoadingLocation.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Error', 'Location permissions are denied');
          isLoadingLocation.value = false;
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        currentAddress.value = "${place.street}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}";
        selectedCountry.value = place.country ?? selectedCountry.value;
        selectedCity.value = place.locality ?? selectedCity.value;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch location: $e');
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
