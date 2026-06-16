import 'package:social_media_app/core/services/supabase_database_services.dart';
import 'package:social_media_app/core/theme/app_tables_names.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart' as google;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final supabase = Supabase.instance.client;
  final supabaseDatabaseServices = SupabaseDatabaseServices.instance;
  Future<void> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('User is null');
      }
      // Note: We don't create the user record here anymore.
      // It will be created in completeUserProfile.
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  User? fetchUserRaw() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    return user;
  }

  Future<bool> checkUserExistsInDb(String userId) async {
    try {
      final user = await supabaseDatabaseServices.fetchRowOptional(
        table: AppTablesNames.users,
        primaryKey: 'id',
        id: userId,
        builder: (data, id) => data,
      );
      // If user exists but dob is empty, it means it's a dummy row from CoreAuthServices and profile is incomplete
      if (user != null) {
        final dob = user['dob'] as String?;
        return dob != null && dob.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkUsernameUnique(String username) async {
    try {
      final users = await supabaseDatabaseServices.fetchRows(
        table: AppTablesNames.users,
        filter: (query) => query.eq('user_name', username),
        builder: (data, id) => data,
      );
      return users.isEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> _uploadImage({
    required dynamic imageFile,
    required String bucket,
    required String userId,
    required String prefix,
  }) async {
    final path = '$userId/$prefix-${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage
        .from(bucket)
        .upload(
          path,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
    final publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  Future<void> completeUserProfile({
    required String userId,
    required String name,
    required String userName,
    required String dob,
    required String email,
    required dynamic profileImageFile,
    String? title,
    dynamic coverImageFile,
  }) async {
    try {
      String? profileImageUrl;
      String? coverImageUrl;

      if (profileImageFile != null) {
        profileImageUrl = await _uploadImage(
          imageFile: profileImageFile,
          bucket: 'avatars',
          userId: userId,
          prefix: 'profile',
        );
      }

      if (coverImageFile != null) {
        coverImageUrl = await _uploadImage(
          imageFile: coverImageFile,
          bucket: 'covers',
          userId: userId,
          prefix: 'cover',
        );
      }

      final userData = UserData(
        id: userId,
        name: name,
        userName: userName,
        dob: dob,
        email: email,
        title: title,
        imageUrl: profileImageUrl,
        coverUrl: coverImageUrl,
      );

      // Upsert in case CoreAuthServices self-healing already created a partial row
      await supabaseDatabaseServices.upsertRow(
        table: AppTablesNames.users,
        values: userData.toMap(),
        onConflict: 'id',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Refresh the session to get the latest user data (including email confirmation status)
      final res = await supabase.auth.refreshSession();
      if (res.user != null) {
        return res.user!.emailConfirmedAt != null;
      }
    }
    return false;
  }

  Future<void> resendVerificationEmail() async {
    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      await supabase.auth.resend(
        type: OtpType.signup,
        email: user.email,
      );
    }
  }

  Future<void> signInWithMagicLink(String email) async {
    await supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false, 
      emailRedirectTo: 'https://luwbglucaedacswkaqgn.supabase.co/auth/v1/verify?token=1357bb799f69048b29eb8f6126b33292acaa888cf52c09ce53c2e85e&type=magiclink&redirect_to=http://localhost:3000',
    );
  }

Future<void> signInWithGoogle() async {
  try {
    final googleSignIn = google.GoogleSignIn(
      serverClientId: "722087504847-9vak50ldillkgnucuu01li1en0nd2e34.apps.googleusercontent.com",
      scopes: ['email', 'profile'],
    );

    // Sign out first to always show the account picker
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // User cancelled the sign-in dialog
      throw Exception('Google sign-in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('Google ID token is null. Make sure your SHA-1/SHA-256 fingerprints and OAuth client are set up correctly in Google Cloud Console.');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  } catch (e, st) {
    print('Google Sign-In ERROR => $e');
    print('STACK => $st');
    rethrow;
  }
}

  Future<void> signInWithApple() async {
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw Exception('Could not find ID Token from Apple.');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final String accessToken = result.accessToken!.tokenString;
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken,
      );
    } else {
      throw Exception(result.message);
    }
  }
}
