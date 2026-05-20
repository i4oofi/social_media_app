import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final supabase = Supabase.instance.client;

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

  Future<UserData?> getUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();
    return UserData.fromMap(response);
  }

  User? fetchUserRaw() {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    return user;
  }

  Future<void> _setUserData(String name, String email, String userId) async {
    await supabase.from('users').insert({
      'name': name,
      'email': email,
      'id': userId,
    });
  }
}
