import 'package:flutter/material.dart';
import 'package:lobi_application/widgets/common/logout/logout_test_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Profil Sayfası'),
               LogoutTestButton(),
            ],
          ),
        ),
      ),
    );
  }
}