import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/user_repository.dart';
import '../../domain/user/user.dart';
import '../../infra/disposable.dart';
import 'profile_form_value.dart';

class ProfileCubit extends Cubit<BaseProfileCubitState> with Disposable {
  final UserRepository _userRepository;

  ProfileCubit(this._userRepository) : super(ProfileCubitStateLoading()) {
    _loadUser();
  }

  void _loadUser() {
    addSubscription(
      _userRepository.observeUser().whereNotNull().listen((user) => emit(ProfileCubitState(user: user))),
    );
  }

  void updateProfile(ProfileFormValue value) async {
    if (state is ProfileCubitStateLoading) return;

    final user = (state as ProfileCubitState).user.copyWith(
          age: DateTime.now().year - value.birthyear,
          height: value.height,
          weight: value.weight,
          bodyComposition: value.bodyComposition,
        );

    await _userRepository.signInOffline(user);
  }

  void signOut() {
    _userRepository.signOut();
  }
}

abstract class BaseProfileCubitState {
  BaseProfileCubitState();
}

class ProfileCubitStateLoading extends BaseProfileCubitState {}

class ProfileCubitState extends BaseProfileCubitState {
  final User user;
  final ProfileFormValue profileFormValue;

  ProfileCubitState({required this.user})
      : profileFormValue = ProfileFormValue(
          birthyear: DateTime.now().year - user.age,
          height: user.height,
          weight: user.weight,
          bodyComposition: user.bodyComposition,
        );
}
