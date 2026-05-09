import 'dart:io';
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

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController controller;
  late final UserModel user;

  @override
  void initState() {
    super.initState();
    user = Get.arguments;
    controller = Get.put(ChatController());
    // Use addPostFrameCallback to ensure the controller is initialized 
    // and we can call initChat safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initChat(user);
    });
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
                    // Messages List
                    Expanded(
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: controller.messages.length +
                            (controller.isOtherUserTyping.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.messages.length) {
                            return _buildTypingBubble();
                          }
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
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar for received messages
          if (!message.isMe) ...[
            _buildAvatar(message.senderImage, message.senderName),
            SizedBox(width: 8.w),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Bubble
                Container(
                  constraints: BoxConstraints(maxWidth: Get.width * 0.72),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
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
                      topLeft: Radius.circular(18.r),
                      topRight: Radius.circular(18.r),
                      bottomLeft: message.isMe
                          ? Radius.circular(18.r)
                          : Radius.circular(4.r),
                      bottomRight: message.isMe
                          ? Radius.circular(4.r)
                          : Radius.circular(18.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: message.isMe
                            ? const Color(0xFF6D28D9).withOpacity(0.25)
                            : Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: message.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Image attachment
                      if (message.type == 'image' && (message.mediaUrl != null || message.localFilePath != null))
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: (message.text == '[Image]' ||
                                    message.text.isEmpty)
                                ? 0
                                : 8.h,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (message.mediaUrl != null) {
                                Get.to(
                                  () => FullScreenImageViewer(
                                    imageUrl: AppUrls.imageUrl(message.mediaUrl),
                                  ),
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  message.localFilePath != null
                                      ? Image.file(
                                          File(message.localFilePath!),
                                          width: 200.w,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 200.w,
                                            height: 150.h,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        )
                                      : Image.network(
                                          AppUrls.imageUrl(message.mediaUrl!),
                                          width: 200.w,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 200.w,
                                            height: 150.h,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                  if (message.id.startsWith('temp_'))
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.4),
                                        child: Center(
                                          child: SizedBox(
                                            width: 30.w,
                                            height: 30.w,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // Text content
                      if (message.text != '[Image]' &&
                          message.text != '[Video]' &&
                          message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: GoogleFonts.inter(
                            fontSize: 14.5.sp,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: message.isMe
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                    ],
                  ),
                ),

                // Timestamp + read status
                Padding(
                  padding: EdgeInsets.only(
                    top: 4.h,
                    left: 4.w,
                    right: 4.w,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (message.isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.done_all,
                          size: 13.sp,
                          color: Colors.grey[400],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Small right padding for own messages
          if (message.isMe) SizedBox(width: 4.w),
        ],
      ),
    );
  }

  /// Builds a circular avatar with an initials fallback.
  Widget _buildAvatar(String imageUrl, String name) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16.r,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[200],
        onBackgroundImageError: (_, __) {},
      );
    }
    // Fallback: initials
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return CircleAvatar(
      radius: 16.r,
      backgroundColor: const Color(0xFFEDE9FE),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6D28D9),
        ),
      ),
    );
  }

  /// Animated typing indicator bubble.
  Widget _buildTypingBubble() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(user.avatar != null ? AppUrls.imageUrl(user.avatar) : '', user.fullName ?? user.username ?? ''),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(4.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
