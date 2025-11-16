import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:lobi_application/theme/app_theme.dart';

/// EventDetailDescription - Açıklama içeriği
///
/// Etkinlik açıklamasını Quill JSON'dan okuyup
/// biçimlendirmeyi (bold, italik, liste, vs.) koruyarak gösterir.
class EventDetailDescription extends StatelessWidget {
  final String description; // JSON string (Quill delta)

  const EventDetailDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Hiç açıklama yoksa
    if (description.isEmpty) {
      return Text(
        'Açıklama bulunmuyor.',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.getTextDescColor(context).withOpacity(0.5),
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    try {
      // Quill JSON'u parse et
      final dynamic decoded = jsonDecode(description);
      final doc = quill.Document.fromJson(decoded as List<dynamic>);

      // Read-only controller
      final controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // Detay sayfası için base text style
      return DefaultTextStyle(
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.white.withValues(alpha: 0.9),
          height: 1.6,
        ),
        child: quill.QuillEditor(
          controller: controller,
          focusNode: FocusNode(),          // sadece görüntüleme için
          scrollController: ScrollController(),
          // Diğer parametreler flutter_quill sürümüne göre optional,
          // create modal'da nasıl kullanıyorsak aynı pattern'i koruyoruz.
        ),
      );
    } catch (_) {
      // JSON parse edilemezse, fallback olarak düz metin göster
      return Text(
        description,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.white.withValues(alpha: 0.9),
          height: 1.6,
        ),
      );
    }
  }
}
