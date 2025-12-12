import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';

class StandardPage extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final IconData? actionIcon;
  final Color? actionIconBackgroundColor;
  final VoidCallback? onActionTap;
  final bool isScrollable;

  const StandardPage({
    super.key,
    required this.title,
    required this.children,
    this.actionIcon,
    this.actionIconBackgroundColor,
    this.onActionTap,
    this.isScrollable = true,
  });

  @override
  State<StandardPage> createState() => _StandardPageState();
}

class _StandardPageState extends State<StandardPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: 120.h, // AppBar altı boşluk
              left: 15.w,
              right: 15.w,
              bottom: 90.h,
            ),
            physics: widget.isScrollable
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [...widget.children],
          ),
          FullPageAppBar(
            title: widget.title,
            scrollController: _scrollController,
            actionIcon: widget.actionIcon,
            actionIconBackgroundColor: widget.actionIconBackgroundColor,
            onActionTap: widget.onActionTap,
            style: AppBarStyle.secondary,
          ),
        ],
      ),
    );
  }
}
