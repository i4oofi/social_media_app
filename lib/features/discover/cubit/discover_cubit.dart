import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/features/auth/models/user_data.dart';
import 'package:social_media_app/features/discover/views/services/discover_services.dart';

part 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit() : super(DiscoverInitial());

  final discoverServices = DiscoverServices();

  Future<void> fetchAllUsers() async {
    try {
      emit(DiscoverLoading());
      final users = await discoverServices.fetchAllUsers();
      emit(DiscoverSuccess(users: users));
    } catch (e) {
      emit(DiscoverFailure(errorMessage: e.toString()));
    }
  }
}

