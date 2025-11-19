import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/pages/standard_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'event_manage_access_screen.dart';
import 'event_manage_checkin_screen.dart';
import 'event_manage_details_screen.dart';
import 'event_manage_guests_screen.dart';
import 'event_manage_questions_screen.dart';

class EventManageScreen extends StatelessWidget {
  const EventManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StandardPage(
      title: 'Etkinliği Yönet',
      children: [
        // 1. Grup: Etkinlik Detayları
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: LucideIcons.fileText,
              title: 'Etkinlik Detayları',
              description: 'Etkinlik bilgilerini düzenle',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManageDetailsScreen(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // 2. Grup: Katılımcı Yönetimi
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: LucideIcons.users,
              title: 'Misafir Listesi',
              description: 'Katılımcıları görüntüle ve yönet',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManageGuestsScreen(),
                ),
              ),
            ),
            _MenuItem(
              icon: LucideIcons.qrCode400,
              title: 'Misafir Katılımı İşaretle',
              description: 'QR kod veya manuel giriş',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManageCheckinScreen(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // 3. Grup: Ayarlar
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: LucideIcons.lock,
              title: 'Erişim',
              description: 'Gizlilik ve erişim ayarları',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManageAccessScreen(),
                ),
              ),
            ),
            _MenuItem(
              icon: LucideIcons.quote400,
              title: 'Kayıt Soruları',
              description: 'Katılımcılara sorulacak sorular',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventManageQuestionsScreen(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // 4. Grup: İptal
        _buildMenuGroup(
          context,
          items: [
            _MenuItem(
              icon: LucideIcons.circle400,
              title: 'Etkinliği İptal Et',
              description: 'Bu işlem geri alınamaz',
              isDestructive: true,
              onTap: () {
                // TODO: Show confirmation dialog
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuGroup(
    BuildContext context, {
    required List<_MenuItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.zinc100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              _buildMenuItemWidget(context, item),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(left: 56.w),
                  child: Divider(height: 1, color: AppTheme.zinc300),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuItemWidget(BuildContext context, _MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 24.sp,
                color: item.isDestructive ? AppTheme.red800 : AppTheme.zinc800,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: item.isDestructive
                            ? AppTheme.red800
                            : AppTheme.black800,
                      ),
                    ),
                    if (item.description != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.zinc600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 20.sp,
                color: AppTheme.zinc400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem({
    required this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.isDestructive = false,
  });
}
