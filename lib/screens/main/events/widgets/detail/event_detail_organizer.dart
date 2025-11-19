import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';

/// EventDetailOrganizer - Etkinliği oluşturan kişinin bilgisi
/// 
/// Küçük profil fotoğrafı + isim soyisim (beyaz renk)
class EventDetailOrganizer extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const EventDetailOrganizer({
    super.key,
    required this.name,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profil fotoğrafı
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        SizedBox(width: 5.w),

        // İsim soyisim
        Text(
          name,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.dark_zinc800,
      child: Icon(
        Icons.person,
        size: 18.sp,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }
}