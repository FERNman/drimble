import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/user_repository.dart';

class ProfileCubit extends Cubit<ProfileCubitState> {
  final UserRepository _userRepository;

  ProfileCubit(this._userRepository) : super(ProfileCubitState());

  void signOut() {
    // TODO: Clear everything else as well
    _userRepository.signOut();
  }
}

class ProfileCubitState {}
