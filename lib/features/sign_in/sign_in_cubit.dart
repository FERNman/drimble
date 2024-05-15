import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/user_repository.dart';

class SignInCubit extends Cubit<SignInCubitState> {
  final UserRepository _userRepository;

  SignInCubit(this._userRepository) : super(SignInCubitState());

  Future<UserCredential> signInAnonymously() {
    return _userRepository.signInAnonymously();
  }

  Future<UserCredential> signInWithCredential(OAuthCredential credential) {
    return _userRepository.signInWithCredential(credential);
  }
}

class SignInCubitState {}
