import 'dart:async';

import 'package:flutter/widgets.dart';

import '../token/t_token_color.dart';

/// Paged content with dot indicators. Autoplay stays off unless [autoplay].
class TSwiper extends StatefulWidget {
  const TSwiper({
    super.key,
    required this.children,
    this.height = 160,
    this.autoplay = false,
  });

  final List<Widget> children;
  final double height;
  final bool autoplay;

  @override
  State<TSwiper> createState() => _TSwiperState();
}

class _TSwiperState extends State<TSwiper> {
  late final PageController _controller = PageController();
  Timer? _timer;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _syncAutoplay();
  }

  @override
  void didUpdateWidget(covariant TSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoplay != widget.autoplay) _syncAutoplay();
  }

  void _syncAutoplay() {
    _timer?.cancel();
    _timer = null;
    if (!widget.autoplay || widget.children.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.children.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
    final brand = tTokenColor(context, 'brandColor7');
    final idle = tTokenColor(context, 'componentBorder');
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => setState(() => _index = index),
            children: widget.children,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.children.length; i++)
                  GestureDetector(
                    onTap: () => _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    ),
                    child: Container(
                      key: ValueKey<String>('TSwiper.dot.$i'),
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index ? brand : idle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
