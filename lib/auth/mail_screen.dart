import 'package:flutter/material.dart';
import 'package:lobi_application/widgets/auth/auth_text_field.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';

class MailScreen extends StatelessWidget {
  const MailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final emailCtrl = TextEditingController();
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 30),
                            child: const AuthBackButton(),
                          ),
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppTheme.zinc200,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.mail_outline,
                                size: 30,
                                color: AppTheme.zinc800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'E-posta adresiyle devam edin',
                            textAlign: TextAlign.start,
                            style: text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 35,
                              color: AppTheme.black800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Fişlerini okut, harcamaların otomatik kategorilensin. '
                            'Hepsini tek ekrandan yönet.',
                            textAlign: TextAlign.start,
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.zinc800,
                              height: 1.3,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),
                          AuthTextField(
                            label: 'E-posta adresin',
                            controller: emailCtrl,
                            hintText: 'ornek@mail.com',
                            keyboardType: TextInputType.emailAddress,
                            // errorText: 'Geçerli bir e-posta gir', // validation sonrası gösterebilirsin
                            suffix: Icon(
                              Icons.mail_outline,
                              size: 24,
                              weight: 1,
                              color: AppTheme.zinc600,
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                  AuthPrimaryButton(
                    label: 'Devam Et',
                    onTap: () {
                      print('Devam Et tıklandı');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
