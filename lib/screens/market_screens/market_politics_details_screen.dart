import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/market_action_menu.dart';
import 'package:pigeon/components/dashboard/market_option_tile.dart';
import 'package:pigeon/components/dashboard/market_summary_card.dart';
import 'package:pigeon/components/dashboard/market_top_bar.dart';
import 'package:pigeon/components/market_cards/market_detail_sheets.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/router/app_router.dart';

class MarketPoliticsDetailsScreen extends StatefulWidget {
  const MarketPoliticsDetailsScreen({super.key});

  @override
  State<MarketPoliticsDetailsScreen> createState() =>
      _MarketPoliticsDetailsScreenState();
}

class _MarketPoliticsDetailsScreenState
    extends State<MarketPoliticsDetailsScreen> {
  bool _showMenu = false;

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  void _hideMenu() {
    if (_showMenu) {
      setState(() {
        _showMenu = false;
      });
    }
  }

  static int _parsePrice(String? raw) {
    if (raw == null) return 0;
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  static String _initialsFor(String name) {
    final List<String> parts = name
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  void _openTrade({
    required BuildContext context,
    required String candidateName,
    required Color candidateColor,
    required int pricePerShare,
  }) {
    Navigator.of(context).pushNamed(
      AppRouter.marketTradeInput,
      arguments: <String, dynamic>{
        'candidateName': candidateName,
        'candidateInitials': _initialsFor(candidateName),
        'candidateColor': candidateColor,
        'pricePerShare': pricePerShare,
        'walletBalance': 59674,
        'optionCount': 4,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Pressable(
          onTap: _hideMenu,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                children: staggeredEntrance([
                  MarketTopBar(
                    title: 'Politics - Election',
                    onBack: () => Navigator.of(context).pop(),
                    onMore: _toggleMenu,
                    onShare: () {},
                  ),
                  const SizedBox(height: 16),
                  const MarketSummaryCard(
                    question: 'Who will be the next\nNigerian President?',
                    position: 'Peter Obi',
                    avatarAsset: AppIcons.candPeterObi,
                    avatarColor: Color(0xFFD9D9D9),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFF2DA6FF),
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Bola Ahmed Tinubu 55%',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFFAA8CFF),
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Peter Obi 28%',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFFFFD74A),
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Atiku Abubakar 13%',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Color(0xFFFF5F42),
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'El Rufai 5%',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const Row(
                    children: [
                      Text(
                        'NOW',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 18),
                      Text(
                        '1D',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 210),
                  const Row(
                    children: [
                      Text(
                        'N769,642,414 Vol.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '↑N378.9874',
                        style: TextStyle(
                          color: Color(0xFF1FD36B),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Options',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  MarketOptionTile(
                    avatarAsset: AppIcons.candBolaTinubu,
                    avatarColor: const Color(0xFFD9D9D9),
                    label: 'Bola Ahmed Tinubu',
                    percentage: '55%',
                    price: 'N59',
                    onTap: () => _openTrade(
                      context: context,
                      candidateName: 'Bola Ahmed Tinubu',
                      candidateColor: const Color(0xFFD9D9D9),
                      pricePerShare: _parsePrice('N59'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  MarketOptionTile(
                    avatarAsset: AppIcons.candPeterObi,
                    avatarColor: const Color(0xFFD9D9D9),
                    label: 'Peter Obi',
                    percentage: '28%',
                    price: 'N41',
                    onTap: () => _openTrade(
                      context: context,
                      candidateName: 'Peter Obi',
                      candidateColor: const Color(0xFFD9D9D9),
                      pricePerShare: _parsePrice('N41'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  MarketOptionTile(
                    avatarAsset: AppIcons.candAtiku,
                    avatarColor: const Color(0xFFD9D9D9),
                    label: 'Atiku Abubakar',
                    percentage: '13%',
                    price: 'N26',
                    onTap: () => _openTrade(
                      context: context,
                      candidateName: 'Atiku Abubakar',
                      candidateColor: const Color(0xFFD9D9D9),
                      pricePerShare: _parsePrice('N26'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  MarketOptionTile(
                    avatarAsset: AppIcons.candElRufai,
                    avatarColor: const Color(0xFFD9D9D9),
                    label: 'El Rufai',
                    percentage: '5%',
                    price: 'N11',
                    onTap: () => _openTrade(
                      context: context,
                      candidateName: 'El Rufai',
                      candidateColor: const Color(0xFFD9D9D9),
                      pricePerShare: _parsePrice('N11'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Details',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _DetailsCard(),
                  const SizedBox(height: 28),
                  const Text(
                    'More Markets',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _MoreMarketsList(),
                  const SizedBox(height: 24),
                  const _JoinDiscussionBar(),
                ]),
              ),
              if (_showMenu)
                Positioned(
                  right: 14,
                  top: 60,
                  child: MarketActionMenu(
                    onDetailsTap: () {
                      _hideMenu();
                      Navigator.of(context).pushNamed(
                        AppRouter.marketInfo,
                        arguments: <String, dynamic>{
                          'question':
                              'Who will be the next Nigerian\nPresident?',
                          'thumbnail': AppIcons.candPeterObi,
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: <Widget>[
          _DetailsRow(
            label: 'Resolution',
            showDivider: true,
            onTap: () => ResolutionSheet.show(context),
          ),
          _DetailsRow(
            label: 'Settlement',
            showDivider: true,
            onTap: () => SettlementSheet.show(context),
          ),
          _DetailsRow(
            label: 'Wage terms',
            onTap: () => WageTermsSheet.show(context),
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({
    required this.label,
    this.showDivider = false,
    this.onTap,
  });
  final String label;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFF2A2A2A)),
      ],
    );
  }
}

class _MoreMarketsList extends StatelessWidget {
  const _MoreMarketsList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const <Widget>[
        _MoreMarketTile(
          thumbnailAsset: AppIcons.neNextLagosState,
          title: 'Next Lagos state\nGovernor?',
        ),
        _MoreMarketDivider(),
        _MoreMarketTile(
          thumbnailAsset: AppIcons.neAtikuStepDown,
          title: 'Will Atiku step down from the\n2027 Presidential race?',
        ),
        _MoreMarketDivider(),
        _MoreMarketTile(
          thumbnailAsset: AppIcons.fanbaseBurnaBoy,
          title: 'Will Burna Boy outsell\nhis last album?',
        ),
      ],
    );
  }
}

class _MoreMarketTile extends StatelessWidget {
  const _MoreMarketTile({required this.thumbnailAsset, required this.title});
  final String thumbnailAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFFD9D9D9),
                BlendMode.multiply,
              ),
              child: Image.asset(
                thumbnailAsset,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreMarketDivider extends StatelessWidget {
  const _MoreMarketDivider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFF2A2A2A));
  }
}

class _JoinDiscussionBar extends StatelessWidget {
  const _JoinDiscussionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFF1C2D),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const AppSvgIcon(asset: AppIcons.pigeonUniverse, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Join discussion...',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.north_east_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
