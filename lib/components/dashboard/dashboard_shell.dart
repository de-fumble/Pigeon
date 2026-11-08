import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/components/dashboard/arena_bottom_navigation.dart';
import 'package:pigeon/components/dashboard/arena_compose_button.dart';
import 'package:pigeon/components/dashboard/arena_trending_card.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/onboarding/onboarding_eye_mark.dart';
import 'package:pigeon/components/shared/app_profile_avatar.dart';
import 'package:pigeon/components/shared/app_side_menu.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/account_service.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/services/supabase_service.dart';
import 'package:pigeon/utils/live_formatters.dart';
import 'package:pigeon/utils/responsive.dart';

/// The app's frame on every screen size.
///
/// * Phones: the four Arena tabs get the bottom navigation and the floating
///   compose button; every other page is shown exactly as designed.
/// * Tablets: a slim icon rail beside the page, held to a phone-width column.
/// * Laptops: a full sidebar with labels, the column, and from
///   [Breakpoints.wide] a side panel with search and trending markets.
///
/// On wide windows the sidebar, column and panel stay together as one group
/// centred in the window, so large monitors get even margins instead of the
/// pieces drifting to the edges.
class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.child,
    this.activeIndex,
    this.onCompose,
  });

  /// The tab this page is: 0 Arena, 1 Markets, 2 Notifications, 3 Search.
  /// Null for every other page (no tab highlighted, no bottom navigation).
  final int? activeIndex;
  final Widget child;

  /// Shown as the floating button on phones and a "Post" button in the
  /// sidebar; null hides it.
  final VoidCallback? onCompose;

  static const List<String> _tabRoutes = <String>[
    AppRouter.dashboardFeed,
    AppRouter.dashboardMarketsHome,
    AppRouter.notifications,
    AppRouter.dashboardSearch,
  ];

  /// Width of the side panel, including its gutter.
  static const double _panelWidth = 360;

  /// Switches tab. From a tab the tab is swapped in place; from any other
  /// page the stack is cleared, like primary navigation on the web.
  static void openTab(BuildContext context, int index) {
    final NavigatorState nav = Navigator.of(context);
    final String route = _tabRoutes[index];
    if (_tabRoutes.contains(ModalRoute.of(context)?.settings.name)) {
      nav.pushReplacementNamed(route);
    } else {
      nav.pushNamedAndRemoveUntil(route, (Route<dynamic> _) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final ScreenClass screen = Breakpoints.classOf(width);
    final int? tab = activeIndex;

    if (screen == ScreenClass.compact) {
      if (tab == null) return child;
      return Stack(
        children: <Widget>[
          child,
          Align(
            alignment: Alignment.bottomCenter,
            child: ArenaBottomNavigation(
              activeIndex: tab,
              onTap: (int index) {
                if (index != tab) openTab(context, index);
              },
            ),
          ),
          if (onCompose != null)
            Positioned(
              right: 18,
              bottom: 80,
              child: ArenaComposeButton(onTap: onCompose),
            ),
        ],
      );
    }

    final bool expanded = screen == ScreenClass.expanded;
    final bool showPanel = width >= Breakpoints.wide;
    final double nav = expanded ? 264 : 84;
    final double column = Breakpoints.columnFor(width);
    final double group = nav + column + (showPanel ? _panelWidth : 0);

    // Pages other than the tabs sit outside any Scaffold here, so the frame
    // brings its own Material for text and ink.
    return Material(
      color: AppColors.background,
      child: DashboardScope(
        child: Center(
          child: SizedBox(
            width: group,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _SideNav(
                  width: nav,
                  activeIndex: tab,
                  extended: expanded,
                  onCompose: onCompose,
                ),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                      vertical: BorderSide(color: AppColors.hairline),
                    ),
                  ),
                  child: SizedBox(
                    width: column,
                    child: PhoneWidthScope(width: column, child: child),
                  ),
                ),
                if (showPanel)
                  _SidePanel(width: _panelWidth, searchActive: tab == 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Marks a subtree as sitting inside the tablet/laptop dashboard, where the
/// sidebar already offers the menu and the account, so top bars hide theirs.
class DashboardScope extends InheritedWidget {
  const DashboardScope({super.key, required super.child});

  static bool hasSideNav(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardScope>() != null;

  @override
  bool updateShouldNotify(DashboardScope oldWidget) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────

class _NavEntry {
  const _NavEntry(this.label, this.icon, this.onTap, {this.tabIndex});

  final String label;
  final String icon;
  final void Function(BuildContext context) onTap;
  final int? tabIndex;
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.width,
    required this.activeIndex,
    required this.extended,
    required this.onCompose,
  });

  final double width;
  final int? activeIndex;
  final bool extended;
  final VoidCallback? onCompose;

  static final List<_NavEntry> _tabs = <_NavEntry>[
    _NavEntry(
      'Arena',
      AppIcons.arena,
      (c) => DashboardShell.openTab(c, 0),
      tabIndex: 0,
    ),
    _NavEntry(
      'Markets',
      AppIcons.markets,
      (c) => DashboardShell.openTab(c, 1),
      tabIndex: 1,
    ),
    _NavEntry(
      'Notifications',
      AppIcons.notifications,
      (c) => DashboardShell.openTab(c, 2),
      tabIndex: 2,
    ),
    _NavEntry(
      'Search',
      AppIcons.search,
      (c) => DashboardShell.openTab(c, 3),
      tabIndex: 3,
    ),
  ];

  static final List<_NavEntry> _more = <_NavEntry>[
    _NavEntry(
      'Wallet',
      AppIcons.wallet,
      (c) => Navigator.of(c).pushNamed(AppRouter.wallet),
    ),
    _NavEntry(
      'Profile',
      AppIcons.profile,
      (c) => Navigator.of(c).pushNamed(AppRouter.account),
    ),
    _NavEntry('More', AppIcons.more, (c) => showSidebar(c)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          extended ? 20 : 12,
          20,
          extended ? 20 : 12,
          20,
        ),
        child: Column(
          crossAxisAlignment: extended
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 48,
              child: Align(
                alignment: extended ? Alignment.centerLeft : Alignment.center,
                child: Pressable(
                  onTap: activeIndex == 0
                      ? null
                      : () => DashboardShell.openTab(context, 0),
                  child: Padding(
                    padding: EdgeInsets.only(left: extended ? 12 : 0),
                    child: extended
                        ? const OnboardingBrandMark()
                        : const OnboardingEyeMark(width: 44, height: 23),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (final _NavEntry entry in _tabs)
              _NavItem(
                entry: entry,
                extended: extended,
                selected: entry.tabIndex == activeIndex,
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.hairline),
            ),
            for (final _NavEntry entry in _more)
              _NavItem(entry: entry, extended: extended, selected: false),
            if (onCompose != null) ...<Widget>[
              const SizedBox(height: 20),
              extended
                  ? FilledButton.icon(
                      onPressed: onCompose,
                      icon: const AppSvgIcon(
                        asset: AppIcons.pencilEdit,
                        size: 20,
                        color: AppColors.buttonText,
                      ),
                      label: const Text('Post'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.buttonText,
                        minimumSize: const Size.fromHeight(52),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Tooltip(
                      message: 'Post',
                      child: ArenaComposeButton(onTap: onCompose),
                    ),
            ],
            const Spacer(),
            _AccountTile(extended: extended),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.entry,
    required this.extended,
    required this.selected,
  });

  final _NavEntry entry;
  final bool extended;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? AppColors.accent : AppColors.textMuted;
    final Widget icon = AppSvgIcon(asset: entry.icon, size: 26, color: color);

    final Widget content = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.enter,
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent.withValues(alpha: 0.12) : null,
        borderRadius: BorderRadius.circular(26),
      ),
      child: extended
          ? Row(
              children: <Widget>[
                icon,
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(width: 52, child: Center(child: icon)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Semantics(
        button: true,
        selected: selected,
        label: entry.label,
        child: Tooltip(
          message: extended ? '' : entry.label,
          child: Pressable(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (selected) return;
              HapticFeedback.selectionClick();
              entry.onTap(context);
            },
            child: content,
          ),
        ),
      ),
    );
  }
}

/// The signed-in user's avatar and handle, or a "Join" button.
class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccountState?>(
      valueListenable: AccountService.current,
      builder: (BuildContext context, AccountState? account, _) {
        if (account == null && !SupabaseService.isSignedIn) {
          final ButtonStyle style = FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textPrimary,
            minimumSize: Size(extended ? double.infinity : 60, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          );
          return FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRouter.login),
            style: style,
            child: Text(extended ? 'Join Pigeon' : 'Join'),
          );
        }

        void open() => Navigator.of(context).pushNamed(AppRouter.account);
        if (!extended) {
          return Tooltip(
            message: 'Account',
            child: AppProfileAvatar(size: 44, onTap: open),
          );
        }
        return Pressable(
          onTap: open,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Row(
              children: <Widget>[
                const AppProfileAvatar(size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    account?.handle ?? 'Your account',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Side panel (laptops)
// ─────────────────────────────────────────────────────────────────────────────

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.width, required this.searchActive});

  final double width;
  final bool searchActive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 28, 32),
        children: <Widget>[
          if (!searchActive) ...<Widget>[
            _SearchShortcut(onTap: () => DashboardShell.openTab(context, 3)),
            const SizedBox(height: 24),
          ],
          DataSourceBuilder(
            // The stock card carries its own heading.
            stock: (BuildContext context) => const ArenaTrendingCard(),
            live: (BuildContext context) => const _PanelCard(
              title: 'Trending markets',
              child: _LiveTrendingList(),
            ),
          ),
          const SizedBox(height: 24),
          const _PanelFooter(),
        ],
      ),
    );
  }
}

class _SearchShortcut extends StatelessWidget {
  const _SearchShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search markets, users and topics',
      child: Pressable(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceMutedAlt,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Row(
            children: <Widget>[
              AppSvgIcon(
                asset: AppIcons.search,
                size: 20,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search Pigeon',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AppSvgIcon(
                asset: AppIcons.trendUp,
                size: 22,
                color: AppColors.accent,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LiveTrendingList extends StatefulWidget {
  const _LiveTrendingList();

  @override
  State<_LiveTrendingList> createState() => _LiveTrendingListState();
}

class _LiveTrendingListState extends State<_LiveTrendingList> {
  late final Future<List<LiveMarket>> _future =
      LiveDataService.fetchTrendingMarkets(limit: 5);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LiveMarket>>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<List<LiveMarket>> snap) {
        final List<LiveMarket>? markets = snap.data;
        if (markets == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          );
        }
        if (markets.isEmpty) {
          return const Text(
            'Markets people trade will show up here.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          );
        }
        return Column(
          children: <Widget>[
            for (final LiveMarket market in markets)
              _TrendingRow(market: market),
          ],
        );
      },
    );
  }
}

class _TrendingRow extends StatelessWidget {
  const _TrendingRow({required this.market});

  final LiveMarket market;

  @override
  Widget build(BuildContext context) {
    final LiveOutcome? leader = market.outcomes.isEmpty
        ? null
        : market.outcomes.reduce(
            (LiveOutcome a, LiveOutcome b) =>
                (b.price ?? 0) > (a.price ?? 0) ? b : a,
          );
    return Pressable(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(
        context,
      ).pushNamed(AppRouter.marketDetails, arguments: LiveMarketRef(market.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    market.categoryName,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    market.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (leader != null) ...<Widget>[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    LiveFormatters.percent(leader.price),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      leader.label,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PanelFooter extends StatelessWidget {
  const _PanelFooter();

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(color: AppColors.textDim, fontSize: 13);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: <Widget>[
          Pressable(
            onTap: () => Navigator.of(context).pushNamed(AppRouter.getSupport),
            child: const Text('Help & Support', style: style),
          ),
          Pressable(
            onTap: () => showSidebar(context),
            child: const Text('Terms of Use', style: style),
          ),
          Text('© ${DateTime.now().year} Pigeon Arena', style: style),
        ],
      ),
    );
  }
}
