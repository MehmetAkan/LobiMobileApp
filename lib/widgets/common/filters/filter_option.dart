import 'package:flutter/material.dart';

/// Filter seçeneği için model sınıfı
/// Her filter item'ı için gerekli bilgileri tutar
class FilterOption {
  final String id; // Benzersiz tanımlayıcı
  final String label; // Gösterilecek metin
  final IconData icon; // Gösterilecek ikon
  final bool isDefault; // Varsayılan seçenek mi?

  const FilterOption({
    required this.id,
    required this.label,
    required this.icon,
    this.isDefault = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}