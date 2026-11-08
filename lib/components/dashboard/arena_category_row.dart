import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/dashboard/arena_pill_chip.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';

class ArenaCategoryRow extends StatefulWidget {
  const ArenaCategoryRow({
    super.key,
    this.initialIndex = 0,
    this.initialSlug,
    this.onSelected,
  });

  final int initialIndex;

  /// Preselects the category with this slug; overrides [initialIndex].
  final String? initialSlug;

  /// Called with the category slug in `categories.slug` (null for Home).
  final ValueChanged<String?>? onSelected;

  @override
  State<ArenaCategoryRow> createState() => _ArenaCategoryRowState();
}

class _ArenaCategoryRowState extends State<ArenaCategoryRow> {
  late int _selectedIndex = widget.initialSlug == null
      ? widget.initialIndex
      : _categories
            .indexWhere((_ArenaCategory c) => c.slug == widget.initialSlug)
            .clamp(0, _categories.length - 1);

  static const List<_ArenaCategory> _categories = <_ArenaCategory>[
    _ArenaCategory(
      label: 'Home',
      slug: null,
      svgAsset: AppIcons.homeHome,
      iconColor: Color(0xFF89D1FF),
    ),
    _ArenaCategory(
      label: 'Socials',
      slug: 'socials',
      svgAsset: AppIcons.homeSocials,
      iconColor: Color(0xFFFF7A00),
    ),
    _ArenaCategory(
      label: 'Sports',
      slug: 'sports',
      svgAsset: AppIcons.homeSports,
      iconColor: Color(0xFF19D36D),
    ),
    _ArenaCategory(
      label: 'Politics',
      slug: 'politics',
      svgAsset: AppIcons.homePolitics,
      iconColor: Color(0xFFFFD400),
    ),
    _ArenaCategory(
      label: 'Culture',
      slug: 'culture',
      svgAsset: AppIcons.homeCulture,
      iconColor: Color(0xFFFF3C63),
    ),
    _ArenaCategory(
      label: 'Tech',
      slug: 'tech-science',
      svgAsset: AppIcons.homeTech,
      iconColor: Color(0xFF00C0C0),
    ),
    _ArenaCategory(
      label: 'Economics',
      slug: 'economics',
      svgAsset: AppIcons.homeEconomics,
      iconColor: Color(0xFFFA4E00),
    ),
  ];

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    widget.onSelected?.call(_categories[index].slug);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < _categories.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 12),
            Pressable(
              behavior: HitTestBehavior.opaque,
              onTap: () => _select(i),
              child: ArenaPillChip(
                label: _categories[i].label,
                icon: _categories[i].icon,
                svgAsset: _categories[i].svgAsset,
                iconColor: _categories[i].iconColor,
                selected: i == _selectedIndex,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArenaCategory {
  const _ArenaCategory({
    required this.label,
    required this.slug,
    required this.iconColor,
    this.icon,
    this.svgAsset,
  }) : assert(icon != null || svgAsset != null, 'icon or svgAsset required');

  final String label;
  final String? slug;
  final IconData? icon;
  final String? svgAsset;
  final Color iconColor;
}
