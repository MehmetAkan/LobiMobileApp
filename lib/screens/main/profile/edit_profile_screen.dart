import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/providers/profile_provider.dart';
import 'package:lobi_application/data/services/profile_service.dart';
import 'package:lobi_application/data/services/storage_service.dart';
import 'package:lobi_application/core/feedback/app_feedback_service.dart';
import 'package:lobi_application/core/utils/logger.dart';
import 'package:lobi_application/core/di/service_locator.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/utils/image_picker_helper.dart';
import 'package:lobi_application/widgets/common/avatars/profile_avatar.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lobi_application/screens/main/profile/widgets/profile_photo_modal.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  bool _hasChanges = false;
  bool _isSaving = false;

  // Initial values to compare against
  final Map<String, String> _initialValues = {};

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Önce data yükle
    _setupListeners(); // Sonra listener'ları ekle (böylece setText tetiklemez)
  }

  void _setupListeners() {
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _instagramController.addListener(_onFieldChanged);
    _twitterController.addListener(_onFieldChanged);
    _tiktokController.addListener(_onFieldChanged);
    _youtubeController.addListener(_onFieldChanged);
    _websiteController.addListener(_onFieldChanged);
    _linkedinController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    // Check if any field has actually changed from initial value
    final hasRealChanges =
        _firstNameController.text != (_initialValues['firstName'] ?? '') ||
        _lastNameController.text != (_initialValues['lastName'] ?? '') ||
        _bioController.text != (_initialValues['bio'] ?? '') ||
        _instagramController.text != (_initialValues['instagram'] ?? '') ||
        _twitterController.text != (_initialValues['twitter'] ?? '') ||
        _tiktokController.text != (_initialValues['tiktok'] ?? '') ||
        _youtubeController.text != (_initialValues['youtube'] ?? '') ||
        _websiteController.text != (_initialValues['website'] ?? '') ||
        _linkedinController.text != (_initialValues['linkedin'] ?? '');

    if (hasRealChanges != _hasChanges) {
      setState(() => _hasChanges = hasRealChanges);
    }
  }

  void _loadUserData() {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _bioController.text = profile.bio ?? '';
      _instagramController.text = profile.instagram ?? '';
      _twitterController.text = profile.twitter ?? '';
      _tiktokController.text = profile.tiktok ?? '';
      _youtubeController.text = profile.youtube ?? '';
      _websiteController.text = profile.website ?? '';
      _linkedinController.text = profile.linkedin ?? '';

      // Save initial values for comparison
      _initialValues['firstName'] = profile.firstName;
      _initialValues['lastName'] = profile.lastName;
      _initialValues['bio'] = profile.bio ?? '';
      _initialValues['instagram'] = profile.instagram ?? '';
      _initialValues['twitter'] = profile.twitter ?? '';
      _initialValues['tiktok'] = profile.tiktok ?? '';
      _initialValues['youtube'] = profile.youtube ?? '';
      _initialValues['website'] = profile.website ?? '';
      _initialValues['linkedin'] = profile.linkedin ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Profil yüklenemedi: $error'))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('Profil bulunamadı')));
        }

        final fullName = '${profile.firstName} ${profile.lastName}';

        return StandardPage(
          title: 'Profili Düzenle',
          actionIcon: LucideIcons.check,
          actionIconBackgroundColor: _hasChanges
              ? AppTheme.getSettingsCheckButtonBgActive(context)
              : AppTheme.getSettingsCheckButtonBg(context),

          onActionTap: _hasChanges && !_isSaving ? _saveProfile : null,
          children: [
            // Profile Photo with Camera Icon
            _buildProfilePhoto(
              context,
              avatarUrl: profile.avatarUrl,
              fullName: fullName,
            ),
            SizedBox(height: 30.h),
            _buildPersonalInfoSection(),
            SizedBox(height: 20.h),
            _buildSectionTitle('Biyografi'),
            SizedBox(height: 10.h),
            _buildBioInput(),
            SizedBox(height: 20.h),
            _buildSectionTitle('Sosyal Hesaplar'),
            SizedBox(height: 10.h),
            _buildSocialAccountsSection(),
            SizedBox(height: 60),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    // Validate required fields
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      getIt<AppFeedbackService>().showError('İsim ve soyisim zorunludur');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentProfile = ref.read(currentUserProfileProvider).value;
      if (currentProfile == null) {
        throw Exception('Profil bulunamadı');
      }

      final profileService = ProfileService();
      await profileService.updateProfile(currentProfile.userId, {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'instagram': _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        'twitter': _twitterController.text.trim().isEmpty
            ? null
            : _twitterController.text.trim(),
        'tiktok': _tiktokController.text.trim().isEmpty
            ? null
            : _tiktokController.text.trim(),
        'youtube': _youtubeController.text.trim().isEmpty
            ? null
            : _youtubeController.text.trim(),
        'website': _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        'linkedin': _linkedinController.text.trim().isEmpty
            ? null
            : _linkedinController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Refresh profile provider
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        setState(() {
          _hasChanges = false;
          _isSaving = false;
        });

        getIt<AppFeedbackService>().showSuccess('Profil güncellendi');

        // Go back to previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        getIt<AppFeedbackService>().showError('Profil güncellenemedi');
      }
    }
  }

  Widget _buildProfilePhoto(
    BuildContext context, {
    required String? avatarUrl,
    required String fullName,
  }) {
    return Center(
      child: Stack(
        children: [
          // Profile Avatar
          ProfileAvatar(imageUrl: avatarUrl, name: fullName, size: 100),
          // Camera Icon
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                ProfilePhotoModal.show(
                  context,
                  onTakePhoto: () async {
                    // Check camera permission
                    final permStatus = await Permission.camera.status;

                    if (permStatus.isDenied) {
                      final result = await Permission.camera.request();
                      if (!result.isGranted) {
                        getIt<AppFeedbackService>().showError(
                          'Kamera izni gerekli',
                        );
                        return;
                      }
                    }

                    final pickerHelper = ImagePickerHelper(getIt());
                    final result = await pickerHelper
                        .takeAndCropCircularPhoto();

                    if (result.isSuccess && result.imageFile != null) {
                      // Show loading
                      getIt<AppFeedbackService>().showInfo(
                        'Fotoğraf yükleniyor...',
                      );

                      try {
                        final currentProfile = ref
                            .read(currentUserProfileProvider)
                            .value;
                        if (currentProfile == null) {
                          throw Exception('Profil bulunamadı');
                        }

                        // Upload to storage
                        final storageService = StorageService();
                        final newAvatarUrl = await storageService
                            .uploadProfilePhoto(
                              userId: currentProfile.userId,
                              imageFile: result.imageFile!,
                            );

                        // Update profile with new avatar URL
                        final profileService = ProfileService();
                        await profileService.updateProfile(
                          currentProfile.userId,
                          {'avatar_url': newAvatarUrl},
                        );

                        // Refresh profile
                        ref.invalidate(currentUserProfileProvider);

                        getIt<AppFeedbackService>().showSuccess(
                          'Profil fotoğrafı güncellendi',
                        );
                      } catch (e) {
                        AppLogger.error('Profil fotoğrafı yükleme hatası', e);
                        getIt<AppFeedbackService>().showError(
                          'Fotoğraf yüklenemedi. Tekrar deneyin.',
                        );
                      }
                    } else if (result.errorMessage != null) {
                      getIt<AppFeedbackService>().showError(
                        result.errorMessage!,
                      );
                    }
                  },
                  onChoosePhoto: () async {
                    final pickerHelper = ImagePickerHelper(getIt());
                    final result = await pickerHelper
                        .pickAndCropCircularImage();

                    if (result.isSuccess && result.imageFile != null) {
                      // Show loading
                      getIt<AppFeedbackService>().showInfo(
                        'Fotoğraf yükleniyor...',
                      );

                      try {
                        final currentProfile = ref
                            .read(currentUserProfileProvider)
                            .value;
                        if (currentProfile == null) {
                          throw Exception('Profil bulunamadı');
                        }

                        // Upload to storage
                        final storageService = StorageService();
                        final newAvatarUrl = await storageService
                            .uploadProfilePhoto(
                              userId: currentProfile.userId,
                              imageFile: result.imageFile!,
                            );

                        // Update profile with new avatar URL
                        final profileService = ProfileService();
                        await profileService.updateProfile(
                          currentProfile.userId,
                          {'avatar_url': newAvatarUrl},
                        );

                        // Refresh profile
                        ref.invalidate(currentUserProfileProvider);

                        getIt<AppFeedbackService>().showSuccess(
                          'Profil fotoğrafı güncellendi',
                        );
                      } catch (e) {
                        AppLogger.error('Profil fotoğrafı yükleme hatası', e);
                        getIt<AppFeedbackService>().showError(
                          'Fotoğraf yüklenemedi. Tekrar deneyin.',
                        );
                      }
                    } else if (result.errorMessage != null) {
                      getIt<AppFeedbackService>().showError(
                        result.errorMessage!,
                      );
                    }
                  },
                  onDeletePhoto: () {
                    debugPrint('Delete photo');
                    // TODO: Delete photo
                  },
                );
              },
              child: Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppTheme.black800,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.white, width: 3),
                ),
                child: Icon(
                  LucideIcons.camera,
                  size: 18.sp,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSettingsCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.getSettingsCardBorder(context)),
      ),
      child: Column(
        children: [
          _buildInfoRow('İsim', _firstNameController),
          _buildDivider(),
          _buildInfoRow('Soyad', _lastNameController),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                letterSpacing: -0.20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getSettingsProfileLabel(context),
              ),
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextHeadColor(context),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: label,
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.getSettingsProfileHint(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppTheme.getSettingsCardDivider(context));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          letterSpacing: -0.20,
          fontWeight: FontWeight.w600,
          color: AppTheme.getSettingsProfileSmallHead(context),
        ),
      ),
    );
  }

  Widget _buildBioInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSettingsCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.getSettingsCardBorder(context)),
      ),
      padding: EdgeInsets.all(15.w),
      child: TextField(
        controller: _bioController,
        maxLines: 5,
        maxLength: 200,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: AppTheme.getTextHeadColor(context),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Kendiniz hakkında birkaç kelime yazın...',
          hintStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.getSettingsProfileHint(context),
          ),
          counterStyle: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.getSettingsProfileHint(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialAccountsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSettingsCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.getSettingsCardBorder(context)),
      ),
      child: Column(
        children: [
          _buildSocialRow(
            'Instagram',
            'assets/images/system/settings/instagram.png',
            _instagramController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'TikTok',
            'assets/images/system/settings/tiktok.png',
            _tiktokController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'Twitter',
            'assets/images/system/settings/twitter.png',
            _twitterController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'YouTube',
            'assets/images/system/settings/youtube.png',
            _youtubeController,
          ),

          _buildDivider(),
          _buildSocialRow(
            'LinkedIn',
            'assets/images/system/settings/linkedin.png',
            _linkedinController,
          ),
          _buildDivider(),
          _buildSocialRow(
            'Website',
            'assets/images/system/settings/web.png',
            _websiteController,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(
    String label,
    String? svgPath,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      child: Row(
        children: [
          // Icon/SVG
          SizedBox(
            width: 24.sp,
            height: 24.sp,
            child: icon != null
                ? Icon(icon, size: 20.sp, color: AppTheme.zinc600)
                : Image.asset(
                    svgPath!,
                    width: 24.sp,
                    height: 24.sp,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      LucideIcons.link,
                      size: 20.sp,
                      color: AppTheme.zinc600,
                    ),
                  ),
          ),
          SizedBox(width: 15.w),
          // Platform Name
          SizedBox(
            width: 90.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                letterSpacing: -0.20,
                fontWeight: FontWeight.w500,
                color: AppTheme.getSettingsProfileLabel(context),
              ),
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextHeadColor(context),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'kullanıcıadı',
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.getSettingsProfileHint(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
