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
    String name,
  ) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user == null) {
        throw Exception('User is null');
      }
      await _setUserData(name, email, response.user!.id);
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

  Future<void> _setUserData(String name, String email, String userId) async {
    try {
      final userData = UserData(id: userId, name: name, email: email);
      await supabaseDatabaseServices.insertRow(
        table: AppTablesNames.users,
        values: userData.toMap(),
      );
    } catch (e) {
      rethrow;
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
    const webClientId = 'my-web-client-id';
    const iosClientId = 'my-ios-client-id';

    await google.GoogleSignIn.instance.initialize(
      serverClientId: webClientId,
      clientId: iosClientId,
    );
    final googleUser = await google.GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('No ID Token found.');
    }

    // Get access token for Supabase if available
    final authz = await googleUser.authorizationClient.authorizationForScopes([]);
    final accessToken = authz?.accessToken;

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
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
