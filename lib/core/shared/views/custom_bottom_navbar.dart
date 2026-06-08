import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:social_media_app/features/discover/views/discover_screen.dart';
import 'package:social_media_app/features/home/views/home_screen.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomBottomNavbar extends StatefulWidget {
  const CustomBottomNavbar({super.key});

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar> {
  UserData? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await CoreAuthServices().getCurrentUserData();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(icon: const Icon(Icons.home), title: "Home"),
        ),
        PersistentTabConfig(
          screen: const DiscoverScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.group_add_rounded),
            title: "Discover",
          ),
        ),
        PersistentTabConfig(
          screen: const ProfileScreen(),
          item: ItemConfig(
            icon: currentUser?.imageUrl != null
                ? CircleAvatar(
                    radius: 12,
                    backgroundImage: CachedNetworkImageProvider(currentUser!.imageUrl!),
                  )
                : const Icon(Icons.person),
            title: "Profile",
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) =>
          Style5BottomNavBar(navBarConfig: navBarConfig),
    );
  }
}
