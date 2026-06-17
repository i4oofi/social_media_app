import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/models/message_model.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final bool isImage =
        message.content.startsWith('http') &&
        (message.content.contains('chat_attachments') ||
            message.content.contains('/storage/v1/object/public') ||
            message.content.endsWith('.jpg') ||
            message.content.endsWith('.jpeg') ||
            message.content.endsWith('.png'));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[SizedBox(width: 4.w)],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: isImage
                      ? EdgeInsets.zero
                      : EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryColor
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: isImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: CachedNetworkImage(
                            imageUrl: message.content,
                            placeholder: (context, url) => SizedBox(
                              width: 200.w,
                              height: 200.h,
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 200.w,
                              height: 200.h,
                              color: Colors.grey.shade300,
                              child: Icon(Icons.broken_image),
                            ),
                            fit: BoxFit.cover,
                            maxWidthDiskCache: 1000,
                          ),
                        )
                      : Text(
                          message.content,
                          style: TextStyle(
                            color:
                                isMe &&
                                    Theme.of(context).brightness ==
                                        Brightness.light
                                ? AppColors.black
                                : AppColors.white,
                            fontSize: 15.sp,
                          ),
                        ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(message.createdAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14.h,
                          color: message.isRead
                              ? AppColors.primaryColor
                              : AppColors.darkGrey,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
