import 'package:flutter/material.dart';
import 'package:social_media_app/core/app_assets.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/auth/widgets/login_form.dart';
import 'package:social_media_app/features/auth/widgets/signup_form.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Tab> tabs = [Tab(text: "Sign In"), Tab(text: "Sign Up")];
    List<Widget> tabsViews = [LoginForm(), SignUpForm()];
    return AuthView(tabs: tabs, tabsViews: tabsViews);
  }
}

class AuthView extends StatelessWidget {
  const AuthView({super.key, required this.tabs, required this.tabsViews});

  final List<Tab> tabs;
  final List<Widget> tabsViews;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Image.asset(AppAssets.appLogo),
                    const SizedBox(height: 32),
                    TabBar(
                      controller: DefaultTabController.of(context),
                      tabs: tabs,
                      isScrollable: true,
                      dividerColor: AppColors.dividerColor,
                      indicatorColor: AppColors.indicatorColor,
                      labelColor: AppColors.black,
                      tabAlignment: TabAlignment.start,
                      labelStyle: Theme.of(context).textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),

                    const SizedBox(height: 32),
                    Expanded(child: TabBarView(children: tabsViews)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
