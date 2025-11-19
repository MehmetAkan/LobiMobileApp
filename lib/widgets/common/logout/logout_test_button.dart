import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/utils/event_permission_helper.dart';
import 'package:lobi_application/data/repositories/auth_repository.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// LogoutTestButton - Test amaçlı çıkış butonu
/// 
/// Kullanım:
/// ```dart
/// // Herhangi bir sayfaya ekle:
/// LogoutTestButton()
/// ```
class LogoutTestButton extends StatefulWidget {
  const LogoutTestButton({super.key});

  @override
  State<LogoutTestButton> createState() => _LogoutTestButtonState();
}

class _LogoutTestButtonState extends State<LogoutTestButton> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    // Onay dialogu göster
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.red900,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = getIt<AuthRepository>();
      await authRepo.signOut();
      
      // Cache'i temizle
      EventPermissionHelper.clearCache();

      if (!mounted) return;

      // Login sayfasına yönlendir
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapılırken hata: $e'),
          backgroundColor: AppTheme.red900,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _handleLogout,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.red900.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.red900.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.red900,
                  ),
                )
              else
                Icon(
                  LucideIcons.logOut400,
                  size: 20.sp,
                  color: AppTheme.red900,
                ),
              SizedBox(width: 8.w),
              Text(
                _isLoading ? 'Çıkış yapılıyor...' : 'Çıkış Yap',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.red900,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ALTERNATİF: SADECE İKON BUTONU ====================

/// LogoutIconButton - Sadece icon, kompakt versiyon
/// 
/// AppBar veya dar alanlara sığması için
class LogoutIconButton extends StatefulWidget {
  const LogoutIconButton({super.key});

  @override
  State<LogoutIconButton> createState() => _LogoutIconButtonState();
}

class _LogoutIconButtonState extends State<LogoutIconButton> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.red900,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = getIt<AuthRepository>();
      await authRepo.signOut();
      
      EventPermissionHelper.clearCache();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Çıkış yapılırken hata: $e'),
          backgroundColor: AppTheme.red900,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45.w,
      height: 45.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _isLoading ? null : _handleLogout,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.red900.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.red900.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.red900,
                      ),
                    )
                  : Icon(
                      LucideIcons.logOut400,
                      size: 22.sp,
                      color: AppTheme.red900,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}