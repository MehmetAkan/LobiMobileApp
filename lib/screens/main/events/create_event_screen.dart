import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lobi_application/widgets/common/forms/events/event_text_field.dart';
import 'package:lobi_application/widgets/common/forms/events/event_datetime_field.dart';
import 'package:lobi_application/widgets/common/forms/events/event_location_field.dart';
import 'package:lobi_application/widgets/common/forms/events/event_description_field.dart';
import 'package:lobi_application/widgets/common/forms/events/event_settings_box.dart';
import 'package:lobi_application/widgets/common/forms/events/event_settings_item.dart';
import 'package:lobi_application/widgets/common/modals/event_visibility_modal.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'dart:ui';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  String? _selectedLocation;
  String? _description;

  bool _isApprovalRequired = false;
  EventVisibility _visibility = EventVisibility.public; // ✨ YENİ
  int? _capacity;

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// ✨ Görünürlük modal'ını aç
  Future<void> _openVisibilityModal() async {
    final result = await EventVisibilityModal.show(
      context: context,
      currentValue: _visibility,
    );

    if (result != null) {
      setState(() {
        _visibility = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 60.h + statusBarHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            _buildBackground(),
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                20.w,
                appBarHeight + 20.h,
                20.w,
                40.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverImage(),
                  SizedBox(height: 20.h),
                  EventTextField(
                    controller: _titleController,
                    placeholder: 'Etkinlik başlığını girin',
                    maxLength: 100,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: EventDateTimeField(
                          value: _startDate,
                          placeholder: 'Başlangıç',
                          onChanged: (date) {
                            setState(() {
                              _startDate = date;
                              if (_endDate == null ||
                                  _endDate!.isBefore(date)) {
                                _endDate = date.add(const Duration(hours: 1));
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: EventDateTimeField(
                          value: _endDate,
                          placeholder: 'Bitiş',
                          firstDate: _startDate,
                          onChanged: (date) {
                            setState(() => _endDate = date);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  EventLocationField(
                    value: _selectedLocation,
                    onTap: () {
                      debugPrint('Konum modal açılıyor...');
                      setState(() {
                        _selectedLocation = 'Konya Kültür Merkezi';
                      });
                    },
                  ),

                  SizedBox(height: 10.h),

                  EventDescriptionField(
                    value: _description,
                    onTap: () {
                      debugPrint('Açıklama modal açılıyor...');
                      setState(() {
                        _description =
                            'Bu etkinlik hakkında kısa bir açıklama...';
                      });
                    },
                  ),

                  SizedBox(height: 20.h),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.white.withOpacity(0.2),
                  ),

                  SizedBox(height: 20.h),

                  // ✨ Başlık: Katılımcı Yönetimi
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 0.h),
                    child: Text(
                      'Biletlendirme',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white.withOpacity(0.8),
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  EventSettingsBox(
                    children: [
                      EventSettingsItem.switchType(
                        icon: LucideIcons.lock400,
                        label: 'Onay gerekli',
                        value: _isApprovalRequired,
                        showDivider: false,
                        onChanged: (value) {
                          setState(() => _isApprovalRequired = value);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 0.h),
                    child: Text(
                      'Seçenekler',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white.withOpacity(0.8),
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  EventSettingsBox(
                    children: [
                      // ✨ Görünürlük - Modal ile güncellendi
                      EventSettingsItem.action(
                        icon: LucideIcons.globe400,
                        label: 'Görünürlük',
                        placeholder: 'Herkese Açık',
                        value: EventVisibilityModal.getDisplayText(_visibility),
                        onTap: _openVisibilityModal,
                      ),
                      EventSettingsItem.action(
                        icon: LucideIcons.users400,
                        label: 'Kontenjan',
                        placeholder: 'Sınırsız',
                        value: _capacity != null ? '$_capacity kişi' : null,
                        onTap: () {
                          debugPrint('Kontenjan modal açılıyor...');
                          setState(() {
                            _capacity = 100;
                          });
                        },
                        showDivider: false,
                      ),
                    ],
                  ),

                  SizedBox(height: 15.h),

                  ...List.generate(
                    8,
                    (i) => Container(
                      height: 60.h,
                      margin: EdgeInsets.only(bottom: 15.h),
                      decoration: BoxDecoration(
                        color: AppTheme.zinc200.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppTheme.zinc300, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          'Input ${i + 2}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.zinc600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FullPageAppBar(
                title: 'Yeni Etkinlik',
                scrollController: _scrollController,
                style: AppBarStyle.dark,
                actions: [_buildSaveButton()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: 1.4,
              child: Image.asset(
                'assets/images/system/event-example-white.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: AppTheme.getCreateEventBg(context).withOpacity(0.30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              'assets/images/system/event-example-white.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(right: 12.w, bottom: 12.h, child: _buildGalleryButton()),
      ],
    );
  }

  Widget _buildGalleryButton() {
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            debugPrint('Galeri açılıyor...');
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

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              debugPrint('Başlık: ${_titleController.text}');
              debugPrint('Başlangıç: $_startDate');
              debugPrint('Bitiş: $_endDate');
              debugPrint('Konum: $_selectedLocation');
              debugPrint('Açıklama: $_description');
              debugPrint('Görünürlük: $_visibility'); // ✨ YENİ
              Navigator.of(context).pop();
            },
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
                  LucideIcons.check400,
                  size: 25.sp,
                  color: AppTheme.getAppBarButtonColor(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}