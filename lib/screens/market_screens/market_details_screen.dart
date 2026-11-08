import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/dashboard/market_top_bar.dart';
import 'package:pigeon/components/market_cards/market_detail_sheets.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/models/market_detail.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/dashboard_screens/post_composer_screen.dart'
    show showPostComposerSheet;
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketDetailsScreen extends StatelessWidget {
  const MarketDetailsScreen({super.key, this.detail, this.marketRef});

  final MarketDetail? detail;

  /// Opens a market from the database instead of a stock [detail].
  final LiveMarketRef? marketRef;

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

  void _openTrade(
    BuildContext context,
    MarketCandidate candidate,
    int optionCount,
  ) {
    Navigator.of(context).pushNamed(
      AppRouter.marketTradeInput,
      arguments: <String, dynamic>{
        'candidateName': candidate.name,
        'candidateInitials': _initialsFor(candidate.name),
        'candidateColor': candidate.avatarColor,
        'pricePerShare': _parsePrice(candidate.amount),
        'walletBalance': 59674,
        'optionCount': optionCount,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (marketRef != null) return _LiveMarketDetails(marketId: marketRef!.id);
    return _MarketDetailView(
      data: detail ?? _defaultPolitics,
      onBuy: (MarketCandidate c) => _openTrade(
        context,
        c,
        (detail ?? _defaultPolitics).candidates.length,
      ),
    );
  }
}

class _MarketDetailView extends StatelessWidget {
  const _MarketDetailView({
    required this.data,
    this.onBuy,
    this.onRelatedTap,
    this.onJoinDiscussion,
  });

  final MarketDetail data;
  final void Function(MarketCandidate candidate)? onBuy;
  final void Function(RelatedMarket market)? onRelatedTap;
  final VoidCallback? onJoinDiscussion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: staggeredEntrance(<Widget>[
            MarketTopBar(title: data.subtitle),
            const SizedBox(height: 24),
            if (data.isSports)
              _SportsHeader(detail: data)
            else
              Text(
                data.question,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            const SizedBox(height: 24),
            if (data.showOptionsSection) _OptionsSummary(detail: data),
            const SizedBox(height: 18),
            _CandidateList(candidates: data.candidates, onBuy: onBuy),
            if (data.volume != null) ...<Widget>[
              const SizedBox(height: 28),
              Text(
                data.volume!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 28),
            const Text(
              'Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _DetailsCard(rows: data.details, detail: data),
            if (data.moreMarkets.isNotEmpty) ...<Widget>[
              const SizedBox(height: 28),
              const Text(
                'More Markets',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < data.moreMarkets.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: 16),
                _RelatedMarketTile(
                  item: data.moreMarkets[i],
                  onTap: onRelatedTap == null
                      ? null
                      : () => onRelatedTap!(data.moreMarkets[i]),
                ),
              ],
            ],
            if (data.joinDiscussion) ...<Widget>[
              const SizedBox(height: 28),
              _JoinDiscussionBar(onTap: onJoinDiscussion),
            ],
          ]),
        ),
      ),
    );
  }
}

class _SportsHeader extends StatelessWidget {
  const _SportsHeader({required this.detail});
  final MarketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (detail.liveTime != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFE542A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'LIVE  ${detail.liveTime}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _TeamColumn(
                name: detail.homeTeamName ?? 'HOME',
                color: detail.homeTeamColor,
                asset: detail.homeTeamAsset,
                url: detail.homeTeamBadgeUrl,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${detail.homeScore ?? '0'}  -  ${detail.awayScore ?? '0'}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: _TeamColumn(
                name: detail.awayTeamName ?? 'AWAY',
                color: detail.awayTeamColor,
                asset: detail.awayTeamAsset,
                url: detail.awayTeamBadgeUrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            for (int i = 0; i < detail.timeOptions.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 18),
              Text(
                detail.timeOptions[i],
                style: TextStyle(
                  color: i == 0 ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({
    required this.name,
    required this.color,
    this.asset,
    this.url,
  });

  final String name;
  final Color color;
  final String? asset;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: url != null
              ? LiveThumb(
                  url: url,
                  fallback: name.isNotEmpty ? name[0] : '?',
                  size: 48,
                  radius: 10,
                  backgroundColor: color,
                )
              : asset != null
              ? Image.asset(asset!, width: 36, height: 36, fit: BoxFit.contain)
              : Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _OptionsSummary extends StatelessWidget {
  const _OptionsSummary({required this.detail});
  final MarketDetail detail;

  @override
  Widget build(BuildContext context) {
    final MarketCandidate? yes = detail.candidates.isNotEmpty
        ? detail.candidates[0]
        : null;
    final MarketCandidate? no = detail.candidates.length > 1
        ? detail.candidates[1]
        : null;
    return Row(
      children: <Widget>[
        if (yes != null) ...<Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1A91FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${yes.name} ${yes.percentageLabel}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (yes != null && no != null) const SizedBox(width: 18),
        if (no != null) ...<Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFFA71A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${no.name} ${no.percentageLabel}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _CandidateList extends StatelessWidget {
  const _CandidateList({required this.candidates, this.onBuy});
  final List<MarketCandidate> candidates;
  final void Function(MarketCandidate candidate)? onBuy;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) return const SizedBox.shrink();
    return Column(
      children: <Widget>[
        for (int i = 0; i < candidates.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 16),
          _CandidateRow(
            candidate: candidates[i],
            onBuy: onBuy == null ? null : () => onBuy!(candidates[i]),
          ),
        ],
      ],
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({required this.candidate, this.onBuy});
  final MarketCandidate candidate;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _CandidateAvatar(
          emoji: candidate.avatar,
          asset: candidate.avatarAsset,
          url: candidate.avatarUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                candidate.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                candidate.percentageLabel,
                style: TextStyle(
                  color: candidate.percentageColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (candidate.amount != null)
          Pressable(
            onTap: onBuy,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                candidate.amount!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CandidateAvatar extends StatelessWidget {
  const _CandidateAvatar({this.emoji, this.asset, this.url});
  final String? emoji;
  final String? asset;
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return LiveThumb(
        url: url,
        fallback: emoji ?? '👤',
        size: 40,
        fallbackStyle: const TextStyle(fontSize: 20),
      );
    }
    if (asset != null) {
      return Container(
        width: 40,
        height: 40,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Image.asset(asset!, width: 40, height: 40, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji ?? '👤', style: const TextStyle(fontSize: 20)),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.rows, required this.detail});
  final List<MarketDetailRow> rows;
  final MarketDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            _DetailRow(
              label: rows[i].label,
              onTap: _sheetFor(rows[i].label, context),
            ),
            if (i != rows.length - 1)
              Container(
                height: 1,
                color: AppColors.divider.withValues(alpha: 0.18),
              ),
          ],
        ],
      ),
    );
  }

  VoidCallback? _sheetFor(String label, BuildContext context) {
    final String l = label.toLowerCase();
    if (l.contains('resolution')) {
      return () => ResolutionSheet.show(context, body: detail.resolutionText);
    }
    if (l.contains('settlement')) {
      return () => SettlementSheet.show(
        context,
        body: detail.settlementText,
        openLabel: detail.openLabel,
        closeLabel: detail.closeLabel,
      );
    }
    if (l.contains('wage')) {
      return () => WageTermsSheet.show(context, body: detail.wagerText);
    }
    return null;
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
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
    );
  }
}

class _RelatedMarketTile extends StatelessWidget {
  const _RelatedMarketTile({required this.item, this.onTap});
  final RelatedMarket item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      children: <Widget>[
        _RelatedAvatar(
          emoji: item.thumbnail,
          asset: item.thumbnailAsset,
          url: item.thumbnailUrl,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
    if (onTap == null) return row;
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

class _RelatedAvatar extends StatelessWidget {
  const _RelatedAvatar({this.emoji, this.asset, this.url});
  final String? emoji;
  final String? asset;
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return LiveThumb(
        url: url,
        fallback: emoji ?? '🏛️',
        size: 44,
        radius: 22,
        fallbackStyle: const TextStyle(fontSize: 20),
      );
    }
    if (asset != null) {
      return Container(
        width: 44,
        height: 44,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2A1F),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Image.asset(asset!, width: 44, height: 44, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.center,
      child: Text(emoji ?? '🏛️', style: const TextStyle(fontSize: 20)),
    );
  }
}

class _JoinDiscussionBar extends StatelessWidget {
  const _JoinDiscussionBar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget bar = Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFFA71A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🧔', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF1A91FF),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('👀', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 10),
          const Text(
            'Join discussion...',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.north_east_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ],
      ),
    );
    if (onTap == null) return bar;
    return Pressable(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: bar,
    );
  }
}

final MarketDetail _defaultPolitics = MarketDetail(
  subtitle: 'Politics - Election',
  question: 'Who will be the next\nNigerian President?',
  candidates: <MarketCandidate>[
    MarketCandidate(
      avatarAsset: 'assets/icons/nigerianelections/nextpresident.png',
      name: 'Peter Obi',
      percentageLabel: '28%',
      amount: '₦41',
    ),
    MarketCandidate(
      avatarAsset: 'assets/icons/nigerianelections/atikustepdown.png',
      name: 'Atiku Abubakar',
      percentageLabel: '13%',
      amount: '₦26',
    ),
    MarketCandidate(
      avatarAsset: 'assets/icons/nigerianelections/elfufai.png',
      name: 'El Rufai',
      percentageLabel: '5%',
      amount: '₦11',
    ),
  ],
  details: <MarketDetailRow>[
    MarketDetailRow(label: 'Resolution'),
    MarketDetailRow(label: 'Settlement'),
    MarketDetailRow(label: 'Wage terms'),
  ],
  moreMarkets: <RelatedMarket>[
    RelatedMarket(
      thumbnailAsset: 'assets/icons/nigerianelections/nextlagosstate.png',
      title: 'Next Lagos state\nGovernor?',
    ),
    RelatedMarket(
      thumbnailAsset: 'assets/icons/nigerianelections/atikustepdown.png',
      title: 'Will Atiku step down from the\n2027 Presidential race?',
    ),
    RelatedMarket(
      thumbnailAsset: 'assets/icons/fanbase/burnaboy.png',
      title: 'Will Burna Boy outsell\nhis last album?',
    ),
  ],
);

final MarketDetail _defaultCulture = MarketDetail(
  subtitle: 'Culture - Music',
  question: 'Will Davido drop an album in\n2026?',
  showOptionsSection: true,
  candidates: <MarketCandidate>[
    MarketCandidate(
      name: 'Yes',
      percentageLabel: '55%',
      amount: '₦59',
      percentageColor: Color(0xFF808085),
    ),
    MarketCandidate(
      name: 'No',
      percentageLabel: '28%',
      amount: '₦41',
      percentageColor: Color(0xFF808085),
    ),
  ],
  details: <MarketDetailRow>[
    MarketDetailRow(label: 'Resolution'),
    MarketDetailRow(label: 'Settlement'),
  ],
  volume: '₦769,642,414 Vol.',
  moreMarkets: <RelatedMarket>[],
);

final MarketDetail _defaultSports = MarketDetail(
  subtitle: 'Sports · Champions League',
  question: 'Arsenal vs. Man City',
  isSports: true,
  liveTime: '1H 5:17',
  homeScore: '3',
  awayScore: '1',
  homeTeamName: 'MAN',
  awayTeamName: 'ARS',
  homeTeamAsset: AppIcons.manchester,
  awayTeamAsset: AppIcons.arsenalBadge,
  homeTeamColor: Color(0xFF6CABDD),
  awayTeamColor: Color(0xFFEB0000),
  showOptionsSection: true,
  candidates: <MarketCandidate>[
    MarketCandidate(
      name: 'Man City',
      percentageLabel: '55%',
      amount: '₦59',
      percentageColor: Color(0xFF808085),
    ),
    MarketCandidate(
      name: 'Arsenal',
      percentageLabel: '41%',
      amount: '₦41',
      percentageColor: Color(0xFF808085),
    ),
  ],
  details: <MarketDetailRow>[MarketDetailRow(label: 'Resolution')],
  volume: '₦769,642,414 Vol.',
  moreMarkets: <RelatedMarket>[],
);

final Map<String, MarketDetail> kMarketDetailDefaults = <String, MarketDetail>{
  'politics': _defaultPolitics,
  'culture': _defaultCulture,
  'sports': _defaultSports,
};

/// A market loaded from the database. Prices refresh in realtime as trades
/// land (every trade updates `market_outcomes`).
class _LiveMarketDetails extends StatefulWidget {
  const _LiveMarketDetails({required this.marketId});

  final String marketId;

  @override
  State<_LiveMarketDetails> createState() => _LiveMarketDetailsState();
}

class _LiveMarketDetailsState extends State<_LiveMarketDetails> {
  late Future<MarketDetail> _future = _load();
  MarketDetail? _latest;
  RealtimeChannel? _prices;

  @override
  void initState() {
    super.initState();
    _prices = LiveDataService.watchMarketPrices(widget.marketId, () {
      if (mounted) setState(() => _future = _load());
    });
  }

  @override
  void dispose() {
    final RealtimeChannel? channel = _prices;
    if (channel != null) LiveDataService.unwatch(channel);
    super.dispose();
  }

  Future<MarketDetail> _load() async {
    final LiveMarket market = await LiveDataService.fetchMarket(
      widget.marketId,
    );
    final List<LiveMarket> related = await LiveDataService.fetchRelatedMarkets(
      market,
    );
    return _latest = _toDetail(market, related);
  }

  static MarketDetail _toDetail(LiveMarket m, List<LiveMarket> related) {
    final LiveEvent? event = m.event;
    final bool sports = event != null && event.hasTeams;
    final String status = switch (m.status) {
      'paused' => ' · Trading paused',
      'closed' => ' · Trading closed',
      'resolved' || 'settled' => ' · Resolved',
      'voided' => ' · Voided',
      'coming_soon' => ' · Coming soon',
      _ => '',
    };
    return MarketDetail(
      marketId: m.id,
      subtitle: m.subtitle(separator: ' - '),
      question: m.title,
      showOptionsSection: m.isBinary || sports,
      candidates: <MarketCandidate>[
        for (final LiveOutcome o in m.outcomes)
          MarketCandidate(
            outcomeId: o.id,
            name: o.label,
            avatar: o.emoji ?? '👤',
            avatarUrl: o.imageUrl,
            avatarColor: LiveFormatters.color(
              o.color,
              fallback: const Color(0xFFCB3D59),
            ),
            price: o.price,
            percentageLabel: o.isWinner == true
                ? 'Winner'
                : LiveFormatters.percent(o.price),
            amount: m.isTradable && o.price != null
                ? '₦${LiveFormatters.pricePerShareNaira(o.price)}'
                : null,
          ),
      ],
      details: <MarketDetailRow>[
        const MarketDetailRow(label: 'Resolution'),
        const MarketDetailRow(label: 'Settlement'),
        if (m.wagerTerms != null) const MarketDetailRow(label: 'Wage terms'),
      ],
      resolutionText:
          m.resolutionCriteria ??
          m.description ??
          'Resolution details will be published soon.',
      settlementText:
          m.settlementTerms ??
          'This market settles once the outcome has been verified.',
      wagerText: m.wagerTerms,
      openLabel: m.opensAt == null
          ? null
          : LiveFormatters.shortDate(m.opensAt!),
      closeLabel: m.closesAt == null
          ? null
          : LiveFormatters.shortDate(m.closesAt!),
      volume: '${LiveFormatters.naira(m.volumeKobo)} Vol.$status',
      moreMarkets: <RelatedMarket>[
        for (final LiveMarket r in related)
          RelatedMarket(
            marketId: r.id,
            title: r.title,
            thumbnail: '🏛️',
            thumbnailUrl: r.imageUrl,
          ),
      ],
      isSports: sports,
      liveTime: event?.liveLabel,
      homeScore: event?.homeScore?.toString(),
      awayScore: event?.awayScore?.toString(),
      homeTeamName: event?.homeTeam?.shortName ?? event?.homeTeam?.name,
      awayTeamName: event?.awayTeam?.shortName ?? event?.awayTeam?.name,
      homeTeamBadgeUrl: event?.homeTeam?.badgeUrl,
      awayTeamBadgeUrl: event?.awayTeam?.badgeUrl,
      homeTeamColor: LiveFormatters.color(
        event?.homeTeam?.color,
        fallback: const Color(0xFF6CABDD),
      ),
      awayTeamColor: LiveFormatters.color(
        event?.awayTeam?.color,
        fallback: const Color(0xFFEB0000),
      ),
    );
  }

  void _buy(MarketCandidate c) {
    if (LiveDataService.currentUserId == null) {
      AppToast.show(context, message: 'Log in to trade.');
      Navigator.of(context).pushNamed(AppRouter.login);
      return;
    }
    Navigator.of(context).pushNamed(
      AppRouter.marketTradeInput,
      arguments: <String, dynamic>{
        'candidateName': c.name,
        'candidateInitials': LiveFormatters.initials(c.name),
        'candidateColor': c.avatarColor,
        'pricePerShare': LiveFormatters.pricePerShareNaira(c.price),
        'outcomeId': c.outcomeId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MarketDetail>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<MarketDetail> snapshot) {
        // Keep showing the last good data while a realtime refresh loads.
        final MarketDetail? data = snapshot.data ?? _latest;
        if (data == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: snapshot.hasError
                  ? Center(
                      child: LiveErrorState(
                        error: snapshot.error!,
                        onRetry: () => setState(() => _future = _load()),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.fromLTRB(18, 72, 18, 0),
                      child: LiveSkeleton(rows: 3),
                    ),
            ),
          );
        }
        return _MarketDetailView(
          data: data,
          onBuy: _buy,
          onRelatedTap: (RelatedMarket r) =>
              Navigator.of(context).pushReplacementNamed(
                AppRouter.marketDetails,
                arguments: LiveMarketRef(r.marketId!),
              ),
          onJoinDiscussion: () =>
              showPostComposerSheet(context, marketId: widget.marketId),
        );
      },
    );
  }
}
