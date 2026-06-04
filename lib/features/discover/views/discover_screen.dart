import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/widgets/main_button.dart';
import 'package:social_media_app/features/discover/cubit/discover_cubit.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DiscoverCubit()..fetchAllUsers(),
      child: const DiscoverBody(),
    );
  }
}

class DiscoverBody extends StatelessWidget {
  const DiscoverBody({super.key});

  @override
  Widget build(BuildContext context) {
    final discoverCubit = context.read<DiscoverCubit>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Discover People",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          BlocBuilder<DiscoverCubit, DiscoverState>(
            buildWhen: (previous, current) =>
                current is DiscoverLoading ||
                current is DiscoverFailure ||
                current is DiscoverSuccess,
            builder: (context, state) {
              if (state is DiscoverLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DiscoverFailure) {
                return Center(
                  child: Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is DiscoverSuccess) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(),
                              ),
                            );
                          },
                          title: Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${user.followersCount} followers",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.darkGrey),
                          ),
                          trailing: MainButton(
                            onPressed: () {},
                            text: 'Follow',
                            width: 100,
                            height: 35,
                          ),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              user.imageUrl ?? '',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
