import 'package:bonded_app/core/constants/app_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../controllers/chat_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/messages/full_screen_image_viewer.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel user = Get.arguments;
    final controller = Get.put(ChatController());
    controller.initChat(user);

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
          user.fullName ?? user.username ?? "Chat",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 16.r,
              backgroundImage: NetworkImage(AppUrls.imageUrl(user.avatar)),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (controller.messages.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          "No messages yet. Say hi!",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // // Today Chip
                    // Padding(
                    //   padding: EdgeInsets.symmetric(vertical: 16.h),
                    //   child: Container(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: 16.w,
                    //       vertical: 8.h,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: const Color(0xFFFAF7FF),
                    //       borderRadius: BorderRadius.circular(10.r),
                    //     ),
                    //     child: Text(
                    //       "Chat",
                    //       style: GoogleFonts.inter(
                    //         fontSize: 12.sp,
                    //         fontWeight: FontWeight.w600,
                    //         color: AppColors.primary,
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // Messages List
                    Expanded(
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final message = controller.messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                  ],

                  // Input Bar
                  _buildMessageInput(context, controller, user),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundImage: NetworkImage(message.senderImage),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: Get.width * 0.7),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isMe
                        ? const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: message.isMe ? null : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: message.isMe
                          ? Radius.circular(20.r)
                          : Radius.zero,
                      bottomRight: message.isMe
                          ? Radius.zero
                          : Radius.circular(20.r),
                    ),
                    boxShadow: [
                      if (message.isMe)
                        BoxShadow(
                          color: const Color(0xFF6D28D9).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: message.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.type == 'image' && message.mediaUrl != null)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                (message.text == '[Image]' ||
                                    message.text.isEmpty)
                                ? 0
                                : 8.h,
                          ),
                          child: GestureDetector(
                            onTap: () => Get.to(
                              () => FullScreenImageViewer(
                                imageUrl: AppUrls.imageUrl(message.mediaUrl),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(
                                AppUrls.imageUrl(message.mediaUrl),
                                width: 200.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 200.w,
                                      height: 150.h,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.broken_image),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      if (message.text != '[Image]' &&
                          message.text != '[Video]' &&
                          message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: message.isMe
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w),
                  child: Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe)
            SizedBox(width: 24.w), // Extra space on right for sent
        ],
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    ChatController controller,
    UserModel user,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showMediaOptions(context, controller),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.attach_file,
                color: Colors.grey[600],
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: "Type message...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => controller.sendMessage(value, user),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () =>
                controller.sendMessage(controller.messageController.text, user),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions(BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Media",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.image,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    controller.pickAndSendMedia(ImageSource.gallery);
                  },
                ),
                _buildMediaOption(
                  icon: Icons.camera_alt,
                  label: "Camera",
                  onTap: () {
                    Get.back();
                    controller.pickAndSendMedia(ImageSource.camera);
                  },
                ),
                _buildMediaOption(
                  icon: Icons.videocam,
                  label: "Video",
                  onTap: () {
                    Get.back();
                    controller.pickAndSendMedia(
                      ImageSource.gallery,
                      isVideo: true,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
