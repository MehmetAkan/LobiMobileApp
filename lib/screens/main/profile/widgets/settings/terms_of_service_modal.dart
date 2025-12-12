import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_text_styles.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/modals/custom_modal_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TermsOfServiceModal {
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
              color: AppTheme.getModalIconBg(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.getModalIconBorder(context),
                width: 1.w,
              ),
            ),
            child: Icon(
              LucideIcons.fileUser400,
              size: 24.sp,
              color: AppTheme.getModalIconText(context),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'Kullanıcı Sözleşmesi',
            style: AppTextStyles.titleHead_XL.copyWith(
              color: AppTheme.getTextHeadColor(context),
            ),
          ),
          SizedBox(height: 15.h),
        ],
      ),
      showDivider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            title: '1. Hizmetin Kabul Edilmesi',
            content:
                'Lobi uygulamasını kullanarak, bu kullanım koşullarını kabul etmiş olursunuz. Bu koşulları kabul etmiyorsanız, lütfen uygulamayı kullanmayın.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '2. Hesap Oluşturma',
            content:
                'Lobi\'de hesap oluşturmak için 18 yaşından büyük olmanız gerekmektedir. Hesap bilgilerinizin doğru ve güncel olmasından siz sorumlusunuz. Hesap güvenliğinizi sağlamak adına şifrenizi kimseyle paylaşmamalısınız.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '3. Kullanıcı Davranışları',
            content:
                'Uygulamayı kullanırken yasalara uygun davranmalı, başkalarının haklarına saygı göstermeli ve zararlı içerikler paylaşmamalısınız. Spam, taciz, nefret söylemi ve yanıltıcı bilgiler paylaşmak yasaktır.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '4. Etkinlik Oluşturma',
            content:
                'Etkinlik oluştururken, doğru ve eksiksiz bilgi sağlamalısınız. Yanıltıcı veya yasadışı etkinlikler oluşturmak yasaktır. Etkinliklerinizden siz sorumlusunuz.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '5. Fikri Mülkiyet',
            content:
                'Lobi uygulamasında yer alan tüm içerikler ve tasarımlar telif hakkı ile korunmaktadır. İzin almadan bu içerikleri kopyalayamaz, dağıtamaz veya ticari amaçlarla kullanamazsınız.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '6. Hizmet Değişiklikleri',
            content:
                'Lobi, sunduğu hizmetleri dilediği zaman değiştirme, askıya alma veya sonlandırma hakkını saklı tutar. Önemli değişiklikler önceden duyurulacaktır.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '7. Sorumluluk Reddi',
            content:
                'Lobi, uygulama üzerinden organize edilen etkinliklerden sorumlu değildir. Etkinliklere katılım kararı ve riskleri size aittir. Uygulama "olduğu gibi" sunulmaktadır.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '8. Hesap Sonlandırma',
            content:
                'Kullanım koşullarını ihlal eden hesaplar uyarı olmaksızın askıya alınabilir veya sonlandırılabilir. Hesabınızı istediğiniz zaman kapatabilirsiniz.',
          ),
          SizedBox(height: 20.h),
          _buildSection(
            context,
            title: '9. İletişim',
            content:
                'Kullanım koşulları hakkında sorularınız varsa, destek@lobiapp.com adresinden bizimle iletişime geçebilirsiniz.',
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
