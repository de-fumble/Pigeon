import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/wallet_action_buttons.dart';
import 'package:pigeon/components/dashboard/wallet_position_tile.dart';
import 'package:pigeon/components/dashboard/wallet_summary_card.dart';
import 'package:pigeon/components/dashboard/wallet_top_bar.dart';
import 'package:pigeon/components/dashboard/withdraw_destination_sheet.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            DataSourceBuilder(
              live: (BuildContext context) => const _LiveWallet(),
              stock: (BuildContext context) => ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
                children: staggeredEntrance([
                  WalletTopBar(
                    title: 'Wallet',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 82,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const WalletSummaryCard(
                          width: 286,
                          label: 'Cash Balance',
                          amount: '₦301',
                          avatar: '👤',
                        ),
                        const SizedBox(width: 12),
                        const WalletSummaryCard(
                          width: 286,
                          label: 'Holdings',
                          amount: '₦301',
                          avatar: '👤',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Predictions',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  WalletPositionTile(
                    avatar: '👨🏾',
                    avatarColor: const Color(0xFFD9D9D9),
                    title: 'Yes',
                    subtitle: 'Will Davido drop an al...',
                    amount: 'N301',
                    delta: '+N11.2',
                    iconAsset: 'assets/icons/marketscreen/davido.png',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRouter.marketPosition,
                      arguments: {
                        'title': 'Will Davido drop an album in 2026?',
                        'position': 'Yes',
                        'avatar': '👨🏾',
                        'avatarColor': const Color(0xFFD9D9D9),
                        'chance': '52%',
                        'cost': 'N100',
                        'value': 'N301',
                        'change': '+N11.2',
                        'payout': 'N1000',
                        'changeColor': const Color(0xFF1FD36B),
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  WalletPositionTile(
                    avatar: '👤',
                    avatarColor: const Color(0xFFB0B0B0),
                    title: 'Peter Obi',
                    subtitle: 'Who will be the next Ni...',
                    amount: 'N134',
                    delta: '-N34.7',
                    iconAsset: 'assets/icons/marketscreen/president.png',
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRouter.marketPosition,
                      arguments: {
                        'title': 'Who will be the next Nigerian President?',
                        'position': 'Peter Obi',
                        'avatar': '👤',
                        'avatarColor': const Color(0xFFB0B0B0),
                        'chance': '34%',
                        'cost': 'N211',
                        'value': 'N134',
                        'change': '-N34.7',
                        'payout': 'N1000',
                        'changeColor': const Color(0xFFFF2D55),
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
                child: WalletActionButtons(
                  onWithdraw: () => showWithdrawDestinationSheet(context),
                  onDeposit: () =>
                      Navigator.of(context).pushNamed(AppRouter.deposit),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveWalletData {
  const _LiveWalletData(this.wallet, this.positions);

  final LiveWallet wallet;
  final List<LivePosition> positions;
}

/// Live balance, holdings and positions from the `my_wallet` and
/// `my_positions` views.
class _LiveWallet extends StatefulWidget {
  const _LiveWallet();

  @override
  State<_LiveWallet> createState() => _LiveWalletState();
}

class _LiveWalletState extends State<_LiveWallet> {
  final GlobalKey<LiveLoaderState<_LiveWalletData>> _loader =
      GlobalKey<LiveLoaderState<_LiveWalletData>>();

  Future<_LiveWalletData> _load() async {
    final List<Object> r = await Future.wait(<Future<Object>>[
      LiveDataService.fetchWallet(),
      LiveDataService.fetchPositions(),
    ]);
    return _LiveWalletData(r[0] as LiveWallet, r[1] as List<LivePosition>);
  }

  Future<void> _openPosition(LivePosition p) async {
    await Navigator.of(context).pushNamed(
      AppRouter.marketPosition,
      arguments: <String, dynamic>{
        'title': p.marketTitle,
        'position': p.outcomeLabel,
        'avatar': p.outcomeEmoji ?? LiveFormatters.initials(p.outcomeLabel),
        'avatarColor': LiveFormatters.color(
          p.outcomeColor,
          fallback: const Color(0xFFD9D9D9),
        ),
        'chance': LiveFormatters.percent(p.chance),
        'cost': LiveFormatters.naira(p.costBasisKobo),
        'value': LiveFormatters.naira(p.valueKobo),
        'change': LiveFormatters.nairaDelta(p.changeKobo),
        'payout': LiveFormatters.naira(p.payoutIfRightKobo),
        'changeColor': p.changeKobo < 0
            ? const Color(0xFFFF2D55)
            : const Color(0xFF1FD36B),
        'marketId': p.marketId,
        'outcomeId': p.outcomeId,
        'shares': p.shares,
        'pricePerShare': LiveFormatters.pricePerShareNaira(p.chance),
        'tradable': p.isOpen && kTradableStatuses.contains(p.marketStatus),
      },
    );
    // Balances may have changed after a buy or cash out.
    _loader.currentState?.reload();
  }

  Widget _tile(LivePosition p) {
    final bool settled = p.settledAt != null;
    return WalletPositionTile(
      avatar: p.outcomeEmoji ?? '👤',
      avatarColor: LiveFormatters.color(
        p.outcomeColor,
        fallback: const Color(0xFFD9D9D9),
      ),
      iconUrl: p.outcomeImageUrl ?? p.marketImageUrl,
      title: p.outcomeLabel,
      subtitle: p.marketTitle,
      amount: settled
          ? LiveFormatters.naira(p.payoutKobo ?? 0)
          : LiveFormatters.naira(p.valueKobo),
      delta: LiveFormatters.nairaDelta(
        settled ? p.realizedPnlKobo : p.changeKobo,
      ),
      onTap: settled ? null : () => _openPosition(p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget topBar = WalletTopBar(
      title: 'Wallet',
      onBack: () => Navigator.of(context).pop(),
    );
    if (LiveDataService.currentUserId == null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
        children: <Widget>[
          topBar,
          const LiveSignInPrompt(message: 'Log in to see your wallet.'),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _loader.currentState?.reload(),
      color: AppColors.accent,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
        children: <Widget>[
          topBar,
          const SizedBox(height: 28),
          LiveLoader<_LiveWalletData>(
            key: _loader,
            load: _load,
            placeholder: const LiveSkeleton(cards: 1, rows: 3),
            builder: (BuildContext context, _LiveWalletData data, _) {
              final List<LivePosition> open = data.positions
                  .where((LivePosition p) => p.settledAt == null)
                  .toList();
              final List<LivePosition> settled = data.positions
                  .where((LivePosition p) => p.settledAt != null)
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: staggeredEntrance(<Widget>[
                  SizedBox(
                    height: 82,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: <Widget>[
                        WalletSummaryCard(
                          width: 286,
                          label: 'Cash Balance',
                          amount: LiveFormatters.naira(
                            data.wallet.cashBalanceKobo,
                          ),
                          avatar: '👤',
                        ),
                        const SizedBox(width: 12),
                        WalletSummaryCard(
                          width: 286,
                          label: 'Holdings',
                          amount: LiveFormatters.naira(
                            data.wallet.holdingsKobo,
                          ),
                          avatar: '👤',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Predictions', style: _headingStyle),
                  const SizedBox(height: 14),
                  if (open.isEmpty)
                    const LiveEmptyState(
                      icon: Icons.query_stats_rounded,
                      message: "You haven't made any predictions yet.",
                    ),
                  for (final LivePosition p in open) ...<Widget>[
                    _tile(p),
                    const SizedBox(height: 14),
                  ],
                  if (settled.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 10),
                    const Text('Settled', style: _headingStyle),
                    const SizedBox(height: 14),
                    for (final LivePosition p in settled) ...<Widget>[
                      _tile(p),
                      const SizedBox(height: 14),
                    ],
                  ],
                  const SizedBox(height: 6),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  static const TextStyle _headingStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
}
