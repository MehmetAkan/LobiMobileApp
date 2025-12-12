import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/data/models/category_model.dart';
import 'package:lobi_application/data/models/event_model.dart';
import 'package:lobi_application/data/services/event_service.dart';
import 'package:lobi_application/screens/main/events/event_detail_screen.dart';
import 'package:lobi_application/data/services/favorite_categories_service.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/cards/events/event_card_vertical.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final CategoryModel category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  final _favService = FavoriteCategoriesService();
  final _eventService = getIt<EventService>();

  bool _isFavorite = false;
  bool _isLoadingFavorite = false;
  bool _isLoadingEvents = true;
  List<Map<String, dynamic>> _events = [];

  // Category descriptions
  final Map<String, String> _categoryDescriptions = {
    'Spor & Aktivite': 'Outdoor, fitness ve spor etkinlikleri keşfet',
    'Sanat & Kültür': 'Sergi, müze ve kültürel etkinlikler',
    'Eğitim & Workshop': 'Eğitici workshop ve seminerler',
    'Müzik & Konser': 'Canlı performanslar ve konserler',
    'Yemek & İçecek': 'Gastronomi ve lezzet etkinlikleri',
    'Oyun & Eğlence': 'Eğlence ve oyun etkinlikleri',
    'Sağlık & Wellness': 'Sağlık, meditasyon ve wellness',
    'İş & Networking': 'Profesyonel networking etkinlikleri',
    'Doğa & Açık Hava': 'Doğa gezileri ve açık hava aktiviteleri',
    'Tiyatro & Gösteri': 'Tiyatro gösterileri ve sahneleme',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    try {
      // Parallel fetch
      final results = await Future.wait([
        _favService.isFavoriteCategory(
          userId: userId,
          categoryId: widget.category.id,
        ),
        _eventService.getEventsByCategory(widget.category.id),
      ]);

      if (mounted) {
        setState(() {
          _isFavorite = results[0] as bool;
          _events = results[1] as List<Map<String, dynamic>>;
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEvents = false);
        getIt<AppFeedbackService>().showError('Yüklenirken hata oluştu');
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    setState(() => _isLoadingFavorite = true);

    try {
      if (_isFavorite) {
        await _favService.removeFavoriteCategory(
          userId: userId,
          categoryId: widget.category.id,
        );
      } else {
        await _favService.addFavoriteCategory(
          userId: userId,
          categoryId: widget.category.id,
        );
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
          _isLoadingFavorite = false;
        });

        getIt<AppFeedbackService>().showSuccess(
          _isFavorite ? 'Abone oldunuz' : 'Abonelikten çıkarıldı',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFavorite = false);
        getIt<AppFeedbackService>().showError('İşlem başarısız');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: widget.category.name,
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: widget.category.colorValue.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      widget.category.svgPath,
                      width: 40.w,
                      height: 40.h,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.category.name,
                  style: TextStyle(
                    fontSize: 24.sp,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextHeadColor(context),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _categoryDescriptions[widget.category.name] ??
                      'Bu kategorideki etkinlikleri keşfet',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.getTextDescColor(context),
                    height: 1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _isLoadingFavorite ? null : _toggleFavorite,
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: _isFavorite
                        ? AppTheme.getCategoryButtonBgActive(context)
                        : AppTheme.getCategoryButtonBg(context),
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(
                      color: _isFavorite
                          ? AppTheme.getCategoryButtonBorderActive(context)
                          : AppTheme.getCategoryButtonBorder(context),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: _isLoadingFavorite
                        ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _isFavorite
                                  ? AppTheme.white
                                  : AppTheme.black800,
                            ),
                          )
                        : Text(
                            _isFavorite ? 'Abone Oldunuz' : 'Abone Ol',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: _isFavorite
                                  ? AppTheme.getCategoryButtonTextActive(
                                      context,
                                    )
                                  : AppTheme.getCategoryButtonText(context),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 25.h),
              Text(
                'Etkinlikler (${_events.length})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black800,
                ),
              ),
              SizedBox(height: 0.h),
              if (_isLoadingEvents)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(0.h),
                    child: CircularProgressIndicator(color: AppTheme.zinc800),
                  ),
                )
              else if (_events.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.calendar400,
                          size: 64.sp,
                          color: AppTheme.zinc400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Henüz etkinlik yok',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.zinc600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  padding: const EdgeInsets.only(top: 15, bottom: 50),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppTheme.zinc200,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return EventCardVertical(
                      imageUrl: event['cover_image_url'] as String? ?? '',
                      title: event['title'] as String? ?? 'Başlıksız',
                      date: event['start_date'] as String? ?? '',
                      location: event['location_name'] as String? ?? '',
                      attendeeCount: event['participant_count'] as int? ?? 0,
                      organizerName: event['organizer_name'] as String?,
                      organizerUsername: event['organizer_username'] as String?,
                      organizerPhotoUrl:
                          event['organizer_photo_url'] as String?,
                      onTap: () {
                        // Parse to EventModel and navigate
                        final eventModel = EventModel(
                          id: event['id'] as String,
                          title: event['title'] as String? ?? '',
                          description: event['description'] as String? ?? '',
                          date: DateTime.parse(event['start_date'] as String),
                          location: event['location_name'] as String? ?? '',
                          imageUrl: event['cover_image_url'] as String? ?? '',
                          attendeeCount:
                              event['participant_count'] as int? ?? 0,
                          // Add organizer fields
                          organizerId: event['organizer_id'] as String?,
                          organizerName: event['organizer_name'] as String?,
                          organizerUsername:
                              event['organizer_username'] as String?,
                          organizerPhotoUrl:
                              event['organizer_photo_url'] as String?,
                          shareSlug: event['share_slug'] as String? ?? '',
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(event: eventModel),
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
