import 'package:flutter/material.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/utils/live_formatters.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';

class AdminCategoryData {
  const AdminCategoryData({
    required this.title,
    required this.color,
    this.id,
    this.emoji,
    this.iconAsset,
    this.iconSize = 18,
    this.fullBleedIcon = false,
  });

  /// A database category, drawn with the bundled artwork when one matches its
  /// name and with its emoji on its colour otherwise.
  factory AdminCategoryData.fromCategory(AdminCategory category) {
    for (final AdminCategoryData known in kAdminCategories) {
      if (known.title == category.name) {
        return AdminCategoryData(
          id: category.id,
          title: category.name,
          color: known.color,
          emoji: category.emoji,
          iconAsset: known.iconAsset,
          iconSize: known.iconSize,
          fullBleedIcon: known.fullBleedIcon,
        );
      }
    }
    return AdminCategoryData(
      id: category.id,
      title: category.name,
      color: LiveFormatters.color(
        category.color,
        fallback: const Color(0xFF6B7280),
      ),
      emoji: category.emoji,
    );
  }

  /// `categories.id`; null for the built-in list below.
  final String? id;
  final String title;

  /// Shown on the tile when there's no [iconAsset].
  final String? emoji;
  final Color color;

  /// Glyph drawn on top of [color]; null renders a plain tile.
  final String? iconAsset;
  final double iconSize;

  /// True when [iconAsset] already contains its own coloured tile.
  final bool fullBleedIcon;
}

const List<AdminCategoryData> kAdminCategories = <AdminCategoryData>[
  AdminCategoryData(
    title: 'Politics',
    color: Color(0xFFFFD300),
    iconAsset: AppIcons.tabPolitics,
  ),
  AdminCategoryData(
    title: 'Sports',
    color: Color(0xFF00C34E),
    iconAsset: AppIcons.tabSports,
    fullBleedIcon: true,
  ),
  AdminCategoryData(
    title: 'Culture',
    color: Color(0xFFFF3C63),
    iconAsset: AppIcons.tabCulture,
    iconSize: 24,
  ),
  AdminCategoryData(
    title: 'Tech & Science',
    color: Color(0xFF00FFFF),
    iconAsset: AppIcons.tabTech,
    iconSize: 20,
  ),
  AdminCategoryData(
    title: 'Economics',
    color: Color(0xFFFFFFFF),
    iconAsset: AppIcons.tabEconomics,
    iconSize: 24,
  ),
  AdminCategoryData(title: 'Socials', color: Color(0xFF6B7280)),
];

/// 30px rounded category tile used across the admin category screens.
class AdminCategoryBadge extends StatelessWidget {
  const AdminCategoryBadge({super.key, required this.category});

  final AdminCategoryData category;

  @override
  Widget build(BuildContext context) {
    final String? asset = category.iconAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 30,
        height: 30,
        color: category.color,
        alignment: Alignment.center,
        child: asset == null
            ? (category.emoji == null
                  ? null
                  : Text(category.emoji!, style: const TextStyle(fontSize: 16)))
            : Image.asset(
                asset,
                width: category.fullBleedIcon ? 30 : category.iconSize,
                height: category.fullBleedIcon ? 30 : category.iconSize,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
