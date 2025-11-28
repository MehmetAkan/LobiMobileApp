import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PrivacyPolicyModal {
  static void show(BuildContext context) {
    CustomModalSheet.show(
      context: context,
      headerLeft: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon in circle
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppTheme.zinc200,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.zinc300, width: 1.w),
            ),
            child: Icon(
              LucideIcons.scrollText400,
              size: 24.sp,
              color: AppTheme.zinc700,
            ),
          ),
          SizedBox(height: 15.h),
          // Title
          Text(
            'Gizlilik Sözleşmesi',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextHeadColor(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Son güncelleme: 28 Kasım 2024',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.zinc600,
            ),
          ),
        ],
      ),
      showDivider: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            title: '1. Toplanan Veriler',
            content:
                'Lobi uygulaması, size daha iyi hizmet verebilmek için kişisel bilgilerinizi toplar ve işler. Bu bilgiler arasında adınız, e-posta adresiniz, telefon numaranız, profil fotoğrafınız ve etkinlik tercihleriniz yer almaktadır.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '2. Verilerin Kullanımı',
            content:
                'Toplanan veriler, hesabınızı yönetmek, etkinlik önerileri sunmak, iletişim kurmak ve hizmetlerimizi geliştirmek amacıyla kullanılır. Verileriniz, yasal yükümlülükler dışında üçüncü taraflarla paylaşılmaz.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '3. Veri Güvenliği',
            content:
                'Kişisel verilerinizin güvenliği bizim için önemlidir. Endüstri standartlarına uygun güvenlik önlemleri alarak verilerinizi korumaktayız. Ancak, internet üzerinden veri iletiminin tamamen güvenli olduğu garanti edilemez.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '4. Çerezler',
            content:
                'Uygulamamız, kullanıcı deneyimini iyileştirmek için çerezler kullanabilir. Çerezler, tercihlerinizi hatırlamak ve uygulama performansını optimize etmek için kullanılır.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '5. Üçüncü Taraf Hizmetleri',
            content:
                'Uygulamamız, analiz ve reklam hizmetleri için üçüncü taraf servisleri kullanabilir. Bu servisler kendi gizlilik politikalarına tabidir.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '6. Haklarınız',
            content:
                'KVKK kapsamında, kişisel verilerinize erişme, düzeltme, silme ve işlenmesine itiraz etme haklarına sahipsiniz. Bu haklarınızı kullanmak için destek ekibimizle iletişime geçebilirsiniz.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '7. Değişiklikler',
            content:
                'Bu gizlilik politikası zaman zaman güncellenebilir. Önemli değişiklikler olduğunda sizi bilgilendireceğiz. Güncel politikayı düzenli olarak kontrol etmenizi öneririz.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '8. İletişim',
            content:
                'Gizlilik politikamız hakkında sorularınız varsa, lütfen destek@lobiapp.com adresinden bizimle iletişime geçin.',
          ),
        ],
      ),
    );
  }

  static Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.getTextHeadColor(context),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.zinc700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
