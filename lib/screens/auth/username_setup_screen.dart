import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/data/services/username_service.dart';
import 'package:lobi_application/screens/auth/favorite_categories_screen.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/auth/auth_back_button.dart';
import 'package:lobi_application/widgets/auth/auth_primary_button.dart';
import 'package:lobi_application/widgets/auth/auth_text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum UsernameState { idle, checking, available, taken, invalid }

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _controller = TextEditingController();
  final _usernameService = UsernameService();
  Timer? _debounce;

  UsernameState _state = UsernameState.idle;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    // Cancel previous debounce
    _debounce?.cancel();

    // Convert to lowercase
    final lowerValue = value.toLowerCase();
    if (lowerValue != value) {
      _controller.value = _controller.value.copyWith(
        text: lowerValue,
        selection: TextSelection.collapsed(offset: lowerValue.length),
      );
      return;
    }

    // Empty check
    if (value.isEmpty) {
      setState(() {
        _state = UsernameState.idle;
        _errorMessage = null;
      });
      return;
    }

    // Client-side validation
    final validation = UsernameService.validateFormat(value);
    if (validation != UsernameValidation.valid) {
      setState(() {
        _state = UsernameState.invalid;
        _errorMessage = validation.message;
      });
      return;
    }

    // Set checking state
    setState(() {
      _state = UsernameState.checking;
      _errorMessage = null;
    });

    // Debounced API call
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final available = await _usernameService.checkAvailability(value);

      if (!mounted) return;

      setState(() {
        _state = available ? UsernameState.available : UsernameState.taken;
        _errorMessage = available ? null : 'Bu kullanıcı adı alınmış';
      });
    });
  }

  Future<void> _handleContinue() async {
    if (_state != UsernameState.available) return;

    setState(() => _isLoading = true);

    try {
      await _usernameService.saveUsername(_controller.text);

      if (!mounted) return;

      // Navigate to favorite categories
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const FavoriteCategoriesScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Kullanıcı adı kaydedilemedi. Tekrar deneyin.';
        _state = UsernameState.invalid;
        _isLoading = false;
      });
    }
  }

  Widget _buildStatusIcon() {
    switch (_state) {
      case UsernameState.idle:
        return Icon(LucideIcons.user400, size: 20.sp, color: AppTheme.zinc600);
      case UsernameState.checking:
        return SizedBox(
          width: 20.sp,
          height: 20.sp,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.zinc600,
          ),
        );
      case UsernameState.available:
        return Icon(
          LucideIcons.check400,
          size: 20.sp,
          color: AppTheme.green500,
        );
      case UsernameState.taken:
      case UsernameState.invalid:
        return Icon(LucideIcons.x400, size: 20.sp, color: AppTheme.red700);
    }
  }

  Color _buildFieldBorderColor() {
    switch (_state) {
      case UsernameState.available:
        return AppTheme.green500;
      case UsernameState.taken:
      case UsernameState.invalid:
        return AppTheme.red700;
      default:
        return AppTheme.getAuthInputBorder(context);
        ;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final isButtonEnabled = _state == UsernameState.available && !_isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 30.h),
                        child: const AuthBackButton(),
                      ),
                      Container(
                        width: 55.w,
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: AppTheme.getAuthIconBg(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            LucideIcons.atSign400,
                            size: 30.sp,
                            color: AppTheme.getAuthIconColor(context),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'Kullanıcı Adını Seç',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 35.sp,
                          letterSpacing: -0.20,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getAuthHeadText(context),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        'Kullanıcı adın profil URL\'inde görünecek ve diğer kullanıcılar seni bu şekilde bulabilecek.',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 16.sp,
                          letterSpacing: -0.20,
                          height: 1.1,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.getAuthDescText(context),
                        ),
                      ),
                      SizedBox(height: 25.h),

                      // Username field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kullanıcı Adı',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getAuthHeadText(context),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                color: _buildFieldBorderColor(),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 15.w),
                                  child: Text(
                                    '@',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getAuthInputHint(context),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    onChanged: _onUsernameChanged,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.getAuthInputText(context),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'kullanıcı adı',
                                      hintStyle: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.getAuthInputHint(
                                          context,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 3.w,
                                        vertical: 16.h,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 15.w),
                                  child: _buildStatusIcon(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Character counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_errorMessage != null)
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.red700,
                                    ),
                                  ),
                                ),
                              Text(
                                '${_controller.text.length}/20',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.getAuthInputHint(context),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h),

                          // Rules
                          Container(
                            padding: EdgeInsets.all(15.w),
                            decoration: BoxDecoration(
                              color: AppTheme.getAuthCardBg(context),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRule(
                                  'Sadece küçük harf kullanabilirsiniz',
                                ),
                                SizedBox(height: 6.h),
                                _buildRule('Rakam, _ ve - kullanabilirsiniz'),
                                SizedBox(height: 6.h),
                                _buildRule('3-20 karakter arası olmalı'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h + bottomInset),
                child: AuthPrimaryButton(
                  label: _isLoading ? 'Kaydediliyor...' : 'Devam Et',
                  onTap: isButtonEnabled ? _handleContinue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRule(String text) {
    return Row(
      children: [
        Icon(
          LucideIcons.check400,
          size: 14.sp,
          color: AppTheme.getAuthCarText(context),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.getAuthCarText(context),
          ),
        ),
      ],
    );
  }
}
