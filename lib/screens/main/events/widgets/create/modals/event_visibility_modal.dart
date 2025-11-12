import 'package:flutter/material.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Görünürlük seçenekleri
enum EventVisibility {
  public,
  private,
}

/// EventVisibilityModal - Görünürlük seçimi
/// 
/// Kullanım:
/// ```dart
/// final result = await EventVisibilityModal.show(
///   context: context,
///   currentValue: EventVisibility.public,
/// );
/// if (result != null) {
///   setState(() => _visibility = result);
/// }
/// ```
class EventVisibilityModal {
  static Future<EventVisibility?> show({
    required BuildContext context,
    required EventVisibility currentValue,
  }) {
    return showModalBottomSheet<EventVisibility>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VisibilityContent(currentValue: currentValue),
    );
  }

  /// Display text
  static String getDisplayText(EventVisibility type) {
    switch (type) {
      case EventVisibility.public:
        return 'Herkese Açık';
      case EventVisibility.private:
        return 'Özel';
    
    }
  }
}

class _VisibilityContent extends StatefulWidget {
  final EventVisibility currentValue;

  const _VisibilityContent({required this.currentValue});

  @override
  State<_VisibilityContent> createState() => _VisibilityContentState();
}

class _VisibilityContentState extends State<_VisibilityContent> {
  late EventVisibility _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentValue;
  }

  void _onSelect(EventVisibility value) {
    setState(() => _selected = value);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.of(context).pop(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return EventModalSheet(
      icon: LucideIcons.globe400,
      title: 'Etkinliğin Görünürlüğü',
      description: 'Bu Etkinliğinizi kimler görebileceğiniz seçin ? Direkt erişim link olanlar görebilir.',
      children: [
        EventModalOption(
          isSelected: _selected == EventVisibility.public,
          title: 'Herkese Açık',
          description: 'Herkes görebilir ve katılabilir',
          onTap: () => _onSelect(EventVisibility.public),
        ),
        EventModalOption(
          isSelected: _selected == EventVisibility.private,
          title: 'Özel',
          description: 'Sadece davet edilenler görebilir',
          onTap: () => _onSelect(EventVisibility.private),
        ),
        
      ],
    );
  }
}