import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';

class MarketsTabChipRow extends StatefulWidget {
  const MarketsTabChipRow({
    super.key,
    required this.labels,
    this.initialIndex = 0,
    this.onSelected,
    this.iconBuilder,
    this.iconAssets,
    this.iconBgColor,
    this.usePills = true,
  });

  final List<String> labels;
  final int initialIndex;
  final ValueChanged<int>? onSelected;
  final IconData Function(String label)? iconBuilder;
  final Map<String, String>? iconAssets;
  final Color? iconBgColor;
  final bool usePills;

  @override
  State<MarketsTabChipRow> createState() => _MarketsTabChipRowState();
}

class _MarketsTabChipRowState extends State<MarketsTabChipRow> {
  late int _selectedIndex = widget.initialIndex;

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    widget.onSelected?.call(index);
  }

  Widget _buildChip(int i) {
    final bool selected = i == _selectedIndex;
    final String? asset = widget.iconAssets?[widget.labels[i]];

    if (!widget.usePills) {
      return _TextChip(
        label: widget.labels[i],
        selected: selected,
        onTap: () => _select(i),
      );
    }

    if (asset != null) {
      return _SportsPillChip(
        label: widget.labels[i],
        asset: asset,
        selected: selected,
        onTap: () => _select(i),
      );
    }

    if (widget.iconBuilder != null) {
      return _SportsPillChip(
        label: widget.labels[i],
        icon: widget.iconBuilder!(widget.labels[i]),
        selected: selected,
        onTap: () => _select(i),
      );
    }

    return _SportsPillChip(
      label: widget.labels[i],
      selected: selected,
      onTap: () => _select(i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < widget.labels.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 12),
            Pressable(
              behavior: HitTestBehavior.opaque,
              onTap: () => _select(i),
              child: _buildChip(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _TextChip extends StatelessWidget {
  const _TextChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SportsPillChip extends StatelessWidget {
  const _SportsPillChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.asset,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? asset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color bg = selected
        ? const Color(0xFFD4D4D4)
        : AppColors.backgroundSecondary;
    final Color textColor = selected
        ? AppColors.buttonText
        : AppColors.textMuted;

    final Widget? iconWidget = asset != null
        ? Center(
            child: Image.asset(
              asset!,
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          )
        : (icon != null ? Icon(icon, size: 18, color: textColor) : null);

    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (iconWidget != null) ...<Widget>[
              iconWidget,
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
