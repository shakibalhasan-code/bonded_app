import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_details_controller.dart';

class BookEventFormScreen extends StatefulWidget {
  final int seats;
  final String eventId;

  const BookEventFormScreen({
    Key? key,
    required this.seats,
    required this.eventId,
  }) : super(key: key);

  @override
  State<BookEventFormScreen> createState() => _BookEventFormScreenState();
}

class _BookEventFormScreenState extends State<BookEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventDetailsController _eventDetailsController = Get.find<EventDetailsController>();
  final AuthController _authController = Get.find<AuthController>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;
  late TextEditingController _locationController;
  String _selectedGender = 'Male';
  bool _acceptTerms = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser.value;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _dobController = TextEditingController(text: user?.dateOfBirth ?? '');
    _selectedGender = user?.gender != null && user!.gender!.isNotEmpty 
        ? user.gender!.capitalizeFirst! 
        : 'Male';
    _countryController = TextEditingController(text: user?.country ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _locationController = TextEditingController(text: user?.address ?? '');

    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _countryController.text = place.country ?? _countryController.text;
            _cityController.text = place.locality ?? _cityController.text;
            _locationController.text = "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}".trim();
            if (_locationController.text.startsWith(',')) {
               _locationController.text = _locationController.text.substring(1).trim();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        Get.snackbar("Error", "Please accept the Terms of Service to continue.");
        return;
      }
      
      final bookingData = {
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'gender': _selectedGender,
        'country': _countryController.text,
        'city': _cityController.text,
        'location': _locationController.text,
        'seats': widget.seats,
      };

      _eventDetailsController.bookEvent(widget.eventId, data: bookingData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0B3B)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Book Event",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
          onPressed: _eventDetailsController.isBooking.value ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          child: _eventDetailsController.isBooking.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  "Continue",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        )),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                "Contact Information",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B0B3B),
                ),
              ),
              SizedBox(height: 24.h),

              _buildTextField("Full Name", _fullNameController, "Enter your full name"),
              _buildTextField("Phone Number", _phoneController, "Enter your phone number", keyboardType: TextInputType.phone),
              _buildTextField("Date of Birth", _dobController, "DD/MM/YYYY"),

              // Gender Dropdown
              _buildLabel("Gender"),
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: GoogleFonts.inter(fontSize: 14.sp)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                  ),
                ),
              ),

              _buildTextField("Country", _countryController, "Enter your country"),
              _buildTextField("City", _cityController, "Enter your city"),

              _buildLabel("Location"),
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                child: TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: "Enter your location",
                    hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14.sp),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    suffixIcon: _isLoadingLocation 
                        ? Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(width: 20, height: 20, child: const CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : Icon(Icons.location_on, color: AppColors.primary),
                  ),
                  validator: (val) => val!.isEmpty ? "Required field" : null,
                ),
              ),

              // Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24.h,
                    width: 24.w,
                    child: Checkbox(
                      value: _acceptTerms,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          _acceptTerms = val ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[600], height: 1.5),
                        children: [
                          const TextSpan(text: "I accept the Bonded "),
                          TextSpan(
                            text: "Terms of Service",
                            style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ", and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: " (required.)"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1B0B3B),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14.sp),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            validator: (val) => val!.isEmpty ? "Required field" : null,
          ),
        ),
      ],
    );
  }
}
