import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:social_media_app/features/discover/views/discover_screen.dart';
import 'package:social_media_app/features/home/views/home_screen.dart';
import 'package:social_media_app/features/profile/views/profile_screen.dart';
import 'package:social_media_app/features/settings/views/setting_screen.dart';

class CustomBottomNavbar extends StatelessWidget {
  const CustomBottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      tabs: [
        PersistentTabConfig(
          screen: HomeScreen(),
          item: ItemConfig(icon: Icon(Icons.home), title: "Home"),
        ),
        PersistentTabConfig(
          screen: DiscoverScreen(),
          item: ItemConfig(
            icon: Icon(Icons.group_add_rounded),
            title: "Discover",
          ),
        ),
        PersistentTabConfig(
          screen: ProfileScreen(),
          item: ItemConfig(icon: Icon(Icons.person), title: "Profile"),
        ),
        PersistentTabConfig(
          screen: SettingsScreen(),
          item: ItemConfig(icon: Icon(Icons.settings), title: "Settings"),
        ),
      ],
      navBarBuilder: (navBarConfig) =>
          Style5BottomNavBar(navBarConfig: navBarConfig),
    );
  }
}
