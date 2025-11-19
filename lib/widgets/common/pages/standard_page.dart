import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lobi_application/theme/app_theme.dart';
import 'package:lobi_application/widgets/common/navbar/full_page_app_bar.dart';

class StandardPage extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final List<Widget>? actions;
  final bool isScrollable;

  const StandardPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
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
      backgroundColor: AppTheme.backgroundLight,
      body: Stack(
        children: [
          // İçerik
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: 120.h, // AppBar altı boşluk
              left: 20.w,
              right: 20.w,
              bottom: 40.h,
            ),
            physics: widget.isScrollable
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            children: [...widget.children],
          ),

          // AppBar
          FullPageAppBar(
            title: widget.title,
            scrollController: _scrollController,
            actions: widget.actions,
            style: AppBarStyle.secondary,
          ),
        ],
      ),
    );
  }
}
