import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/screens/auth/username_setup_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/auth/auth_text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/core/supabase_client.dart';
// DatePickerField kaldırıldı - Apple Review

// StatefulWidget → ConsumerStatefulWidget
class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

// State → ConsumerState
class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  // Tek full name input - Instagram tarzı
  final fullNameCtrl = TextEditingController();
  // birthDate kaldırıldı - null gönderilecek
  bool isLoading = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    // Apple Sign In'den gelen bilgileri otomatik doldur
    _loadAppleUserData();
  }

  /// Apple Sign In user metadata'dan isim bilgisini oku
  void _loadAppleUserData() {
    try {
      final user = SupabaseManager.instance.client.auth.currentUser;

      if (user?.userMetadata != null) {
        final metadata = user!.userMetadata!;

        // Farklı key'leri dene
        final fullName = metadata['full_name'] as String?;
        final name = metadata['name'] as String?;
        final firstName = metadata['given_name'] as String?;
        final lastName = metadata['family_name'] as String?;

        // Öncelik sırası: full_name > name > (given_name + family_name)
        String? nameToUse;
        if (fullName != null && fullName.isNotEmpty) {
          nameToUse = fullName;
        } else if (name != null && name.isNotEmpty) {
          nameToUse = name;
        } else if (firstName != null && firstName.isNotEmpty) {
          nameToUse = lastName != null && lastName.isNotEmpty
              ? '$firstName $lastName'
              : firstName;
        }

        if (nameToUse != null && nameToUse.isNotEmpty) {
          fullNameCtrl.text = nameToUse;
        }
      }
    } catch (e) {
      // Hata olursa sessizce devam et, kullanıcı manuel girecek
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 30),
                        child: AuthBackButton(),
                      ),
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppTheme.getAuthIconBg(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.userStar400,
                            size: 30,
                            color: AppTheme.getAuthIconColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Profil Oluşturma',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 35.sp,
                          letterSpacing: -0.20,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getAuthHeadText(context),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Artık son aşamadayız, profilini oluştur hemen etkinlik katıl!',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.sp,
                          letterSpacing: -0.20,
                          height: 1.1,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getAuthDescText(context),
                        ),
                      ),
                      const SizedBox(height: 25),
                      AuthTextField(
                        label: 'Tam Adınız',
                        controller: fullNameCtrl,
                        hintText: 'Örn: Mehmet Akan',
                        keyboardType: TextInputType.name,
                        errorText: null,
                      ),
                      const SizedBox(height: 10),
                      // DatePickerField kaldırıldı
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                              color: AppTheme.red700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20 + bottomInset),
                child: AuthPrimaryButton(
                  label: 'Devam Et',
                  onTap: isLoading
                      ? null
                      : () async {
                          // Full name parse et - Instagram tarzı
                          final fullName = fullNameCtrl.text.trim();
                          if (fullName.isEmpty) {
                            setState(() {
                              errorText = 'Lütfen en az adınızı giriniz';
                            });
                            return;
                          }

                          // İlk kelime firstName, geri kalanı lastName
                          final parts = fullName.split(' ');
                          final firstName = parts.first.trim();
                          final lastName = parts.length > 1
                              ? parts.sublist(1).join(' ').trim()
                              : '';

                          setState(() {
                            isLoading = true;
                            errorText = null;
                          });

                          final controller = ref.read(
                            profileControllerProvider.notifier,
                          );
                          final result = await controller.saveProfile(
                            firstName: firstName,
                            lastName: lastName,
                            birthDate: null, // Apple Review: null gönder
                          );

                          if (!mounted) return;

                          if (result?.isSuccess == true) {
                            ref.invalidate(currentUserProfileProvider);

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UsernameSetupScreen(),
                              ),
                              (route) => false,
                            );
                          } else {
                            setState(() {
                              errorText =
                                  result?.errorMessage ??
                                  'Profil kaydedilemedi. Tekrar deneyin.';
                            });
                          }

                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
