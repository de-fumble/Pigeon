import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pigeon/components/dashboard/arena_fanbase_card.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_image.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/components/dashboard/search_input_bar.dart';
import 'package:pigeon/components/dashboard/search_predicted_card.dart';
import 'package:pigeon/components/dashboard/search_recent_item.dart';
import 'package:pigeon/components/dashboard/search_screen_top_bar.dart';
import 'package:pigeon/components/dashboard/search_section_header.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class DashboardSearchScreen extends StatefulWidget {
  const DashboardSearchScreen({super.key});

  @override
  State<DashboardSearchScreen> createState() => _DashboardSearchScreenState();
}

class _DashboardSearchScreenState extends State<DashboardSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _active = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _active = true;
    });
    _focusNode.requestFocus();
  }

  void _closeSearch() {
    setState(() {
      _active = false;
      _controller.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: DashboardShell(
          activeIndex: 3,
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 126),
                children: staggeredEntrance([
                  SearchScreenTopBar(showTitle: !_active),
                  const SizedBox(height: 18),
                  SearchInputBar(
                    controller: _controller,
                    focusNode: _focusNode,
                    active: _active,
                    onTap: _openSearch,
                    onCancel: _closeSearch,
                  ),
                  const SizedBox(height: 22),
                  DataSourceBuilder(
                    live: (BuildContext context) => _LiveSearchBody(
                      controller: _controller,
                      active: _active,
                    ),
                    stock: (BuildContext context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: staggeredEntrance(<Widget>[
                        if (!_active) ...const [
                          SearchSectionHeader(title: 'Most Predicted'),
                          SizedBox(height: 12),
                          SearchPredictedCard(),
                        ] else ...const [
                          SearchSectionHeader(title: 'Recents'),
                          SizedBox(height: 14),
                          SearchRecentItem(),
                          SizedBox(height: 22),
                          SearchRecentItem(),
                          SizedBox(height: 22),
                          SearchRecentItem(),
                          SizedBox(height: 22),
                          SearchRecentItem(),
                          SizedBox(height: 22),
                          SearchRecentItem(),
                          SizedBox(height: 22),
                          SearchRecentItem(circularAvatar: true),
                          SizedBox(height: 22),
                          SearchRecentItem(circularAvatar: true),
                          SizedBox(height: 22),
                          SearchRecentItem(circularAvatar: true),
                          SizedBox(height: 22),
                          SearchRecentItem(circularAvatar: true),
                        ],
                      ]),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Live search: trending markets when idle, recent searches when the field
/// is empty, and results from the `search` RPC as the user types.
class _LiveSearchBody extends StatefulWidget {
  const _LiveSearchBody({required this.controller, required this.active});

  final TextEditingController controller;
  final bool active;

  @override
  State<_LiveSearchBody> createState() => _LiveSearchBodyState();
}

class _LiveSearchBodyState extends State<_LiveSearchBody> {
  Timer? _debounce;
  String _query = '';
  Future<List<LiveSearchResult>>? _results;
  late Future<List<String>> _recents = LiveDataService.fetchRecentSearches();
  late final Future<List<LiveMarket>> _trending =
      LiveDataService.fetchTrendingMarkets();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final String q = widget.controller.text.trim();
    if (q == _query) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _query = q;
        _results = q.isEmpty ? null : LiveDataService.search(q);
        if (q.isEmpty) _recents = LiveDataService.fetchRecentSearches();
      });
    });
  }

  void _open(LiveSearchResult r) {
    LiveDataService.saveRecentSearch(_query).catchError((_) {});
    switch (r.kind) {
      case 'market':
        openLiveMarket(context, r.id);
      case 'user':
        Navigator.of(context).pushNamed(
          AppRouter.userProfile,
          arguments: <String, dynamic>{'userId': r.id},
        );
      default:
        Navigator.of(context).pushNamed(AppRouter.dashboardMarketsHome);
    }
  }

  void _useRecent(String q) {
    widget.controller
      ..text = q
      ..selection = TextSelection.collapsed(offset: q.length);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return FutureBuilder<List<LiveMarket>>(
        future: _trending,
        builder: (BuildContext context, AsyncSnapshot<List<LiveMarket>> s) {
          if (s.hasError) return LiveErrorState(error: s.error!);
          if (!s.hasData) return const LiveSkeleton(cards: 1);
          if (s.data!.isEmpty) {
            return const LiveEmptyState(message: 'Nothing trending yet.');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SearchSectionHeader(title: 'Most Predicted'),
              const SizedBox(height: 12),
              ArenaFanbaseCard(
                title: 'Trending',
                items: <ArenaFanbaseItemData>[
                  for (final LiveMarket m in s.data!)
                    ArenaFanbaseItemData(
                      avatar: LiveFormatters.initials(m.title),
                      avatarUrl: m.imageUrl,
                      avatarBgColor: const Color(0xFF1F2A1F),
                      title: m.title,
                      onTap: () => openLiveMarket(context, m.id),
                    ),
                ],
              ),
            ],
          );
        },
      );
    }

    if (_results == null) {
      return FutureBuilder<List<String>>(
        future: _recents,
        builder: (BuildContext context, AsyncSnapshot<List<String>> s) {
          final List<String> recents = s.data ?? const <String>[];
          if (recents.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SearchSectionHeader(title: 'Recents'),
              const SizedBox(height: 6),
              for (final String q in recents)
                Pressable(
                  onTap: () => _useRecent(q),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.history_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    return FutureBuilder<List<LiveSearchResult>>(
      future: _results,
      builder: (BuildContext context, AsyncSnapshot<List<LiveSearchResult>> s) {
        if (s.hasError) return LiveErrorState(error: s.error!);
        if (!s.hasData) return const LiveSkeleton(cards: 0, rows: 4);
        if (s.data!.isEmpty) {
          return LiveEmptyState(
            icon: Icons.search_off_rounded,
            message: 'No results for "$_query".',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final LiveSearchResult r in s.data!) ...<Widget>[
              Pressable(
                onTap: () => _open(r),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: <Widget>[
                    LiveThumb(
                      url: r.imageUrl,
                      fallback: switch (r.kind) {
                        'user' =>
                          r.title.isEmpty ? '?' : r.title[0].toUpperCase(),
                        'topic' => '#',
                        'event' => '📅',
                        _ => '🗳️',
                      },
                      size: 48,
                      radius: r.kind == 'user' ? null : 10,
                      backgroundColor: AppColors.surfaceMutedAlt,
                      fallbackStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            r.kind == 'user' ? '@${r.title}' : r.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (r.subtitle != null)
                            Text(
                              r.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
            ],
          ],
        );
      },
    );
  }
}
