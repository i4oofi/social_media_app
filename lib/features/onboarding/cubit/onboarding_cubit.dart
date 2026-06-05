import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  int _currentPage = 0;
  int get currentPage => _currentPage;

  void changePage(int index) {
    _currentPage = index;
    emit(OnboardingPageChanged(index));
  }

  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingCompleted());
    }
  }
}
