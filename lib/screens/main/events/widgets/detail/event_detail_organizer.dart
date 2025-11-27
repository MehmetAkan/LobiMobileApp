import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';

/// EventDetailOrganizer - Etkinliği oluşturan kişinin bilgisi
///
/// Küçük profil fotoğrafı + isim soyisim (beyaz renk)
class EventDetailOrganizer extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const EventDetailOrganizer({super.key, required this.name, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ProfileAvatar with custom white border
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ProfileAvatar(imageUrl: photoUrl, name: name, size: 25),
        ),
        SizedBox(width: 8.w),

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
}
