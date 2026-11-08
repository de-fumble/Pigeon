import 'package:flutter/material.dart';

class NotificationActionSheet extends StatelessWidget {
  const NotificationActionSheet({
    super.key,
    this.onShareTap,
    this.onViewMarketTap,
  });

  final VoidCallback? onShareTap;
  final VoidCallback? onViewMarketTap;

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onShareTap,
    VoidCallback? onViewMarketTap,
  }) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Future<void>.value();
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    const double menuWidth = 200;
    const double gap = 6;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder:
          (
            BuildContext ctx,
            Animation<double> anim,
            Animation<double> secondaryAnim,
          ) {
            return SizedBox.expand(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: offset.dy + size.height + gap,
                    left: offset.dx + size.width - menuWidth,
                    width: menuWidth,
                    child: Material(
                      color: const Color(0xFF181818),
                      elevation: 8,
                      borderRadius: BorderRadius.circular(18),
                      child: NotificationActionSheet(
                        onShareTap: onShareTap,
                        onViewMarketTap: onViewMarketTap,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Tile(
          label: 'Share',
          icon: Icons.open_in_new,
          onTap: () {
            Navigator.of(context).pop();
            final VoidCallback? cb = onShareTap;
            if (cb != null) cb();
          },
        ),
        const Divider(height: 1, color: Colors.white12),
        _Tile(
          label: 'View Market',
          icon: Icons.storefront_outlined,
          onTap: () {
            Navigator.of(context).pop();
            final VoidCallback? cb = onViewMarketTap;
            if (cb != null) cb();
          },
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(icon, color: Colors.white70, size: 22),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}
