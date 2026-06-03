# 📱 Social Media App

A premium, modern social media application built using **Flutter** and powered by the **Supabase** backend. Designed with an elegant, responsive user experience, featuring robust state management via **Flutter Bloc / Cubit** and a modular, feature-first clean architecture.

---

## 🚀 Key Features

*   **🔐 Authentication & Session Management**
    *   Secure user signup and login handled via Supabase Auth.
    *   Persisted session check on startup, routing users automatically to either the Home feed or Auth portal.
    *   State-driven forms with validation and responsive feedback.
*   **📰 Interactive Feed (Home)**
    *   Dynamic posts feed featuring clean layout cards.
    *   Dynamic Story-ring components (Instagram-style) for viewing active user stories.
    *   Interactive bottom sheets for writing, sending, and viewing comments.
    *   File attachment integration using file/image pickers uploaded straight to Supabase Storage buckets.
    *   Real-time post interaction (liking, commenting) with instant UI state updates.
*   **👤 Custom User Profiles**
    *   Display user metrics (Followers, Following, and Posts).
    *   Dedicated user feed showing published posts.
    *   Interactive profile editing (name, profile avatar updates) synced dynamically to the database.
*   **🔍 Discover Feed**
    *   Explore and search for other users, posts, and trending content.
*   **⚙️ Settings Panel**
    *   Theme configurations and preference customization backed by dedicated settings Cubits.
*   **🎨 Premium UI/UX & Navigation**
    *   Clean custom dark/light themes.
    *   Smooth transitions and interaction-aware micro-animations.
    *   Seamless navigation using a persistent bottom navigation bar.

---

## 🛠️ Tech Stack & Dependencies

*   **Framework:** [Flutter](https://flutter.dev/) (Dart SDK `^3.10.4`)
*   **Backend Database & Auth:** [Supabase Flutter SDK](https://supabase.com/)
*   **State Management:** [Flutter Bloc](https://pub.dev/packages/flutter_bloc) & Cubits
*   **Navigation:** [Persistent Bottom Navigation Bar v2](https://pub.dev/packages/persistent_bottom_nav_bar_v2)
*   **Media & Picker Services:** [File Picker](https://pub.dev/packages/file_picker), [Image Picker](https://pub.dev/packages/image_picker)
*   **Image Caching:** [Cached Network Image](https://pub.dev/packages/cached_network_image)
*   **UI Components:** [Flutter SVG](https://pub.dev/packages/flutter_svg), [Cupertino Icons](https://pub.dev/packages/cupertino_icons)

---

## 📂 Project Architecture & Directory Structure

The codebase is organized following a strict **Feature-First Clean Architecture**, separation of concerns, and maximum reusability:

```
lib/
├── main.dart                      # App entry point, initializes Supabase & sets up core Bloc providers
├── core/                          # Shared configurations, routes, theme & global services
│   ├── app_assets.dart            # Centralized assets and vectors
│   ├── app_constants.dart         # Global constants (e.g., Supabase URLs & keys)
│   ├── route/                     # Centralized app routing configurations
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   ├── theme/                     # Typography, Color Palette, and Theme configurations
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_tables_names.dart  # Supabase database table definitions
│   ├── models/                    # Shared global models (e.g. CommentModel, Request bodies)
│   ├── services/                  # Global API, DB, and File services
│   │   ├── supabase_database_services.dart
│   │   ├── post_services.dart
│   │   ├── file_picker_services.dart
│   │   └── core_auth_services.dart
│   ├── shared/                    # Reusable visual shell structure and widgets
│   │   ├── views/                 # Custom persistent bottom navbar container
│   │   └── widgets/               # Shared PostCard, layout helpers
│   └── cubit/                     # Global state management cubits (e.g. PostsCubit)
│
└── features/                      # Isolated feature modules containing dedicated layer blocks
    ├── auth/                      # Authentication (Login, Sign-Up forms and flow)
    │   ├── cubit/, models/, services/, views/, widgets/
    ├── home/                      # Main Feed, stories, post creation, and comments sheet
    │   ├── cubit/, models/, services/, views/, widgets/
    ├── profile/                   # User Profile, statistics, list of posts & Edit Profile view
    │   ├── cubit/, services/, views/, widgets/
    ├── discover/                  # Content exploration views
    │   └── views/
    └── settings/                  # App preferences & profile settings
        └── cubit/, views/, widgets/
```

---

## 🗄️ Database Schema & Tables (Supabase)

The core database tables defined and integrated within the application:
*   `users`: Stores user profile details, usernames, and avatar URLs.
*   `posts`: Main posts content (text, image attachment URLs, authors, and timestamps).
*   `comments`: User comments linked directly to specific post and user UUIDs.
*   `likes`: Pivot table mapping user actions to posts for instant reaction tracking.
*   `stories`: Active user stories.
*   `notifications`: In-app updates and alert logs.
*   `follows`: Follow relationships between users.
*   `chats` & `messages`: Communication logs.

---

## ⚙️ Getting Started & Local Setup

### 📋 Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   A [Supabase](https://supabase.com/) account and project set up.

### 🔌 Supabase Initialization
1. Create tables in your Supabase database according to the structures defined in `lib/core/theme/app_tables_names.dart`.
2. Configure your Supabase connection strings inside `lib/core/app_constants.dart`:
   ```dart
   class AppConstants {
     static const String supabaseUrl = 'YOUR_SUPABASE_URL';
     static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   }
   ```

### 🏃 Setup & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/social_media_app.git
   cd social_media_app
   ```
2. Get project dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
