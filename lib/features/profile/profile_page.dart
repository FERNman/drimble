import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_cubit.dart';

class ProfilePage extends StatefulWidget {
  static Route<void> route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ProfileCubit(),
          child: const ProfilePage(),
        ),
      );

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile'),
      ),
    );
  }
}
