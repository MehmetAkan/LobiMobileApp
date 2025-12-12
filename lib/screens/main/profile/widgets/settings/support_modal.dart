import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lobi_application/data/services/support_service.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SupportModal {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SupportModalContent(ref: ref),
    );
  }
}

class _SupportModalContent extends StatefulWidget {
  final WidgetRef ref;

  const _SupportModalContent({required this.ref});

  @override
  State<_SupportModalContent> createState() => _SupportModalContentState();
}

class _SupportModalContentState extends State<_SupportModalContent> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      getIt<AppFeedbackService>().showError('Lütfen bir mesaj yazın');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = widget.ref.read(currentUserProfileProvider).value?.userId;

      if (userId == null) {
        throw Exception('Kullanıcı bulunamadı');
      }

      final supportService = SupportService();

      // Check rate limit
      final canSend = await supportService.canSendMessage(userId: userId);
      if (!canSend) {
        if (mounted) {
          setState(() => _isLoading = false);
          getIt<AppFeedbackService>().showError(
            'Yakın zamanda çok mesaj gönderdiniz. Lütfen daha sonra tekrar deneyin.',
          );
        }
        return;
      }

      await supportService.sendSupportMessage(userId: userId, message: message);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        getIt<AppFeedbackService>().showSuccess('Mesajınız iletildi');
      }
    } catch (e) {
      if (mounted) {
        // Check if it's a rate limit error
        final errorMessage = e.toString().toLowerCase();

        if (errorMessage.contains('policy') ||
            errorMessage.contains('row-level security') ||
            errorMessage.contains('42501')) {
          // Rate limit hit - close modal and show message
          Navigator.of(context, rootNavigator: true).pop();
          getIt<AppFeedbackService>().showError(
            'Yakın zamanda çok mesaj gönderdiniz. Lütfen daha sonra tekrar deneyin.',
          );
        } else {
          // Other error - stop loading and show error
          setState(() => _isLoading = false);
          getIt<AppFeedbackService>().showError('Mesaj gönderilemedi');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomModalSheet(
      headerLeft: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.getModalIconBg(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.getModalIconBorder(context),
                width: 1.w,
              ),
            ),
            child: Icon(
              LucideIcons.headset,
              size: 24.sp,
              color: AppTheme.getModalIconText(context),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'Destek',
            style: AppTextStyles.titleHead_XL.copyWith(
              color: AppTheme.getTextHeadColor(context),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Lütfen sorunuz veya geri bildiriminizi bizimle paylaşın.',
            style: AppTextStyles.titleDesc_MD.copyWith(
              color: AppTheme.getTextModalDescColor(context),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
      showDivider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.getSettingsCardBg(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.getSettingsCardBorder(context),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 8,
              enabled: !_isLoading,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.getTextHeadColor(context),
              ),
              decoration: InputDecoration(
                hintText: 'Lütfen mesajınızı buraya yazın',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  letterSpacing: -0.20,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.getSettingsProfileHint(context),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getModalButtonBg(context),
                foregroundColor: AppTheme.getModalButtonText(context),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
                disabledBackgroundColor: AppTheme.zinc400,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.white,
                        ),
                      ),
                    )
                  : Text(
                      'Gönder',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
