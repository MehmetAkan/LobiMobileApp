import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✨ YENİ
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/event_provider.dart'; // ✨ YENİ
import 'package:lobi_application/screens/main/events/widgets/create/sections/create_event_cover_section.dart';
import 'package:lobi_application/screens/main/events/widgets/global/event_background.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_text_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_datetime_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_location_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_description_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_settings_box.dart';
import 'package:lobi_application/screens/main/events/widgets/create/forms/event_settings_item.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_visibility_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_capacity_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_description_modal.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/location_picker_modal.dart';
import 'package:lobi_application/utils/event_description_helper.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/data/services/location_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lobi_application/data/models/category_model.dart';
// ✨ SİLİNDİ: import 'package:lobi_application/screens/main/events/widgets/create/forms/event_category_field.dart';
import 'package:lobi_application/screens/main/events/widgets/create/modals/event_category_modal.dart';

// ✨ DEĞİŞTİ: StatefulWidget -> ConsumerStatefulWidget
class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  // ✨ DEĞİŞTİ: State -> ConsumerState
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

// ✨ DEĞİŞTİ: State -> ConsumerState
class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  LocationModel? _selectedLocationModel;
  CategoryModel? _selectedCategory;
  String? _description;
  String? _coverPhotoUrl;
  bool _isApprovalRequired = false;
  EventVisibility _visibility = EventVisibility.public;
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

  /// ✨ Kontenjan modal'ını aç
  Future<void> _openCapacityModal() async {
    final result = await EventCapacityModal.show(
      context: context,
      currentValue: _capacity,
    );

    setState(() {
      _capacity = result;
    });
  }

  /// ✨ Açıklama modal'ını aç
  Future<void> _openDescriptionModal() async {
    final result = await Navigator.push(
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

  /// ✨ Konum modal'ını aç
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

  /// ✨ Kategori modal'ını aç
  Future<void> _openCategoryModal() async {
    final category = await EventCategoryModal.show(
      context: context,
      currentValue: _selectedCategory,
    );

    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      debugPrint('🎨 Kategori seçildi: ${category.name}');
    }
  }

  Future<void> _submitCreateEvent() async {
    // Provider'ı çağırmadan önce 'ref.read' kullanarak
    // 'CreateEventController'ın 'notifier'ına (kendisine) erişiyoruz.
    final bool success = await ref
        .read(createEventControllerProvider.notifier)
        .createEvent(
          title: _titleController.text,
          description: _description,
          coverPhotoUrl: _coverPhotoUrl,
          startDate: _startDate,
          endDate: _endDate,
          location: _selectedLocationModel,
          category: _selectedCategory,
          visibility: _visibility,
          isApprovalRequired: _isApprovalRequired,
          capacity: _capacity,
        );

    if (success && mounted) {
      // Başarılı olursa ekranı kapat
      _showSnackBar('Etkinlik başarıyla oluşturuldu!', isError: false);
      Navigator.of(context).pop();
    }
    // Hata durumu 'ref.listen' tarafından otomatik olarak ele alınacak
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✨ YENİ: Provider'ın durumunu (loading, error, data) dinle
    ref.listen<AsyncValue<void>>(
      createEventControllerProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            debugPrint('==== ETKİNLİK OLUŞTURMA HATASI ====');
            debugPrint('HATA: $error');
            debugPrint('STACK TRACE: $stackTrace');
            debugPrint('====================================');
            final errorMessage = error.toString().startsWith('Exception: ')
                ? error.toString().substring(11) // "Exception: " kısmını (11 karakter) atla
                : error.toString();
            _showSnackBar(errorMessage);
          },
        );
      },
    );

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 60.h + statusBarHeight;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: screenHeight,
        child: Stack(
          children: [
            EventBackground(coverPhotoUrl: _coverPhotoUrl),
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
                    onPhotoSelected: (url) {
                      setState(() {
                        _coverPhotoUrl = url;
                      });
                    },
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
                        ? EventDescriptionHelper.getPlainText(_description)
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
                  SizedBox(height: 20.h),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.white.withOpacity(0.2),
                  ),
                  SizedBox(height: 20.h),
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
                        value: _capacity != null
                            ? EventCapacityModal.getDisplayText(_capacity)
                            : null,
                        onTap: _openCapacityModal,
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
                title: 'Yeni Etkinlik',
                scrollController: _scrollController,
                style: AppBarStyle.dark,
                // ✨ DEĞİŞTİ: ref eklendi
                actions: [_buildSaveButton(ref)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(WidgetRef ref) {
  
    final createEventState = ref.watch(createEventControllerProvider);
    final bool isLoading = createEventState is AsyncLoading;

    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: SizedBox(
        width: 45.w,
        height: 45.w,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            // ✨ DEĞİŞTİ: 'isLoading' ise null, değilse '_submitCreateEvent'
            onTap: isLoading ? null : _submitCreateEvent,
            customBorder: const CircleBorder(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getAppBarButtonBg(context).withOpacity(
                  isLoading ? 0.5 : 1.0,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.getAppBarButtonBorder(context),
                  width: 1,
                ),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 22.sp,
                        height: 22.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.getAppBarButtonColor(context),
                        ),
                      )
                    : Icon(
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