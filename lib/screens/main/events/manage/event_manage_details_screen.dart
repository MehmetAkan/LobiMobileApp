import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lobi_application/screens/main/events/widgets/create/sections/create_event_cover_section.dart';
import 'package:lobi_application/screens/main/events/widgets/global/event_background.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_text_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_datetime_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_location_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_description_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_settings_box.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_settings_item.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_description_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/location_picker_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_category_modal.dart';
import 'package:lobi_application/utils/event_description_helper.dart';
import 'package:lobi_application/data/services/location_service.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const List<String> kDefaultEventCovers = [
  'assets/images/system/events_cover/events_cover_1.jpg',
  'assets/images/system/events_cover/events_cover_2.jpg',
  'assets/images/system/events_cover/events_cover_3.jpg',
  'assets/images/system/events_cover/events_cover_4.jpg',
  'assets/images/system/events_cover/events_cover_5.jpg',
  'assets/images/system/events_cover/events_cover_6.jpg',
  'assets/images/system/events_cover/events_cover_7.jpg',
  'assets/images/system/events_cover/events_cover_8.jpg',
  'assets/images/system/events_cover/events_cover_9.jpg',
  'assets/images/system/events_cover/events_cover_10.jpg',
];

class EventManageDetailsScreen extends StatefulWidget {
  const EventManageDetailsScreen({super.key});

  @override
  State<EventManageDetailsScreen> createState() =>
      _EventManageDetailsScreenState();
}

class _EventManageDetailsScreenState extends State<EventManageDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final _random = Random();

  late TextEditingController _titleController;
  DateTime? _startDate;
  DateTime? _endDate;
  LocationModel? _selectedLocationModel;
  CategoryModel? _selectedCategory;
  String? _description;
  String? _coverPhotoUrl;
  late final String _initialCoverAsset;

  @override
  void initState() {
    super.initState();
    _initialCoverAsset =
        kDefaultEventCovers[_random.nextInt(kDefaultEventCovers.length)];

    // TODO: Load existing event data from provider
    // For now, initialize with placeholder data
    _titleController = TextEditingController(text: 'Mevcut Etkinlik Başlığı');
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(hours: 2));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _handlePhotoSelected(String url) {
    setState(() {
      _coverPhotoUrl = url;
    });
  }

  /// Açıklama modal'ını aç
  Future<void> _openDescriptionModal() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (context) => EventDescriptionModal(initialText: _description),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      setState(() {
        _description = result;
      });
    }
  }

  /// Konum modal'ını aç
  Future<void> _openLocationModal() async {
    final location = await LocationPickerModal.show(context: context);

    if (location != null) {
      setState(() {
        _selectedLocationModel = location;
      });

      debugPrint('📍 Konum seçildi: ${location.placeName}');
      debugPrint('🗺️ ${location.latitude}, ${location.longitude}');
    }
  }

  /// Kategori modal'ını aç
  Future<void> _openCategoryModal() async {
    final category = await EventCategoryModal.show(
      context: context,
      currentValue: _selectedCategory,
    );

    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });

      debugPrint('📂 Kategori seçildi: ${category.name}');
    }
  }

  /// Etkinlik güncelleme
  Future<void> _updateEvent() async {
    // TODO: Implement update event with provider
    final String coverImageUrlToSave = _coverPhotoUrl ?? _initialCoverAsset;

    debugPrint('=== ETKİNLİK GÜNCELLEME ===');
    debugPrint('Başlık: ${_titleController.text}');
    debugPrint('Cover: $coverImageUrlToSave');
    debugPrint('Başlangıç: $_startDate');
    debugPrint('Bitiş: $_endDate');
    debugPrint('Konum: ${_selectedLocationModel?.placeName}');
    debugPrint('Kategori: ${_selectedCategory?.name}');
    debugPrint('Açıklama: $_description');
    debugPrint('========================');

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Etkinlik başarıyla güncellendi!'),
          backgroundColor: AppTheme.green500,
          duration: const Duration(seconds: 2),
        ),
      );
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
            EventBackground(
              coverPhotoUrl: _coverPhotoUrl,
              defaultCoverAsset: _initialCoverAsset,
            ),
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
                  CreateEventCoverSection(
                    coverPhotoUrl: _coverPhotoUrl,
                    defaultCoverAsset: _initialCoverAsset,
                    onPhotoSelected: _handlePhotoSelected,
                  ),
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
                    value: _selectedLocationModel?.displayText,
                    onTap: _openLocationModal,
                  ),
                  SizedBox(height: 10.h),
                  EventDescriptionField(
                    value: _description != null
                        ? EventDescriptionHelper.getPlainText(_description!)
                        : null,
                    onTap: _openDescriptionModal,
                  ),
                  SizedBox(height: 10.h),
                  EventSettingsBox(
                    children: [
                      EventSettingsItem.action(
                        icon: LucideIcons.layoutGrid400,
                        label: 'Kategori',
                        placeholder: 'Kategori Seç',
                        value: _selectedCategory != null
                            ? EventCategoryModal.getDisplayText(
                                _selectedCategory!,
                              )
                            : null,
                        onTap: _openCategoryModal,
                        showDivider: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FullPageAppBar(
                title: 'Etkinlik Detayları',
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

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _updateEvent,
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getAppBarButtonBg(context).withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getAppBarButtonBorder(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.check400,
                  size: 22.sp,
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
