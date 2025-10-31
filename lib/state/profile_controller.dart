import 'package:flutter/material.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/screens/home/home_screen.dart';

class ProfileController {
  final ProfileService _profileService;

  ProfileController({
    ProfileService? profileService,
  }) : _profileService = profileService ?? ProfileService();

  Future<void> submitProfileAndGoHome({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required DateTime? birthDate,
    required void Function(String? errorMessage) onError,
  }) async {
    if (firstName.trim().isEmpty) {
      onError('Lütfen adını gir');
      return;
    }
    if (lastName.trim().isEmpty) {
      onError('Lütfen soyadını gir');
      return;
    }
    if (birthDate == null) {
      onError('Lütfen doğum tarihini seç');
      return;
    }

    try {
      await _profileService.upsertMyProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        birthDate: birthDate,
      );

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      onError('Profil kaydedilemedi. Lütfen tekrar dene.');
    }
  }
}