import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  String? _coverImagePath;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _fbController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _virtualLinkController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isVirtual = false;
  bool _showPhone = true;
  bool _showSocial = true;
  String? _selectedCategory;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isPaid = false;

  final List<String> _categories = [
    "Birthday Celebration",
    "Graduation",
    "Anniversary",
  ];
  final List<String> _suggestedVenues = [
    "Grand Place Hotel",
    "Sonny Restaurant",
    "Redfin Hotel",
    "Dreams Restaurant",
    "Five Star Hotel",
  ];
  final Set<String> _addedVenues = {};

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['isVirtual'] == true) {
        _isVirtual = true;
      }
      if (args['category'] != null && _categories.contains(args['category'])) {
        _selectedCategory = args['category'];
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _coverImagePath = pickedFile.path);
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
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
          "Create Event",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9FF),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: _coverImagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.grey[400],
                            size: 48.sp,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Add event cover image",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1B0B3B),
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: Image.file(
                          File(_coverImagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 24.h),

            _buildLabel("Event Name"),
            _buildTextField(_nameController, "Event Name"),
            SizedBox(height: 24.h),

            _buildLabel("Description"),
            _buildTextField(
              _descriptionController,
              "Description...",
              maxLines: 4,
            ),
            SizedBox(height: 24.h),

            _buildLabel("Phone Number"),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "🇺🇸 +1",
                        style: GoogleFonts.inter(fontSize: 14.sp),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(child: _buildTextField(_phoneController, "1234567")),
              ],
            ),
            SizedBox(height: 24.h),

            _buildLabel("Add Social Media Links"),
            _buildSocialInput(
              Icons.facebook,
              _fbController,
              "Add Facebook Link",
              Colors.blue,
            ),
            SizedBox(height: 12.h),
            _buildSocialInput(
              Icons.alternate_email,
              _twitterController,
              "Add Twitter Link",
              Colors.lightBlue,
            ),
            SizedBox(height: 24.h),

            _buildLabel("Show phone number to attendees?"),
            Row(
              children: [
                _buildRadioButton(
                  "Yes",
                  _showPhone,
                  (val) => setState(() => _showPhone = true),
                ),
                SizedBox(width: 24.w),
                _buildRadioButton(
                  "No",
                  !_showPhone,
                  (val) => setState(() => _showPhone = false),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            _buildLabel("Show social media links to attendees?"),
            Row(
              children: [
                _buildRadioButton(
                  "Yes",
                  _showSocial,
                  (val) => setState(() => _showSocial = true),
                ),
                SizedBox(width: 24.w),
                _buildRadioButton(
                  "No",
                  !_showSocial,
                  (val) => setState(() => _showSocial = false),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            _buildLabel("Event Category"),
            _buildDropdown(),
            SizedBox(height: 24.h),

            _buildLabel("Date"),
            _buildPickerField(
              _selectedDate == null
                  ? "DD/MM/YYYY"
                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
              Icons.calendar_month_outlined,
              _selectDate,
            ),
            SizedBox(height: 24.h),

            _buildLabel("Time"),
            _buildPickerField(
              _selectedTime == null
                  ? "HH:MM"
                  : "${_selectedTime!.format(context)}",
              Icons.access_time,
              _selectTime,
            ),
            SizedBox(height: 24.h),

            if (!_isVirtual) ...[
              _buildLabel("Location"),
              _buildLocationField(),
              SizedBox(height: 24.h),

              _buildLabel("Suggested Venues"),
              SizedBox(height: 12.h),
              ..._suggestedVenues.map((v) => _buildVenueItem(v)).toList(),
              SizedBox(height: 24.h),
            ],

            if (_isVirtual) ...[
              _buildLabel("Add Virtual Link"),
              _buildTextField(_virtualLinkController, "Enter Link"),
              SizedBox(height: 24.h),
            ],

            Row(
              children: [
                Checkbox(
                  value: _isPaid,
                  onChanged: (val) => setState(() => _isPaid = val!),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Text(
                  "Is this a Paid event?",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B0B3B),
                  ),
                ),
              ],
            ),
            if (_isPaid) ...[
              SizedBox(height: 24.h),
              _buildLabel("Ticket Price"),
              _buildTextField(_priceController, "Ticket price"),
            ],
            SizedBox(height: 24.h),

            if (!_isVirtual) ...[
              _buildLabel("Available Seats Quantity"),
              _buildTextField(_seatsController, "Available seats"),
            ],
            SizedBox(height: 48.h),

            ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.EVENT_KYC),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.05),
                foregroundColor: AppColors.primary,
                elevation: 0,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Continue",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1B0B3B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSocialInput(
    IconData icon,
    TextEditingController controller,
    String hint,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _buildTextField(controller, hint)),
      ],
    );
  }

  Widget _buildRadioButton(
    String label,
    bool isSelected,
    Function(bool?)? onChanged,
  ) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: isSelected,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          hint: Text(
            "Dropdown to select",
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[400]),
          ),
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }

  Widget _buildPickerField(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FF),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[400],
              ),
            ),
            Icon(icon, color: AppColors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _locationController,
        decoration: InputDecoration(
          hintText: "Location",
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[400],
          ),
          suffixIcon: Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: 20.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildVenueItem(String venue) {
    bool isAdded = _addedVenues.contains(venue);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            venue,
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          SizedBox(
            height: 32.h,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  if (isAdded)
                    _addedVenues.remove(venue);
                  else
                    _addedVenues.add(venue);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdded ? Colors.green : Colors.white,
                foregroundColor: isAdded ? Colors.white : AppColors.primary,
                side: BorderSide(
                  color: isAdded ? Colors.green : AppColors.primary,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                isAdded ? "Added" : "Add",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
