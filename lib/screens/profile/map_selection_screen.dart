import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;

import '../../core/theme/app_colors.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  gmaps.GoogleMapController? googleMapController;
  amaps.AppleMapController? appleMapController;

  // Shared center coordinates
  final double _lat = 40.7128;
  final double _lng = -74.0060;

  void _onGoogleMapCreated(gmaps.GoogleMapController controller) {
    googleMapController = controller;
  }

  void _onAppleMapCreated(amaps.AppleMapController controller) {
    appleMapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map Background
          _buildMap(),

          // Back Button (Optimized)
          Positioned(
            top: 50.h,
            left: 20.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textHeading,
                  size: 20.sp,
                ),
              ),
            ),
          ),

          // Search Bar (Optimized)
          Positioned(
            top: 110.h,
            left: 24.w,
            right: 24.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              height: 58.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary, size: 22.sp),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search your location...",
                        hintStyle: GoogleFonts.inter(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.mic_none, color: Colors.grey[400], size: 22.sp),
                ],
              ),
            ),
          ),

          // Central Pin (Optimized)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 120.w,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                Container(
                  height: 24.w,
                  width: 24.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons (Optimized)
          Positioned(
            bottom: 130.h,
            right: 24.w,
            child: Column(
              children: [
                _buildActionButton(Icons.layers_outlined, () {}),
                SizedBox(height: 16.h),
                _buildActionButton(Icons.my_location, () {}),
              ],
            ),
          ),

          // Continue Button
          Positioned(
            bottom: 40.h,
            left: 24.w,
            right: 24.w,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF8E2DE2)],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Confirm Location",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (Platform.isAndroid) {
      return gmaps.GoogleMap(
        onMapCreated: _onGoogleMapCreated,
        initialCameraPosition: gmaps.CameraPosition(
          target: gmaps.LatLng(_lat, _lng),
          zoom: 13.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      );
    } else {
      return amaps.AppleMap(
        onMapCreated: _onAppleMapCreated,
        initialCameraPosition: amaps.CameraPosition(
          target: amaps.LatLng(_lat, _lng),
          zoom: 13.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
      );
    }
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.w,
        width: 48.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 22.sp),
      ),
    );
  }
}
