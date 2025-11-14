import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:ui';
import 'dart:convert';

/// EventDescriptionModal - Etkinlik açıklama modal'ı
///
/// Kullanım:
/// ```dart
/// final result = await Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => EventDescriptionModal(
///       initialText: currentDescription,
///     ),
///     fullscreenDialog: true,
///   ),
/// );
/// if (result != null) {
///   setState(() => description = result);
/// }
/// ```
class EventDescriptionModal extends StatefulWidget {
  final String? initialText;

  const EventDescriptionModal({super.key, this.initialText});

  @override
  State<EventDescriptionModal> createState() => _EventDescriptionModalState();
}

class _EventDescriptionModalState extends State<EventDescriptionModal> {
  late quill.QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isToolbarVisible = false;

  @override
  void initState() {
    super.initState();

    // Controller'ı başlat
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      // Mevcut text varsa yükle
      try {
        final doc = quill.Document.fromJson(jsonDecode(widget.initialText!));
        _controller = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        // JSON parse hatası varsa düz text olarak ekle
        _controller = quill.QuillController.basic();
        _controller.document.insert(0, widget.initialText!);
      }
    } else {
      _controller = quill.QuillController.basic();
    }

    // Selection değişikliklerini dinle (toolbar'ı güncellemek için)
    _controller.addListener(() {
      setState(() {}); // Toolbar butonlarını güncelle
    });

    // Otomatik focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    // Quill document'ı JSON'a çevir
    final json = jsonEncode(_controller.document.toDelta().toJson());
    Navigator.of(context).pop(json);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Content
          Column(
            children: [
              // Header
              _buildHeader(statusBarHeight),

              // Editor
              Expanded(child: _buildEditor()),

              // Toolbar (klavyenin üzerinde)
              if (keyboardHeight > 0) _buildToolbar(),
            ],
          ),
        ],
      ),
    );
  }

  /// Background (blur)
  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.4,
              child: Image.asset(
                'assets/images/system/event-example.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: AppTheme.getCreateEventBg(context).withValues(alpha: 0.30),
            ),
          ),
        ],
      ),
    );
  }

  /// Header: [X] Açıklama Ekle [✓]
  Widget _buildHeader(double statusBarHeight) {
    return Container(
      padding: EdgeInsets.only(
        top: statusBarHeight + 10.h,
        left: 20.w,
        right: 20.w,
        bottom: 15.h,
      ),
      child: Row(
        children: [
          // Kapat butonu
          _buildIconButton(
            icon: LucideIcons.x400,
            onTap: () => Navigator.of(context).pop(),
          ),

          // Başlık
          Expanded(
            child: Center(
              child: Text(
                'Açıklama Ekle',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                  height: 1.2,
                ),
              ),
            ),
          ),

          // Kaydet butonu
          _buildIconButton(icon: LucideIcons.check400, onTap: _onSave),
        ],
      ),
    );
  }

  /// Icon Button
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 45.w,
      height: 45.w,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.getAppBarButtonBg(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.getAppBarButtonBorder(context),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 25.sp,
                color: AppTheme.getAppBarButtonColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Editor
  Widget _buildEditor() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppTheme.white,
            selectionColor: AppTheme.white.withValues(alpha: 0.30),
            selectionHandleColor: AppTheme.white,
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.white, // ✨ Beyaz text
            height: 1.5,
          ),
          child: quill.QuillEditor(
            controller: _controller,
            focusNode: _focusNode,
            scrollController: ScrollController(),
          ),
        ),
      ),
    );
  }

  /// Toolbar (klavyenin üzerinde)
  Widget _buildToolbar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth, // 🔥 Ekran genişliğine sabitle
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.black800.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  child: Row(
                    children: [
                      // H1
                      _buildToolbarButton(
                        icon: Icons.title,
                        attribute: quill.Attribute.h1,
                        label: 'H1',
                      ),
                      SizedBox(width: 4.w),

                      // H2
                      _buildToolbarButton(
                        icon: Icons.title,
                        attribute: quill.Attribute.h2,
                        label: 'H2',
                      ),
                      SizedBox(width: 4.w),

                      // Bold
                      _buildToolbarButton(
                        icon: Icons.format_bold,
                        attribute: quill.Attribute.bold,
                      ),
                      SizedBox(width: 4.w),

                      // Italic
                      _buildToolbarButton(
                        icon: Icons.format_italic,
                        attribute: quill.Attribute.italic,
                      ),
                      SizedBox(width: 4.w),

                      // Bullet List
                      _buildToolbarButton(
                        icon: Icons.format_list_bulleted,
                        attribute: quill.Attribute.ul,
                      ),
                      SizedBox(width: 4.w),

                      // Numbered List
                      _buildToolbarButton(
                        icon: Icons.format_list_numbered,
                        attribute: quill.Attribute.ol,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Toolbar Button
  Widget _buildToolbarButton({
    required IconData icon,
    required quill.Attribute attribute,
    String? label,
  }) {
    final attrs = _controller.getSelectionStyle().attributes;

    // Aynı key'e sahip (header/list) attribute'u al
    final current = attrs[attribute.key];

    // 🔥 Artık hem key hem value'ya bakıyoruz
    final isToggled = current != null && current.value == attribute.value;

    return GestureDetector(
      onTap: () {
        if (isToggled) {
          // Seçiliyse kaldır
          _controller.formatSelection(quill.Attribute.clone(attribute, null));
        } else {
          // Değilse bu attribute'u uygula
          _controller.formatSelection(attribute);
        }
      },
      child: Container(
        width: label != null ? 50.w : 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: isToggled
              ? AppTheme.white.withValues(alpha: .20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isToggled
                        ? AppTheme.white
                        : AppTheme.white.withValues(alpha: 0.60),
                  ),
                )
              : Icon(
                  icon,
                  size: 22.sp,
                  color: isToggled
                      ? AppTheme.white
                      : AppTheme.white.withOpacity(0.6),
                ),
        ),
      ),
    );
  }
}
