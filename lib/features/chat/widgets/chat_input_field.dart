import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';
import 'package:social_media_app/core/di/service_locator.dart';

class ChatInputField extends StatefulWidget {
  final Function(String text) onSend;
  final Function(String filePath, String fileName) onImageSelected;
  final bool isSending;

  const ChatInputField({
    super.key,
    required this.onSend,
    required this.onImageSelected,
    this.isSending = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final FilePickerServices _filePickerServices = sl<FilePickerServices>();
  bool _isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final isNowEmpty = _controller.text.trim().isEmpty;
      if (isNowEmpty != _isTextEmpty) {
        setState(() {
          _isTextEmpty = isNowEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _filePickerServices.pickImage();
      if (image != null) {
        final fileName = image.name.isNotEmpty
            ? image.name
            : '${DateTime.now().millisecondsSinceEpoch}.jpg';
        widget.onImageSelected(image.path, fileName);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showToast(
          msg: 'Failed to pick image: $e',
          backgroundColor: AppColors.red,
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _filePickerServices.takeImage();
      if (image != null && image.path.isNotEmpty) {
        final fileName = image.name.isNotEmpty
            ? image.name
            : '${DateTime.now().millisecondsSinceEpoch}.jpg';
        widget.onImageSelected(image.path, fileName);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showToast(
          msg: 'Failed to capture photo: $e',
          backgroundColor: AppColors.red,
        );
      }
    }
  }

  void _showAttachmentOptions() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primaryColor,
                ),
                title: Text('Camera', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.primaryColor,
                ),
                title: Text('Gallery', style: theme.textTheme.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primaryColor,
              ),
              onPressed: widget.isSending ? null : _showAttachmentOptions,
              iconSize: 28,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 15.sp),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: theme.hintColor),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            widget.isSending
                ? SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTextEmpty
                          ? (theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.2))
                          : AppColors.primaryColor,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: AppColors.white,
                      ),
                      iconSize: 18,
                      onPressed: _isTextEmpty ? null : _handleSend,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
