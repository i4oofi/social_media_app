# 📱 SocialMate

A premium, state-of-the-art social media application built using **Flutter** and powered by the **Supabase** backend + **Firebase Cloud Messaging (FCM)**. Designed with an elegant, responsive user experience, featuring robust state management via **Flutter Bloc / Cubit** and a modular, feature-first clean architecture.

---

<p align="center">
  <img src="assets/images/logo/logo.svg" alt="SocialMate Logo" width="220" />
</p>

<p align="center">
  <b>SocialMate</b> — A premium, modern social media experience built with Flutter & Supabase.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-^3.10.4-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Supabase-Database%20%26%20Auth-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Firebase-FCM%20Notifications-FFCA28?logo=firebase&logoColor=white" alt="Firebase" />
  <img src="https://img.shields.io/badge/State%20Management-Bloc%20%2F%20Cubit-02569B" alt="Bloc" />
  <img src="https://img.shields.io/badge/Architecture-Feature--First%20Clean-orange" alt="Architecture" />
</p>

---

## 🎨 Branding & Visual Assets

### Core Brand Identity
| Main Logo | App Launcher Icon | Social Sign-In Icons |
|:---:|:---:|:---:|
| <img src="assets/images/logo/logo.svg" width="160" /> | <img src="assets/images/logo/logo_launcher.png" width="80" /> | <img src="assets/images/icons/social/google.svg" width="28" /> &nbsp;&nbsp; <img src="assets/images/icons/social/apple.svg" width="28" /> &nbsp;&nbsp; <img src="assets/images/icons/social/facebook.svg" width="28" /> |

### 🚀 Premium Onboarding Illustrations
The app features a fluid user onboarding process complete with custom SVG illustrations:
| Discover New Friends | Watch Reels & Videos | Direct Chat Messaging |
|:---:|:---:|:---:|
| <img src="assets/images/onboarding/onboarding_1.svg" width="180" /> | <img src="assets/images/onboarding/onboarding_2.svg" width="180" /> | <img src="assets/images/onboarding/onboarding_3.svg" width="180" /> |

---

## 🚀 Key Features

*   **🎬 Reels (Short Videos Feed)**
    *   Smooth vertical short-video feed (TikTok/Instagram Reels style).
    *   Smart batch-loading pagination logic (fetches 10 videos at a time).
    *   Efficient memory management using visibility detectors to play/pause active videos and auto-dispose of off-screen players.
*   **💬 Real-Time Messaging & Chat**
    *   Real-time Direct Message (DM) chat rooms with messages synced via Supabase Realtime channels.
    *   Custom messaging bubble UI supporting typing statuses, system messages, and rich user info.
    *   Interactive Inbox overview displaying latest conversations and user active states.
*   **🔐 Authentication & Social Logins**
    *   Secure signup, login, and session persistence handled via Supabase Auth.
    *   Seamless third-party OAuth provider integrations (Google, Apple, and Facebook sign-in options).
    *   Form-validation flows with interactive toast and shimmer notifications on success or failure.
*   **📰 Interactive Home Feed**
    *   Dynamic posts feed with sleek card layouts, responsive like actions, and comment counts.
    *   Instagram-style Stories tray showing active profiles and stories.
    *   Rich post creator supporting media attachments uploaded directly to Supabase Storage.
    *   Staggered-animation Comments Bottom Sheet featuring real-time comments, profile avatars, and a dedicated text input.
*   **👤 Profiles & Customization**
    *   User stats overview (Followers, Following, and Posts count).
    *   Personal posts grid with detailed media preview.
    *   Edit Profile screen allowing updates to Display Name, Bio, and instant profile avatar file uploads.
*   **🔔 Real-Time Notifications**
    *   In-app notifications feed tracking likes, comments, and new followers.
    *   Push notification triggers utilizing Firebase Cloud Messaging (FCM) and Local Notification channels.
*   **🔍 Discover Feed**
    *   Global exploration screen to search for users, posts, and trending tags.
*   **⚙️ Settings & Preference Customization**
    *   System preferences configuration, app settings management, and persistent theme switching (Dark & Light Modes) backed by Bloc state persistence.

---

## 🛠️ Technology Stack & Key Dependencies

### Core Frameworks
*   **Flutter (Dart SDK `^3.10.4`)** — Cross-platform UI development.
*   **Supabase (Flutter SDK `^2.12.4`)** — Database service, Storage Buckets, Auth, and Real-time WebSockets.
*   **Firebase Core (`^4.10.0`) & Messaging (`^16.3.0`)** — Cloud infrastructure for push notification delivery.

### Main Libraries
*   **State Management:** `flutter_bloc` (`^9.1.1`) — Predictable, modular state management.
*   **Dependency Injection:** `get_it` (`^9.2.1`) — Service Locator pattern for clean API / service dependencies.
*   **Navigation:** `persistent_bottom_nav_bar_v2` (`^6.3.2`) — Clean and persistent bottom routing layout.
*   **Video & Media:** `video_player` (`^2.11.1`) & `visibility_detector` (`^0.4.0+2`) — Performant Reels video engine.
*   **Media Picker:** `image_picker` (`^1.2.2`) & `file_picker` (`^11.0.2`) — File uploads support.
*   **Caching & UI Performance:** `cached_network_image` (`^3.4.1`) and `shimmer` (`^3.0.0`) — Smooth loading skeletons and network image asset caching.
*   **Local Storage:** `shared_preferences` (`^2.5.5`) — Client-side flags persistence (e.g., onboarding completion).

---

## 📂 Project Architecture

The codebase follows the **Feature-First Clean Architecture** principles to separate concerns, enforce testability, and keep features decoupled.

```
lib/
├── main.dart                      # App launcher (initializes Supabase, Firebase FCM, and builds the MultiBlocProvider tree)
├── firebase_options.dart          # Auto-generated Firebase configuration options
│
├── core/                          # Shared configurations, styling tokens, routing, and global layers
│   ├── app_assets.dart            # Central asset path references
│   ├── app_constants.dart         # Backend URL endpoint constants and API credentials
│   ├── route/                     # Central app routing configurations (AppRouter & routes definitions)
│   ├── theme/                     # App custom styling patterns, typography, and dark/light themes
│   ├── models/                    # Unified domain data models (e.g. CommentModel, UserProfileModel)
│   ├── services/                  # Database connections, file picker configurations, auth services
│   ├── di/                        # Service Locator config (GetIt dependency setup)
│   ├── shared/                    # Reusable visual shell components, standard layouts, and global widgets
│   └── cubit/                     # Global state engines (PostsCubit, ThemeCubit, NotificationCubit)
│
└── features/                      # Isolated features (each having independent layers)
    ├── splash/                    # Native splash check and initialization routing
    ├── onboarding/                # Intro screen slider with custom SVG illustrations
    ├── auth/                      # Login, sign-up forms, password recovery, and social providers
    ├── home/                      # Global home feed, story rings, comments, and upload widgets
    ├── reels/                     # Short video scrolling viewport with lazy loading
    ├── discover/                  # Explore grid and search bars
    ├── chat/                      # Real-time message exchange and user inbox
    ├── profile/                   # User bio details, profile editing, and post history
    └── settings/                  # User options and dark mode triggers
```

---

## 🗄️ Database & Backend Schema

The backend is hosted on **Supabase** with a relational PostgreSQL schema. Data interactions sync automatically with the application's Dart models.

### Database Tables
*   `users`: Stores profile configurations (display names, bios, avatars, and email linkages).
*   `posts`: Main feeds content (text captions, media attachments URLs, and timestamps).
*   `comments`: Nested thread commentaries mapped to posts and author profiles.
*   `likes`: Pivot table registering user interactions on posts.
*   `stories`: Expiring media records mapped to stories cards.
*   `notifications`: Target event triggers for user updates.
*   `follows`: Follower/following linkage mappings.
*   `chats` & `messages`: Dynamic text storage mapping messaging rooms and timestamps.

### Database Schema Graph
Below is the visualization of the database relational schema:

<p align="center">
  <img src="docs/presentation/assets/supabase-schema-luwbglucaedacswkaqgn.svg" alt="Supabase Schema Graph" width="90%" />
</p>

---

## ⚙️ Local Development Setup

### 📋 Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (`^3.10.4` or higher).
*   A [Supabase](https://supabase.com/) project set up.
*   A [Firebase Console](https://console.firebase.google.com/) project configured for push notifications.

### 🔧 Configuration

1. **Supabase Setup**:
   Create your tables on your Supabase dashboard, and update `lib/core/app_constants.dart` with your API credentials:
   ```dart
   class AppConstants {
     static final appName = "SocialMate";
     static final supabaseUrl = "YOUR_SUPABASE_URL";
     static final supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY";
   }
   ```

2. **Firebase Setup**:
   Add Firebase configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) or run the `flutterfire configure` script to auto-generate `lib/firebase_options.dart`.

3. **Install Dependencies & Launch**:
   Run these standard terminal commands inside the project root:
   ```bash
   # Retrieve pub packages
   flutter pub get

   # Run launcher icon generator (if updating app launcher logos)
   flutter pub run flutter_launcher_icons

   # Launch the application on a connected device
   flutter run
   ```

---

## 📱 Interactive Presentation & Demos

The project includes an interactive web-based presentation containing features descriptions and video walk-throughs:
1. Navigate to the `docs/presentation/` folder.
2. Launch a local web server (e.g. `python3 -m http.server 8000`).
3. Open `http://localhost:8000` in any web browser to explore.
