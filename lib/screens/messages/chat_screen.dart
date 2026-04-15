import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/bond_user_model.dart';
import '../../controllers/chat_controller.dart';
import '../../core/theme/app_colors.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BondUserModel user = Get.arguments;
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
          "Chat",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B0B3B),
          ),
        ),
      ),
      body: Column(
        children: [
          // Today Chip
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "Today",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message);
                  },
                )),
          ),

          // Input Bar
          _buildInputBar(controller, user),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(message.senderImage),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (message.isMe) ...[
                      Text(
                        DateFormat('h:mm a').format(message.timestamp),
                        style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        message.senderName,
                        style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1B0B3B)),
                      ),
                    ] else ...[
                      Text(
                        message.senderName,
                        style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1B0B3B)),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        DateFormat('h:mm a').format(message.timestamp),
                        style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: message.isMe ? AppColors.primary : const Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(message.isMe ? 16.r : 0),
                      topRight: Radius.circular(message.isMe ? 0 : 16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: message.isMe ? Colors.white : const Color(0xFF1B0B3B),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) ...[
            SizedBox(width: 12.w),
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(message.senderImage),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatController controller, BondUserModel user) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FF),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      decoration: InputDecoration(
                        hintText: "Type message...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14.sp),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.mic_none, color: Colors.grey[500], size: 24.sp),
                  SizedBox(width: 12.w),
                  Icon(Icons.sentiment_satisfied_alt, color: Colors.grey[500], size: 24.sp),
                  SizedBox(width: 12.w),
                  Icon(Icons.camera_alt_outlined, color: Colors.grey[500], size: 24.sp),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.sendMessage(controller.messageController.text, user),
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.send, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
