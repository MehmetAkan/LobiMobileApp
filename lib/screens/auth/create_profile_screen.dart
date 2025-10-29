import 'package:flutter/material.dart';
import 'package:lobi_application/state/profile_controller.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/auth/auth_text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/widgets/common/date_picker_field.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
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
                  padding: EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Geri butonu
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 30),
                        child: AuthBackButton(),
                      ),
                      Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(
                          color: AppTheme.zinc200,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.userStar400,
                            size: 28,
                            color: AppTheme.zinc800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Başlık
                      Text(
                        'Profil Oluşturma',
                        textAlign: TextAlign.start,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 35,
                          color: AppTheme.black800,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Açıklama
                      Text(
                        'Artık son aşamadayız, profilini oluştur hemen etkinlik katıl!',
                        textAlign: TextAlign.start,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.zinc800,
                          height: 1.3,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // İsim
                      AuthTextField(
                        label: 'İsim',
                        controller: firstNameCtrl,
                        hintText: 'Lütfen isminizi giriniz',
                        keyboardType: TextInputType.name,
                        errorText: null,
                      ),
                      const SizedBox(height: 10),

                      // Soyisim
                      AuthTextField(
                        label: 'Soyisim',
                        controller: lastNameCtrl,
                        hintText: 'Lütfen soyisminizi giriniz',
                        keyboardType: TextInputType.name,
                        errorText: null,
                      ),
                      const SizedBox(height: 10),

                      // Doğum Tarihi
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

                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 20 + bottomInset, // klavye varsa yukarı çıksın
                ),
                child: AuthPrimaryButton(
                  label: 'Devam Et',
                  onTap: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorText = null;
                          });

                          await ProfileController().submitProfileAndGoHome(
                            context: context,
                            firstName: firstNameCtrl.text,
                            lastName: lastNameCtrl.text,
                            birthDate: birthDate,
                            onError: (msg) {
                              setState(() {
                                errorText = msg;
                              });
                            },
                          );

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
