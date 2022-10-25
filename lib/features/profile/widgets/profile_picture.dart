import 'package:flutter/material.dart';

import '../../../domain/user/gender.dart';

class ProfilePicture extends StatelessWidget {
  final String _imagePath;

  const ProfilePicture({required Gender gender, super.key})
      : _imagePath = gender == Gender.male ? 'assets/images/profile_male.png' : 'assets/images/profile_female.png';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 142,
        height: 142,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
          image: DecorationImage(fit: BoxFit.fill, image: AssetImage(_imagePath)),
        ),
      ),
    );
  }
}
