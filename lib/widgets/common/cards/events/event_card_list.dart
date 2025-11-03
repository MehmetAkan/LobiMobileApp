import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// EventCardList - Yatay scroll olan kart listesi (Molecule seviyesi)
/// 
/// Kullanım alanları:
/// - EventsSection içinde
/// - Farklı kart tipleri için (EventCard, ProductCard, etc.)
/// 
/// Generic tasarım sayesinde farklı item tipleri ile kullanılabilir
class EventCardList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final double? height;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const EventCardList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.height = 265,
    this.spacing = 20,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: height?.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: physics ?? const BouncingScrollPhysics(),
        padding: padding ?? EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing.w),
        itemBuilder: (context, index) {
          return itemBuilder(items[index], index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      child: Center(
        child: Text(
          'Henüz etkinlik yok',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}