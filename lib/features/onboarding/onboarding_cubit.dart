import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/user_repository.dart';
import '../../domain/user/body_composition.dart';
import '../../domain/user/gender.dart';
import '../../domain/user/user.dart';

class OnboardingCubit extends Cubit<OnboardingCubitState> {
  final UserRepository _userRepository;

  OnboardingCubit(this._userRepository) : super(OnboardingCubitState());

  void setFirstName(String name) {
    emit(state.copyWith(firstName: name));
  }

  void setGender(Gender gender) {
    emit(state.copyWith(gender: gender));
  }

  void setBirthyear(int birthyear) {
    emit(state.copyWith(birthyear: birthyear));
  }

  void setHeight(int height) {
    emit(state.copyWith(height: height));
  }

  void setWeight(int weight) {
    emit(state.copyWith(weight: weight));
  }

  void setBodyComposition(BodyComposition bodyComposition) {
    emit(state.copyWith(bodyComposition: bodyComposition));
  }

  void save() {
    _userRepository.signIn(state.user);
  }
}

class OnboardingCubitState {
  final String firstName;
  final Gender gender;
  final int birthyear;
  final int height;
  final int weight;
  final BodyComposition bodyComposition;

  int get age => DateTime.now().year - birthyear;

  User get user => User(
        name: firstName,
        gender: gender,
        age: age,
        height: height,
        weight: weight,
        bodyComposition: bodyComposition,
      );

  OnboardingCubitState({
    this.firstName = '',
    this.gender = Gender.female,
    this.birthyear = 2000,
    this.height = 180,
    this.weight = 80,
    this.bodyComposition = BodyComposition.lean,
  });

  OnboardingCubitState copyWith({
    String? firstName,
    Gender? gender,
    int? birthyear,
    int? height,
    int? weight,
    BodyComposition? bodyComposition,
  }) =>
      OnboardingCubitState(
        firstName: firstName ?? this.firstName,
        gender: gender ?? this.gender,
        birthyear: birthyear ?? this.birthyear,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        bodyComposition: bodyComposition ?? this.bodyComposition,
      );
}
