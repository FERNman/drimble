import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/user_repository.dart';
import '../../domain/user/user.dart';
import '../../infra/disposable.dart';
import 'profile_form_value.dart';

class ProfileCubit extends Cubit<ProfileCubitState> with Disposable {
  final UserRepository _userRepository;

  ProfileCubit(this._userRepository) : super(ProfileCubitState()) {
    _loadUser();
  }

  void updateProfile(ProfileFormValue value) {
    final user = state.user;
    if (user != null) {
      user.age = DateTime.now().year - value.birthyear;
      user.height = value.height;
      user.weight = value.weight;
      user.bodyComposition = value.bodyComposition;

      _userRepository.signInOffline(user);
    }
  }

  void signOut() {
    _userRepository.signOut();
  }

  void _loadUser() {
    addSubscription(_userRepository.observeUser().listen((user) => emit(ProfileCubitState(user: user))));
  }
}

class ProfileCubitState {
  final User? user;

  final ProfileFormValue? profileFormValue;

  ProfileCubitState({this.user})
      : profileFormValue = user == null
            ? null
            : ProfileFormValue(
                birthyear: DateTime.now().year - user.age,
                height: user.height,
                weight: user.weight,
                bodyComposition: user.bodyComposition,
              );
}
