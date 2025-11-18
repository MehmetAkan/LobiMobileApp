import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/cover_photo_picker_modal.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/images/app_image.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class CreateEventCoverSection extends StatelessWidget {
  final String? coverPhotoUrl;
  final Function(String url)? onPhotoSelected;
  final String defaultCoverAsset;

  const CreateEventCoverSection({
    super.key,
    this.coverPhotoUrl,
    this.onPhotoSelected,
    required this.defaultCoverAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: _buildCoverImage(coverPhotoUrl),
          ),
        ),
        Positioned(
          right: 12.w,
          bottom: 12.h,
          child: _buildGalleryButton(context),
        ),
      ],
    );
  }

  Widget _buildGalleryButton(BuildContext context) {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: BoxDecoration(
        color: AppTheme.getAppBarButtonBg(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.getAppBarButtonBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CoverPhotoPickerModal(),
                fullscreenDialog: true,
              ),
            );

            // ✨ YENİ - Seçilen fotoğrafı parent'a gönder
            if (result != null && result is String) {
              onPhotoSelected?.call(result);
              debugPrint('✅ Seçilen fotoğraf: $result');
            }
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(
              LucideIcons.image400,
              size: 22.sp,
              color: AppTheme.getAppBarButtonColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(String? url) {
    return AppImage(
      path: url,
      fallbackPath: defaultCoverAsset, 
      fit: BoxFit.cover,
    );
  }
}
