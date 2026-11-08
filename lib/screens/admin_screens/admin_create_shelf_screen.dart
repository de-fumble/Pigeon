import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/admin/admin_market_picker.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

class AdminCreateShelfScreen extends StatefulWidget {
  const AdminCreateShelfScreen({super.key});

  @override
  State<AdminCreateShelfScreen> createState() => _AdminCreateShelfScreenState();
}

class _AdminCreateShelfScreenState extends State<AdminCreateShelfScreen> {
  /// Empty slots shown until the shelf has this many markets.
  static const int _minSlots = 4;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _headingController = TextEditingController();
  late final Future<List<AdminMarket>> _markets = AdminService.instance
      .fetchMarkets();
  final List<AdminMarket> _selected = <AdminMarket>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onChanged);
    _headingController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _headingController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canCreate =>
      !_saving &&
      _titleController.text.trim().isNotEmpty &&
      _headingController.text.trim().isNotEmpty;

  /// Fills slot [index], or replaces the market already in it.
  Future<void> _pick(int index) async {
    final List<AdminMarket> markets;
    try {
      markets = await _markets;
    } catch (e) {
      if (mounted) AppToast.show(context, message: liveErrorMessage(e));
      return;
    }
    if (!mounted) return;
    final Set<String> taken = <String>{
      for (final AdminMarket m in _selected) m.id,
    };
    final List<String>? picked = await showAdminMarketPicker(
      context,
      markets: markets.where((AdminMarket m) => !taken.contains(m.id)).toList(),
      single: true,
      title: 'Select market',
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    final AdminMarket market = markets.firstWhere(
      (AdminMarket m) => m.id == picked.first,
    );
    setState(() {
      if (index < _selected.length) {
        _selected[index] = market;
      } else {
        _selected.add(market);
      }
    });
  }

  Future<void> _create() async {
    if (!_canCreate) return;
    setState(() => _saving = true);
    final String title = _titleController.text.trim();
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.createShelf(
        title: title,
        heading: _headingController.text.trim(),
        marketIds: <String>[for (final AdminMarket m in _selected) m.id],
      ),
      success: '$title created.',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int slots = _selected.length < _minSlots
        ? _minSlots
        : _selected.length + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: staggeredEntrance([
            Row(
              children: [
                Pressable(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Create Shelf',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 54),
            _BoldField(
              controller: _titleController,
              hint: 'Title',
              helper: 'Admin name, e.g. Trending',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: BoxDecoration(
                color: const Color(0xFF202020),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BoldField(
                    controller: _headingController,
                    hint: 'Heading',
                    helper: 'Shown to users, e.g. Nigerian Elections',
                  ),
                  const SizedBox(height: 18),
                  for (int index = 0; index < slots; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Pressable(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _pick(index),
                        child: _ShelfMarketSlot(
                          market: index < _selected.length
                              ? _selected[index]
                              : null,
                          onRemove: index < _selected.length
                              ? () => setState(() => _selected.removeAt(index))
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: FilledButton(
                onPressed: _canCreate ? _create : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  disabledBackgroundColor: AppColors.surfaceDisabled,
                  foregroundColor: AppColors.buttonText,
                  minimumSize: const Size(96, 46),
                  shape: const StadiumBorder(),
                ),
                child: Text(_saving ? 'Saving…' : 'Create'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Large bold text field matching the screen's "Title" / "Heading" labels.
class _BoldField extends StatelessWidget {
  const _BoldField({
    required this.controller,
    required this.hint,
    required this.helper,
  });

  final TextEditingController controller;
  final String hint;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          cursorColor: AppColors.accent,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: const TextStyle(color: Color(0xFF787878), fontSize: 13),
        ),
      ],
    );
  }
}

class _ShelfMarketSlot extends StatelessWidget {
  const _ShelfMarketSlot({this.market, this.onRemove});

  final AdminMarket? market;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              market?.title ?? 'Select Market',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: market == null ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (onRemove != null)
            Pressable(
              onTap: onRemove!,
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
