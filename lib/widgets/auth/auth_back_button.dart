import 'package:flutter/material.dart';
import 'package:lobi_application/theme/app_theme.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {}
        },
        child: Ink(
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: AppTheme.getAuthBackButton(context),
          ),
        ),
      ),
    );
  }
}
