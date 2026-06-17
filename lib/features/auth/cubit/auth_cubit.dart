import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/di/service_locator.dart';
import 'package:social_media_app/features/auth/services/auth_services.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthChecking());
  final authServices = sl<AuthServices>();

  Future<void> signUpWithEmail(
    String email,
    String password,
  ) async {
    emit(AuthLoading());
    try {
      await authServices.signUpWithEmail(email, password);
      emit(AuthSignUpSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> completeProfile({
    required String name,
    required String userName,
    required String dob,
    required dynamic profileImageFile,
    String? title,
    dynamic coverImageFile,
  }) async {
    emit(AuthLoading());
    try {
      final user = authServices.fetchUserRaw();
      if (user == null) {
        throw Exception('User is not authenticated');
      }
      
      await authServices.completeUserProfile(
        userId: user.id,
        email: user.email ?? '',
        name: name,
        userName: userName,
        dob: dob,
        title: title,
        profileImageFile: profileImageFile,
        coverImageFile: coverImageFile,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      await authServices.signInWithEmail(email, password);
      await _checkUserProfileCompletion();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await authServices.signOut();
    emit(AuthLogOut());
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    try {
      await authServices.resetPassword(email);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> checkUserAuth() async {
    final user = authServices.fetchUserRaw();
    if (user != null) {
      await _checkUserProfileCompletion();
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> signInWithMagicLink(String email) async {
    emit(AuthLoading());
    try {
      await authServices.signInWithMagicLink(email);
      await _checkUserProfileCompletion();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      await authServices.signInWithGoogle();
      await _checkUserProfileCompletion();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithApple() async {
    emit(AuthLoading());
    try {
      await authServices.signInWithApple();
      await _checkUserProfileCompletion();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithFacebook() async {
    emit(AuthLoading());
    try {
      await authServices.signInWithFacebook();
      await _checkUserProfileCompletion();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _checkUserProfileCompletion() async {
    try {
      final user = authServices.fetchUserRaw();
      if (user != null) {
        final exists = await authServices.checkUserExistsInDb(user.id);
        if (exists) {
          emit(AuthSuccess());
        } else {
          emit(AuthIncompleteProfile());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
