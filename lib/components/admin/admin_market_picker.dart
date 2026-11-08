import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_market_list_tile.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/models/admin_models.dart';

/// Bottom sheet for choosing markets. Returns the chosen ids in the order
/// they were picked, or null when dismissed. With [single] it returns as soon
/// as one market is tapped.
Future<List<String>?> showAdminMarketPicker(
  BuildContext context, {
  required List<AdminMarket> markets,
  List<String> selected = const <String>[],
  bool single = false,
  String title = 'Select markets',
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.backgroundSecondary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext context) => _MarketPicker(
      markets: markets,
      initial: selected,
      single: single,
      title: title,
    ),
  );
}

class _MarketPicker extends StatefulWidget {
  const _MarketPicker({
    required this.markets,
    required this.initial,
    required this.single,
    required this.title,
  });

  final List<AdminMarket> markets;
  final List<String> initial;
  final bool single;
  final String title;

  @override
  State<_MarketPicker> createState() => _MarketPickerState();
}

class _MarketPickerState extends State<_MarketPicker> {
  late final List<String> _selected = <String>[...widget.initial];

  void _toggle(String id) {
    if (widget.single) {
      Navigator.of(context).pop(<String>[id]);
      return;
    }
    setState(() {
      if (!_selected.remove(id)) _selected.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!widget.single)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      child: Text(
                        _selected.isEmpty
                            ? 'Done'
                            : 'Done (${_selected.length})',
                        style: const TextStyle(color: AppColors.accent),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: widget.markets.isEmpty
                  ? const LiveEmptyState(
                      message: 'No markets to choose from yet.',
                      icon: Icons.storefront_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: widget.markets.length,
                      itemBuilder: (BuildContext context, int i) {
                        final AdminMarket m = widget.markets[i];
                        return AdminMarketRow(
                          market: m,
                          showDivider: i < widget.markets.length - 1,
                          onTap: () => _toggle(m.id),
                          trailing: widget.single
                              ? null
                              : AdminSelectCircle(
                                  selected: _selected.contains(m.id),
                                ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hollow circle with a filled dot when [selected].
class AdminSelectCircle extends StatelessWidget {
  const AdminSelectCircle({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFC4C4C4), width: 1.5),
      ),
      child: selected
          ? const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
