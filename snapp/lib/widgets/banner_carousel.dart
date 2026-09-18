import 'dart:async';

import 'package:flutter/material.dart' hide Banner;

import '../data/banner_models.dart';
import '../theme/theme_extension.dart';
import '../utils/style_utils.dart';
import 'app_icon.dart';
import 'pressable.dart';

/// 首页 Banners 轮播（对照原型 `BannerCarousel.vue`）。
class BannerCarousel extends StatefulWidget {
  final List<Banner> banners;
  final void Function(Banner) onTapBanner;
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.onTapBanner,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _current = 0;

  bool get _reducedMotion =>
      MediaQuery.of(context).disableAnimations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeStartAuto();
  }

  @override
  void didUpdateWidget(BannerCarousel old) {
    super.didUpdateWidget(old);
    if (old.banners.length != widget.banners.length) {
      _current = 0;
      _controller.jumpToPage(0);
      _maybeStartAuto();
    }
  }

  void _maybeStartAuto() {
    _timer?.cancel();
    _timer = null;
    if (_reducedMotion) return;
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_current + 1) % widget.banners.length;
      _controller.animateToPage(next,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (int i) => setState(() => _current = i),
            itemBuilder: (_, int i) => _card(context, widget.banners[i]),
          ),
        ),
        if (widget.banners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(widget.banners.length, (int i) {
                final on = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: on ? 14 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: on ? c.primary : c.text3,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _card(BuildContext context, Banner b) {
    final c = Theme.of(context).appColors;
    final g = parseCssGradient(b.gradient);
    final colors = g?.colors ?? <Color>[c.primary, c.primaryStrong];
    final begin = g?.begin ?? Alignment.topLeft;
    final end = g?.end ?? Alignment.bottomRight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: PressableScale(
        onTap: () => widget.onTapBanner(b),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(begin: begin, end: end, colors: colors),
            boxShadow: c.shadow2,
          ),
          child: Row(children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.onCover.withOpacity(0.18),
              ),
              alignment: Alignment.center,
              child: AppIcon(name: b.icon, size: 22, color: c.onCover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(b.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: c.onCover,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3)),
                  if (b.subtitle != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(b.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: c.onCoverSoft, fontSize: 13)),
                  ],
                ],
              ),
            ),
            if (b.type == BannerType.featured)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.onCover.withOpacity(0.22),
                ),
                alignment: Alignment.center,
                child: AppIcon(name: 'play', size: 18, color: c.onCover),
              ),
          ]),
        ),
      ),
    );
  }
}