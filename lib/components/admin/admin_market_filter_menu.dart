import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminMarketFilterMenu extends StatelessWidget {
  const AdminMarketFilterMenu({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    this.width = 232,
  });

  final List<String> items;
  final String selectedItem;
  final ValueChanged<String> onSelected;
  final double width;

  /// Opens the menu 10px below [context]'s widget, right-aligned to it
  /// (or left-aligned when [alignStart] is true).
  static Future<void> show(
    BuildContext context, {
    required List<String> items,
    required String selectedItem,
    required ValueChanged<String> onSelected,
    bool alignStart = false,
    double width = 232,
  }) async {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss filter menu',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (BuildContext dialogContext, _, _) {
        return Stack(
          children: [
            Positioned(
              top: offset.dy + size.height + 10,
              left: alignStart ? offset.dx : null,
              right: alignStart ? null : screenWidth - offset.dx - size.width,
              child: AdminMarketFilterMenu(
                items: items,
                selectedItem: selectedItem,
                width: width,
                onSelected: (String item) {
                  Navigator.of(dialogContext).pop();
                  onSelected(item);
                },
              ),
            ),
          ],
        );
      },
      transitionBuilder: (_, Animation<double> animation, _, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF202221),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.background,
                ),
              _MenuItemRow(
                label: items[i],
                selected: items[i] == selectedItem,
                onTap: () => onSelected(items[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE6E6E6),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  CupertinoIcons.checkmark_alt_circle,
                  color: Color(0xFFE6E6E6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
