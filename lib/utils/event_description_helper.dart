import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;

/// EventDescriptionHelper - Açıklama metni dönüştürme yardımcısı
class EventDescriptionHelper {
  /// JSON formatındaki Quill document'ı plain text'e çevir
  static String getPlainText(String? jsonText) {
    if (jsonText == null || jsonText.isEmpty) return '';
    
    try {
      final doc = quill.Document.fromJson(jsonDecode(jsonText));
      return doc.toPlainText().trim();
    } catch (e) {
      // JSON parse edilemezse, olduğu gibi döndür
      return jsonText;
    }
  }

  /// Açıklamanın ilk N karakterini al (önizleme için)
  static String getPreview(String? jsonText, {int maxLength = 100}) {
    final plainText = getPlainText(jsonText);
    if (plainText.length <= maxLength) return plainText;
    return '${plainText.substring(0, maxLength)}...';
  }
}