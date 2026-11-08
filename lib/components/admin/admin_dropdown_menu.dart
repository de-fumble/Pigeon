import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_market_filter_menu.dart';

/// Inline variant of the admin filter menu, for screens that position it
/// themselves inside a [Stack].
class AdminDropdownMenu extends StatelessWidget {
  const AdminDropdownMenu({
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

  @override
  Widget build(BuildContext context) {
    return AdminMarketFilterMenu(
      items: items,
      selectedItem: selectedItem,
      onSelected: onSelected,
      width: width,
    );
  }
}
