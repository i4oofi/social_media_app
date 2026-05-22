import 'package:flutter/material.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      children: [
        SizedBox(
          height: size.height * 0.15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const StoryItem(firstItem: true);
              }
              return const StoryItem();
            },
          ),
        ),
      ],
    );
  }
}

class StoryItem extends StatelessWidget {
  final bool firstItem;
  const StoryItem({super.key, this.firstItem = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(firstItem){
          
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: firstItem ? AppColors.indicatorColor : null,
              border: Border.all(
                color: firstItem
                    ? AppColors.indicatorColor
                    : AppColors.primaryColor,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: firstItem ? AppColors.indicatorColor : null,
              child: Icon(
                firstItem ? Icons.add : null,
                size: 30,
                color: firstItem ? AppColors.white : AppColors.indicatorColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            firstItem ? "Share Story" : "User",
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
