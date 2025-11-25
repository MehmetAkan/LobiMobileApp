import 'package:flutter/material.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_modal_sheet.dart';
import 'package:lobi_application/screens/main/events/widgets/manage/access/modals/event_access_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum EventAccessVisibility { public, private }

class EventAccessVisibilityModal {
  static Future<EventAccessVisibility?> show({
    required BuildContext context,
    required EventAccessVisibility currentValue,
  }) {
    return showModalBottomSheet<EventAccessVisibility>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VisibilityContent(currentValue: currentValue),
    );
  }

  /// Display text
  static String getDisplayText(EventAccessVisibility type) {
    switch (type) {
      case EventAccessVisibility.public:
        return 'Herkese Açık';
      case EventAccessVisibility.private:
        return 'Özel';
    }
  }
}

class _VisibilityContent extends StatefulWidget {
  final EventAccessVisibility currentValue;

  const _VisibilityContent({required this.currentValue});

  @override
  State<_VisibilityContent> createState() => _VisibilityContentState();
}

class _VisibilityContentState extends State<_VisibilityContent> {
  late EventAccessVisibility _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentValue;
  }

  void _onSelect(EventAccessVisibility value) {
    setState(() => _selected = value);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) Navigator.of(context).pop(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return EventAccessModalSheet(
      icon: LucideIcons.globe400,
      title: 'Etkinliğin Görünürlüğü',
      description:
          'Bu Etkinliğinizi kimler görebileceğiniz seçin ? Direkt erişim link olanlar görebilir.',
      children: [
        EventModalAccessOption(
          isSelected: _selected == EventAccessVisibility.public,
          title: 'Herkese Açık',
          description: 'Herkes görebilir ve katılabilir',
          onTap: () => _onSelect(EventAccessVisibility.public),
        ),
        EventModalAccessOption(
          isSelected: _selected == EventAccessVisibility.private,
          title: 'Özel',
          description: 'Sadece davet edilenler görebilir',
          onTap: () => _onSelect(EventAccessVisibility.private),
        ),
      ],
    );
  }
}
