import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pigeon/components/admin/admin_category_badge.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

class AdminCategoryDetailScreen extends StatefulWidget {
  const AdminCategoryDetailScreen({super.key, required this.category});

  final AdminCategoryData category;

  @override
  State<AdminCategoryDetailScreen> createState() =>
      _AdminCategoryDetailScreenState();
}

typedef _DetailData = ({AdminCategory? self, List<AdminCategory> children});

class _AdminCategoryDetailScreenState extends State<AdminCategoryDetailScreen> {
  /// Bundled icons for the seeded sports subcategories; others use their emoji.
  static const Map<String, Widget> _knownIcons = <String, Widget>{
    'Football': FaIcon(
      FontAwesomeIcons.solidFutbol,
      color: Color(0xFF00C34E),
      size: 22,
    ),
    'Basketball': AppSvgIcon(asset: AppIcons.basketball, size: 24),
    'Tennis': AppSvgIcon(asset: AppIcons.tennis, size: 24),
    'Boxing': AppSvgIcon(asset: AppIcons.boxing, size: 24),
    'Wrestling': AppSvgIcon(asset: AppIcons.wrestling, size: 24),
  };

  final GlobalKey<LiveLoaderState<_DetailData>> _loaderKey =
      GlobalKey<LiveLoaderState<_DetailData>>();

  String? get _id => widget.category.id;

  Future<_DetailData> _load() async {
    final List<AdminCategory> all = await AdminService.instance
        .fetchCategories();
    return (
      self: all.where((AdminCategory c) => c.id == _id).firstOrNull,
      children: all.where((AdminCategory c) => c.parentId == _id).toList(),
    );
  }

  Future<void> _reload() async => _loaderKey.currentState?.reload();

  Future<void> _addSubcategory(int count) async {
    final String? name = await showTextInputDialog(
      context,
      title: 'New sub category',
      hint: 'Name',
      confirmLabel: 'Add',
    );
    if (name == null || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.createCategory(
        name: name,
        parentId: _id,
        sortOrder: count + 1,
      ),
    );
    if (ok) await _reload();
  }

  Future<void> _rename(AdminCategory sub) async {
    final String? name = await showTextInputDialog(
      context,
      title: 'Rename',
      initial: sub.name,
    );
    if (name == null || name == sub.name || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.renameCategory(sub.id, name),
    );
    if (ok) await _reload();
  }

  Future<void> _deleteSubcategory(AdminCategory sub) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${sub.name}?',
      message: 'Only categories without markets can be deleted.',
    );
    if (!confirmed || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.deleteCategory(sub.id),
      success: '${sub.name} deleted.',
    );
    if (ok) await _reload();
  }

  Future<void> _deleteCategory() async {
    final String? id = _id;
    if (id == null) return;
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${widget.category.title}?',
      message:
          'Its sub categories are deleted too. Categories that still have '
          'markets can only be hidden.',
    );
    if (!confirmed || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.deleteCategory(id),
      success: '${widget.category.title} deleted.',
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _toggleActive(AdminCategory self) async {
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.setCategoryActive(self.id, !self.isActive),
      success: self.isActive
          ? '${self.name} is hidden from users.'
          : '${self.name} is visible again.',
    );
    if (ok) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LiveLoader<_DetailData>(
          key: _loaderKey,
          load: _load,
          builder:
              (
                BuildContext context,
                _DetailData data,
                Future<void> Function() reload,
              ) {
                final AdminCategory? self = data.self;
                final List<AdminCategory> rows = data.children;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AdminPageHeader(
                      title: widget.category.title,
                      titleLeading: AdminCategoryBadge(
                        category: widget.category,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (self != null)
                            Pressable(
                              onTap: () => _toggleActive(self),
                              child: Icon(
                                self.isActive
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textPrimary,
                                size: 22,
                              ),
                            ),
                          const SizedBox(width: 16),
                          Pressable(
                            onTap: _deleteCategory,
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFFF1111),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        children: staggeredEntrance([
                          const Text(
                            'Sub categories',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final AdminCategory sub in rows)
                            _EditableSubCategoryRow(
                              label: sub.name,
                              icon:
                                  _knownIcons[sub.name] ??
                                  Text(
                                    sub.emoji ?? '•',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                              onEdit: () => _rename(sub),
                              onDelete: () => _deleteSubcategory(sub),
                            ),
                          SizedBox(height: rows.isEmpty ? 0 : 10),
                          Pressable(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _addSubcategory(rows.length),
                            child: _OptionField(
                              label: rows.isEmpty
                                  ? 'Add sub category'
                                  : 'Add other option',
                              dashed: true,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}

class _EditableSubCategoryRow extends StatelessWidget {
  const _EditableSubCategoryRow({
    required this.label,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
  });

  final String label;
  final Widget icon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: Center(child: icon)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          ),
          Pressable(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Pressable(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textPrimary,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}

/// 58px option field: solid outline for an existing entry, dashed for "add".
class _OptionField extends StatelessWidget {
  const _OptionField({required this.label, this.dashed = false});

  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final Widget content = SizedBox(
      height: 58,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: dashed ? const Color(0xFF353535) : const Color(0xFFC4C4C4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    if (!dashed) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF606060), width: 1),
        ),
        child: content,
      );
    }

    return CustomPaint(
      painter: _DashedRoundedBorderPainter(
        radius: 14,
        color: const Color(0xFF606060),
        strokeWidth: 1,
        dashLength: 6,
        gapLength: 4,
      ),
      child: content,
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  _DashedRoundedBorderPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);

    final Path dashed = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashLength).clamp(0.0, metric.length);
        dashed.addPath(metric.extractPath(distance, end), Offset.zero);
        distance = end + gapLength;
      }
    }

    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashLength != dashLength ||
        old.gapLength != gapLength ||
        old.radius != radius;
  }
}
