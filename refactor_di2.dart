import 'dart:io';

void main() {
  final filesToRefactor = [
    'lib/features/chat/widgets/chat_input_field.dart',
    'lib/features/chat/cubit/chat_room/chat_room_cubit.dart',
    'lib/features/reels/cubit/reels_cubit.dart',
    'lib/features/chat/cubit/inbox/inbox_cubit.dart',
  ];

  for (final filePath in filesToRefactor) {
    final file = File('/home/i4oofi/Desktop/Projects/social_media_app/' + filePath);
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();
    bool modified = false;

    // Replace explicit type service initializations
    final regex = RegExp(r'(final\s+[A-Z][a-zA-Z0-9]+Services\s+[_a-zA-Z0-9]+\s*=\s*)([A-Z][a-zA-Z0-9]+Services)\(\);');
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
