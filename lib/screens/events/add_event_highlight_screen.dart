import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/event_model.dart';
import '../../controllers/event_details_controller.dart';
import '../../controllers/circle_controller.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_endpoints.dart';

class AddEventHighlightScreen extends StatefulWidget {
  const AddEventHighlightScreen({Key? key}) : super(key: key);

  @override
  State<AddEventHighlightScreen> createState() =>
      _AddEventHighlightScreenState();
}

class _AddEventHighlightScreenState extends State<AddEventHighlightScreen> {
  static const int _maxVideos = 10;
  static const int _maxImages = 15;

  late final EventModel _event;
  late final EventDetailsController _detailsController;
  late final CircleController _circleController;
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  // null = empty slot, non-null = picked file
  final List<XFile?> _videoSlots = [null, null, null];
  final List<XFile?> _imageSlots = [null, null, null];

  final List<String> _selectedAttendeeIds = [];
  final List<String> _selectedCircleIds = [];
  final List<Map<String, String>> _bonds = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _event = Get.arguments as EventModel;
    _detailsController = Get.isRegistered<EventDetailsController>()
        ? Get.find<EventDetailsController>()
        : Get.put(EventDetailsController());
    _circleController = Get.isRegistered<CircleController>()
        ? Get.find<CircleController>()
        : Get.put(CircleController());
    _loadBonds();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadBonds() async {
    try {
      final response = await _apiService.get(AppUrls.myBonds);
      final data = jsonDecode(response.body);
      if (data['success'] == true && mounted) {
        final list = (data['data'] as List?) ?? [];
        setState(() {
          _bonds.clear();
          for (final item in list) {
            final user = item['user'] ?? item['bondUser'] ?? item;
            final id = (user['_id'] ?? user['id'] ?? '').toString();
            final name = (user['fullName'] ?? user['name'] ?? 'Unknown').toString();
            if (id.isNotEmpty) _bonds.add({'id': id, 'name': name});
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _pickVideoForSlot(int index) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null && mounted) {
      setState(() => _videoSlots[index] = video);
    }
  }

  Future<void> _pickImageForSlot(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _imageSlots[index] = image);
    }
  }

  void _addVideoSlot() {
    if (_videoSlots.length >= _maxVideos) {
      Get.snackbar('Limit Reached', 'Maximum $_maxVideos videos allowed');
      return;
    }
    setState(() => _videoSlots.add(null));
  }

  void _addImageSlot() {
    if (_imageSlots.length >= _maxImages) {
      Get.snackbar('Limit Reached', 'Maximum $_maxImages images allowed');
      return;
    }
    setState(() => _imageSlots.add(null));
  }

  bool get _hasMedia =>
      _videoSlots.any((s) => s != null) || _imageSlots.any((s) => s != null);

  Future<void> _submit() async {
    if (!_hasMedia) {
      Get.snackbar('Error', 'Please add at least one photo or video',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final success = await _detailsController.createHighlight(
        eventId: _event.id,
        caption: _captionController.text.trim(),
        imagePaths:
            _imageSlots.whereType<XFile>().map((f) => f.path).toList(),
        videoPaths:
            _videoSlots.whereType<XFile>().map((f) => f.path).toList(),
        taggedAttendees:
            _selectedAttendeeIds.isEmpty ? null : List.from(_selectedAttendeeIds),
        taggedCircles:
            _selectedCircleIds.isEmpty ? null : List.from(_selectedCircleIds),
      );
      if (success && mounted) {
        Get.back();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMultiSelectSheet({
    required String title,
    required List<MapEntry<String, String>> options,
    required List<String> currentSelected,
    required void Function(List<String>) onConfirm,
  }) {
    final temp = List<String>.from(currentSelected);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (_, scrollCtrl) => Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B0B3B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onConfirm(temp);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.h),
              if (options.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No options available',
                      style: GoogleFonts.inter(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: options.length,
                    itemBuilder: (_, i) {
                      final option = options[i];
                      final isSelected = temp.contains(option.key);
                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          option.value,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: const Color(0xFF1B0B3B),
                          ),
                        ),
                        onChanged: (checked) {
                          setModal(() {
                            if (checked == true) {
                              if (!temp.contains(option.key)) {
                                temp.add(option.key);
                              }
                            } else {
                              temp.remove(option.key);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
          'Add Event Highlights',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Event Name'),
            SizedBox(height: 8.h),
            _buildReadOnlyField(_event.title),
            SizedBox(height: 24.h),

            _buildLabel('Add Video Highlights (max $_maxVideos shorts)'),
            SizedBox(height: 12.h),
            _buildMediaGrid(isVideo: true),
            SizedBox(height: 10.h),
            _buildAddMoreButton(
              enabled: _videoSlots.length < _maxVideos,
              onTap: _addVideoSlot,
            ),
            SizedBox(height: 24.h),

            _buildLabel('Add Images (max $_maxImages)'),
            SizedBox(height: 12.h),
            _buildMediaGrid(isVideo: false),
            SizedBox(height: 10.h),
            _buildAddMoreButton(
              enabled: _imageSlots.length < _maxImages,
              onTap: _addImageSlot,
            ),
            SizedBox(height: 24.h),

            _buildLabel('Caption'),
            SizedBox(height: 8.h),
            _buildCaptionField(),
            SizedBox(height: 24.h),

            _buildLabel('Tag Attendees'),
            SizedBox(height: 8.h),
            _buildDropdownButton(
              selectedIds: _selectedAttendeeIds,
              nameMap: Map.fromEntries(
                _bonds.map((b) => MapEntry(b['id']!, b['name']!)),
              ),
              placeholder: 'Dropdown to select',
              onTap: () => _showMultiSelectSheet(
                title: 'Tag Attendees',
                options: _bonds
                    .map((b) => MapEntry(b['id']!, b['name']!))
                    .toList(),
                currentSelected: _selectedAttendeeIds,
                onConfirm: (selected) => setState(() {
                  _selectedAttendeeIds
                    ..clear()
                    ..addAll(selected);
                }),
              ),
            ),
            SizedBox(height: 16.h),

            _buildLabel('Tag Circle'),
            SizedBox(height: 8.h),
            Obx(() {
              final circles = _circleController.joinedCircles;
              final nameMap = Map.fromEntries(
                circles.map((c) => MapEntry(c.id, c.name)),
              );
              return _buildDropdownButton(
                selectedIds: _selectedCircleIds,
                nameMap: nameMap,
                placeholder: 'Dropdown to select',
                onTap: () => _showMultiSelectSheet(
                  title: 'Tag Circle',
                  options: circles
                      .map((c) => MapEntry(c.id, c.name))
                      .toList(),
                  currentSelected: _selectedCircleIds,
                  onConfirm: (selected) => setState(() {
                    _selectedCircleIds
                      ..clear()
                      ..addAll(selected);
                  }),
                ),
              );
            }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1B0B3B),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildMediaGrid({required bool isVideo}) {
    final slots = isVideo ? _videoSlots : _imageSlots;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          slots.length,
          (i) => isVideo ? _buildVideoSlot(i) : _buildImageSlot(i),
        ),
      ),
    );
  }

  Widget _buildVideoSlot(int index) {
    final file = _videoSlots[index];
    return GestureDetector(
      onTap: file == null ? () => _pickVideoForSlot(index) : null,
      child: Container(
        width: 100.w,
        height: 120.h,
        margin: EdgeInsets.only(right: 12.w),
        child: CustomPaint(
          foregroundPainter: file == null
              ? _DashedBorderPainter(
                  color: AppColors.primary,
                  radius: 12.r,
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: file == null
                ? Container(
                    color: const Color(0xFFF5F0FF),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle,
                            color: AppColors.primary, size: 28.sp),
                        SizedBox(height: 6.h),
                        Text(
                          'Upload\nShort',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Max 30 sec',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFF2D1B5E),
                        child: Icon(
                          Icons.play_circle_filled,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 36.sp,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _videoSlots[index] = null),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlot(int index) {
    final file = _imageSlots[index];
    return GestureDetector(
      onTap: file == null ? () => _pickImageForSlot(index) : null,
      child: Container(
        width: 100.w,
        height: 100.h,
        margin: EdgeInsets.only(right: 12.w),
        child: CustomPaint(
          foregroundPainter: file == null
              ? _DashedBorderPainter(
                  color: AppColors.primary,
                  radius: 12.r,
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: file == null
                ? Container(
                    color: const Color(0xFFF5F0FF),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle,
                            color: AppColors.primary, size: 28.sp),
                        SizedBox(height: 6.h),
                        Text(
                          'Upload\nImage',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _imageSlots[index] = null),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                                color: Colors.white, size: 14.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMoreButton({
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFF1B0B3B)
                  : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.white, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Text(
            'Add more',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? const Color(0xFF1B0B3B)
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptionField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E0FF)),
      ),
      child: TextField(
        controller: _captionController,
        maxLines: 5,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: const Color(0xFF1B0B3B),
        ),
        decoration: InputDecoration(
          hintText: 'Write here...',
          hintStyle: GoogleFonts.inter(
            color: Colors.grey[400],
            fontSize: 14.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required List<String> selectedIds,
    required Map<String, String> nameMap,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final selectedNames = selectedIds.map((id) => nameMap[id] ?? id).toList();
    final displayText = selectedNames.isEmpty
        ? placeholder
        : selectedNames.length <= 2
            ? selectedNames.join(', ')
            : '${selectedNames.length} selected';
    final isPlaceholder = selectedNames.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE8E8EE)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: isPlaceholder
                      ? Colors.grey[400]
                      : const Color(0xFF1B0B3B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[500],
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: (_hasMedia && !_isSubmitting) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: const Color(0xFFB0A8D0),
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({
    required this.color,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        ),
        Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final end = (start + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
