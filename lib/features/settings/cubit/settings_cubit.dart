import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/di/service_locator.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());
    final coreAuthServices = sl<CoreAuthServices>();

  Future<void> signOut() async {
    emit(SignOutLoading());
    try {
      await coreAuthServices.signOut();
      emit(SignOutSuccess());
    } catch (e) {
      emit(SignOutFailure(error: e.toString()));
    }
}
}
