import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/features/auth/services/auth_services.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authServices = AuthServices();

  Future<void> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    emit(AuthLoading());
    try {
      await authServices.signUpWithEmail(email, password, username);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      await authServices.signInWithEmail(email, password);
      emit(AuthSuccess());
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

  void checkUserAuth() {
    final userData = authServices.fetchUserRaw();
    if (userData != null) {
      emit(AuthSuccess());
    }
  }

  Future<void> signInWithMagicLink(String email) async {
    emit(AuthLoading());
    try {
      await authServices.signInWithMagicLink(email);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
