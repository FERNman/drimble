import '../../domain/user/body_composition.dart';

class ProfileFormValue {
  final int birthyear;
  final int height;
  final int weight;
  final BodyComposition bodyComposition;

  const ProfileFormValue({
    required this.birthyear,
    required this.height,
    required this.weight,
    required this.bodyComposition,
  });

  ProfileFormValue copyWith({
    int? birthyear,
    int? height,
    int? weight,
    BodyComposition? bodyComposition,
  }) =>
      ProfileFormValue(
        birthyear: birthyear ?? this.birthyear,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        bodyComposition: bodyComposition ?? this.bodyComposition,
      );
}
