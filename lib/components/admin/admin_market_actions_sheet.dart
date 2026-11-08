import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

/// Status, visibility and resolution actions for one market. Returns true
/// when the market was changed, so the caller can reload.
Future<bool> showAdminMarketActions(
  BuildContext context,
  AdminMarket market,
) async {
  final String? action = await showModalBottomSheet<String>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.backgroundSecondary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (BuildContext context) => _MarketActionsSheet(market: market),
  );
  if (action == null || !context.mounted) return false;

  if (action == 'hide' || action == 'unhide') {
    return runWithToast(
      context,
      () => AdminService.instance.setMarketHidden(market.id, action == 'hide'),
      success: action == 'hide' ? 'Market hidden.' : 'Market visible again.',
    );
  }
  if (action == 'resolve') return _resolve(context, market);
  if (action == 'settle') {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Settle now?',
      message:
          'Winning positions are paid out immediately instead of after the '
          'settlement window. This cannot be undone.',
      confirmLabel: 'Settle',
    );
    if (!confirmed || !context.mounted) return false;
    return runWithToast(
      context,
      () => AdminService.instance.settleMarket(market.id),
      success: 'Market settled. Winners have been paid.',
    );
  }
  if (action == 'void') {
    final String? reason = await showTextInputDialog(
      context,
      title: 'Void market',
      hint: 'Reason shown to traders',
      confirmLabel: 'Void',
    );
    if (reason == null || !context.mounted) return false;
    return runWithToast(
      context,
      () => AdminService.instance.voidMarket(market.id, reason),
      success: 'Market voided. Stakes have been refunded.',
    );
  }

  // Anything else is a status.
  return runWithToast(
    context,
    () => AdminService.instance.setMarketStatus(market.id, action),
    success: 'Status set to ${kAdminMarketStatusLabels[action] ?? action}.',
  );
}

Future<bool> _resolve(BuildContext context, AdminMarket market) async {
  final AdminOutcome? winner = await showDialog<AdminOutcome>(
    context: context,
    builder: (BuildContext context) => SimpleDialog(
      backgroundColor: AppColors.backgroundSecondary,
      title: const Text(
        'Pick the winning option',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      children: <Widget>[
        for (final AdminOutcome o in market.outcomes)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(o),
            child: Text(
              '${o.emoji == null ? '' : '${o.emoji}  '}${o.label}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
      ],
    ),
  );
  if (winner == null || !context.mounted) return false;
  return runWithToast(
    context,
    () => AdminService.instance.resolveMarket(market.id, winner.id),
    success:
        '${winner.label} wins. Payouts follow after the settlement window.',
  );
}

class _MarketActionsSheet extends StatelessWidget {
  const _MarketActionsSheet({required this.market});

  final AdminMarket market;

  @override
  Widget build(BuildContext context) {
    final String status = market.status;
    final bool isFinal = kAdminFinalStatuses.contains(status);
    final bool isResolved = status == 'resolved';

    Widget item(String value, String label, IconData icon, {Color? color}) {
      return ListTile(
        leading: Icon(icon, color: color ?? AppColors.textMuted, size: 22),
        title: Text(
          label,
          style: TextStyle(color: color ?? AppColors.textPrimary, fontSize: 16),
        ),
        trailing: value == status
            ? const Icon(
                Icons.check_rounded,
                color: AppColors.textPrimary,
                size: 20,
              )
            : null,
        onTap: value == status ? null : () => Navigator.of(context).pop(value),
      );
    }

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                market.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${kAdminMarketStatusLabels[status] ?? status}'
                '${market.isHidden ? ' · Hidden' : ''}',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
            if (!isFinal && !isResolved) ...<Widget>[
              const _SheetLabel('Status'),
              for (final String s in kAdminSettableStatuses)
                item(
                  s,
                  kAdminMarketStatusLabels[s]!,
                  s == 'closed'
                      ? Icons.flag_outlined
                      : Icons.radio_button_unchecked_rounded,
                ),
            ],
            const _SheetLabel('Visibility'),
            market.isHidden
                ? item('unhide', 'Show to users', Icons.visibility_outlined)
                : item(
                    'hide',
                    'Hide from users',
                    Icons.visibility_off_outlined,
                  ),
            if (!isFinal &&
                status != 'draft' &&
                market.outcomes.isNotEmpty) ...<Widget>[
              const _SheetLabel('Outcome'),
              item(
                'resolve',
                isResolved ? 'Change winner' : 'Resolve',
                Icons.emoji_events_outlined,
              ),
              if (isResolved)
                item('settle', 'Settle now', Icons.payments_outlined),
            ],
            if (!isFinal)
              item(
                'void',
                'Void and refund',
                Icons.block_rounded,
                color: const Color(0xFFFF4F4F),
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
