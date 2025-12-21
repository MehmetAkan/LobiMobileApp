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
import 'package:lobi_application/widgets/auth/date_picker_field.dart';

// StatefulWidget → ConsumerStatefulWidget
class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

// State → ConsumerState
class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();

  DateTime? birthDate;
  bool isLoading = false;
  String? errorText;

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
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
                        label: 'İsim',
                        controller: firstNameCtrl,
                        hintText: 'Lütfen isminizi giriniz',
                        keyboardType: TextInputType.name,
                        errorText: null,
                      ),
                      const SizedBox(height: 10),
                      AuthTextField(
                        label: 'Soyisim',
                        controller: lastNameCtrl,
                        hintText: 'Lütfen soyisminizi giriniz',
                        keyboardType: TextInputType.name,
                        errorText: null,
                      ),
                      const SizedBox(height: 10),
                      DatePickerField(
                        label: 'Doğum Tarihin',
                        value: birthDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        onChanged: (date) {
                          setState(() {
                            birthDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
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
                          if (birthDate == null) {
                            setState(() {
                              errorText = 'Lütfen doğum tarihini seçin';
                            });
                            return;
                          }

                          setState(() {
                            isLoading = true;
                            errorText = null;
                          });

                          final controller = ref.read(
                            profileControllerProvider.notifier,
                          );
                          final result = await controller.saveProfile(
                            firstName: firstNameCtrl.text,
                            lastName: lastNameCtrl.text,
                            birthDate: birthDate!,
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
