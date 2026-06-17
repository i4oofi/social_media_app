import 'dart:io';

void main() {
  final filesToRefactor = [
    'lib/features/settings/cubit/settings_cubit.dart',
    'lib/core/cubit/notification_cubit/notification_cubit.dart',
    'lib/features/chat/widgets/chat_input_field.dart',
    'lib/features/chat/cubit/chat_room/chat_room_cubit.dart',
    'lib/features/profile/cubit/edit_profile_cubit/edit_profile_cubit.dart',
    'lib/features/discover/cubit/discover_cubit.dart',
    'lib/core/cubit/posts_cubit/posts_cubit.dart',
    'lib/features/reels/cubit/reels_cubit.dart',
    'lib/features/chat/cubit/inbox/inbox_cubit.dart',
    'lib/features/home/cubit/home_cubit.dart',
  ];

  for (final filePath in filesToRefactor) {
    final file = File('/home/i4oofi/Desktop/Projects/social_media_app/' + filePath);
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();
    bool modified = false;

    // Add import if not present
    if (!content.contains('package:social_media_app/core/di/service_locator.dart')) {
      // Find the last import
      final lines = content.split('\n');
      int lastImportIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('import ')) {
          lastImportIndex = i;
        }
      }
      if (lastImportIndex != -1) {
        lines.insert(lastImportIndex + 1, "import 'package:social_media_app/core/di/service_locator.dart';");
        content = lines.join('\n');
        modified = true;
      }
    }

    // Replace service initializations
    final regex = RegExp(r'(final\s+[_a-zA-Z0-9]+\s*=\s*)([A-Z][a-zA-Z0-9]+Services)\(\);');
    if (regex.hasMatch(content)) {
      content = content.replaceAllMapped(regex, (match) {
        return '${match.group(1)}sl<${match.group(2)}>();';
      });
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Refactored: $filePath');
    }
  }
}
