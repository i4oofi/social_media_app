import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/custom_video_player.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _textController = TextEditingController();
  late final HomeCubit homeCubit;

  @override
  void initState() {
    super.initState();
    homeCubit = context.read<HomeCubit>();
    homeCubit.fetchInitialCreatePostData();
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.removeListener(() {});
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create Post",
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'SF Pro Text',
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close_rounded, color: AppColors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: BlocConsumer<HomeCubit, HomeState>(
              bloc: homeCubit,
              listenWhen: (previous, current) =>
                  current is PostCreated || current is PostCreateError,
              listener: (context, state) {
                if (state is PostCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post created successfully')),
                  );
                } else if (state is PostCreateError) {
                  debugPrint('Error: ${state.error}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.error}')),
                  );
                }
              },
              buildWhen: (previous, current) =>
                  current is PostCreating ||
                  current is PostCreated ||
                  current is PostCreateError,
              builder: (context, state) {
                if (state is PostCreating) {
                  return const CircularProgressIndicator.adaptive();
                }
                return TextButton(
                  onPressed: () async {
                    if (_textController.text.isNotEmpty) {
                      await homeCubit.createPost(text: _textController.text);
                      if (context.mounted) {
                        // Navigator.pop(context);
                      }
                    }
                  },
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: _textController.text.isNotEmpty
                          ? AppColors.primaryColor
                          : AppColors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // User Profile Info
              BlocBuilder<HomeCubit, HomeState>(
                bloc: homeCubit,
                buildWhen: (previous, current) =>
                    current is PostCreateInitialLoading ||
                    current is PostCreateInitialData,
                builder: (context, state) {
                  if (state is PostCreateInitialLoading) {
                    return const CircularProgressIndicator.adaptive();
                  } else if (state is PostCreateInitialData) {
                    final userData = state.user;
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.babyBlue15,
                          child: userData.imageUrl == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primaryColor,
                                )
                              : CachedNetworkImage(
                                  imageUrl: userData.imageUrl!,
                                  height: 44,
                                  width: 44,
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person_rounded,
                                        color: AppColors.primaryColor,
                                      ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData.name,
                              style: TextStyle(
                                color: AppColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 14,
                                  color: AppColors.dividerColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Public",
                                  style: TextStyle(
                                    color: AppColors.dividerColor,
                                    fontSize: 12,
                                    fontFamily: 'SF Pro Text',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is PickingImage) {
                    return const CircularProgressIndicator.adaptive();
                  } else if (homeCubit.currentImage != null) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            homeCubit.currentImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                homeCubit.clearImage();
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is PickingImageError) {
                    return Text('Error: ${state.error}');
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is PickingVideo) {
                    return const CircularProgressIndicator.adaptive();
                  } else if (homeCubit.currentVideo != null) {
                    return Expanded(
                      child: Stack(
                        children: [
                          CustomVideoPlayer(
                            videoFile: homeCubit.currentVideo!,
                            height: 200,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  homeCubit.clearVideo();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is PickingVideoError) {
                    return Text('Error: ${state.error}');
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is FileUploading) {
                    return const CircularProgressIndicator.adaptive();
                  } else if (homeCubit.currentFile != null) {
                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.babyBlue5,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file_outlined,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  homeCubit.currentFile!.path.split('/').last,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              homeCubit.clearFile();
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is FileUploadError) {
                    return Text('Error: ${state.error}');
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              // Post Text Input
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'SF Pro Text',
                  ),
                  decoration: InputDecoration(
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(color: AppColors.grey, fontSize: 16),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // "Add to your post" attachment trigger bar
              GestureDetector(
                onTap: () => _showAttachmentBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.dividerColor.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Add to your post",
                          style: TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.image_outlined,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.video_library_outlined,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.insert_drive_file_outlined,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: 630,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 6,
                offset: Offset(0, -1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Add to your post',
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 20,
                    fontFamily: 'SF Pro Text',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(
                color: AppColors.dividerColor.withValues(alpha: 0.3),
                thickness: 1,
                height: 1,
              ),
              const SizedBox(height: 16),

              // Option 1: Camera (Image)
              InkWell(
                onTap: () async {
                  if (context.mounted) Navigator.pop(context);
                  await homeCubit.takeImage();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Camera (Image)',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Option 2: Camera (Video)
              InkWell(
                onTap: () async {
                  if (context.mounted) Navigator.pop(context);
                  await homeCubit.takeVideo();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: const Icon(
                          Icons.videocam_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Camera (Video)',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Option 3: Upload Image
              InkWell(
                onTap: () async {
                  if (context.mounted) Navigator.pop(context);
                  await homeCubit.pickImage();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload Image',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Option 4: Upload Video
              InkWell(
                onTap: () async {
                  if (context.mounted) Navigator.pop(context);
                  await homeCubit.pickVideo();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: const Icon(
                          Icons.video_library_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload Video',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Option 5: Upload File
              InkWell(
                onTap: () async {
                  if (context.mounted) Navigator.pop(context);
                  await homeCubit.uploadFile();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: const Icon(
                          Icons.insert_drive_file_outlined,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Upload File',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Cancel Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.babyBlue5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
