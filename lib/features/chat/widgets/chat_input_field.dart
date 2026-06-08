import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/services/file_picker_services.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

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
  final FilePickerServices _filePickerServices = FilePickerServices();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to capture photo: $e')),
        );
      }
    }
  }

  void _showAttachmentOptions() {
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
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryColor),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primaryColor),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment Button
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryColor),
              onPressed: widget.isSending ? null : _showAttachmentOptions,
              iconSize: 28,
            ),
            
            // Text Input Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  style: const TextStyle(color: AppColors.black, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send Button
            widget.isSending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isTextEmpty ? Colors.grey.withValues(alpha: 0.2) : AppColors.primaryColor,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.white),
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
