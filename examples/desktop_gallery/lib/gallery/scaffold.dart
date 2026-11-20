import 'package:flutter/widgets.dart';

/// Scrollable component page used by every Desktop Gallery demo.
class GalleryPage extends StatelessWidget {
  const GalleryPage({
    super.key,
    required this.title,
    required this.source,
    required this.children,
  });

  final String title;

  /// Path under tdesign-vue-next, for example `components/button`.
  final String source;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFFFFF),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF000000),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '示例来源：tdesign-vue-next/$source',
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 20),
          for (final child in children) ...[child, const SizedBox(height: 28)],
        ],
      ),
    );
  }
}

/// One Vue Next example block.
class DemoSection extends StatelessWidget {
  const DemoSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Click target for Dropdown / Popover. Keeps the gesture on the parent.
class DemoTrigger extends StatelessWidget {
  const DemoTrigger(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCDCDC)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

/// Neutral block used by Badge demos, matching the Vue Next badge block.
class DemoBlock extends StatelessWidget {
  const DemoBlock({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        border: Border.all(color: const Color(0xFFDCDCDC)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}
