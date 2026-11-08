import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_market_list_tile.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/utils/live_formatters.dart';
import 'package:pigeon/constants/app_colors.dart';

class AdminShelfBlock extends StatelessWidget {
  const AdminShelfBlock({super.key, required this.card});

  final AdminShelf card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.heading,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          if (card.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'No markets on this shelf yet.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          for (final AdminShelfItem item in card.items)
            AdminMarketListTile(
              leading: LiveThumb(
                url: item.imageUrl,
                fallback: LiveFormatters.initials(item.label),
                size: 50,
                backgroundColor: const Color(0xFFC4C4C4),
              ),
              trailing: const _OpenMarketButton(),
              child: Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OpenMarketButton extends StatelessWidget {
  const _OpenMarketButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF313035),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.north_east_rounded,
        color: AppColors.textPrimary,
        size: 16,
      ),
    );
  }
}
