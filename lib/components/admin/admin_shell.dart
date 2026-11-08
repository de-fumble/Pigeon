import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pigeon/components/onboarding/onboarding_brand_mark.dart';
import 'package:pigeon/components/onboarding/onboarding_eye_mark.dart';
import 'package:pigeon/components/shared/app_profile_avatar.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/account_service.dart';
import 'package:pigeon/utils/responsive.dart';

/// Frame for every admin route on tablets and laptops: an admin sidebar to
/// jump between sections, and the page in a centred content area — wide for
/// dashboards and lists, form-width for create and detail pages. On phones it
/// returns [child] untouched.
class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.routeName,
    required this.arguments,
    required this.child,
  });

  final String? routeName;
  final Object? arguments;
  final Widget child;

  /// Content width for dashboard and list pages; wider on large monitors.
  static double wideContentFor(double windowWidth) =>
      windowWidth >= Breakpoints.large ? 1200 : 1040;

  /// Space either side of the content.
  static const double _gutter = 32;

  /// Content width for forms and detail pages.
  static const double formContent = 680;

  static const Set<String> _widePages = <String>{
    AppRouter.adminPanel,
    AppRouter.adminUsers,
    AppRouter.adminSection,
    AppRouter.adminMarkets,
    AppRouter.adminCategories,
    AppRouter.adminTopicsShelves,
    AppRouter.adminBanners,
  };

  static bool isAdminRoute(String? name) =>
      name != null && name.startsWith('/admin');

  /// Opens an admin section from the sidebar: back to the Admin Panel (or the
  /// first admin page) first, so sections don't pile up on the stack.
  static void openSection(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    final NavigatorState nav = Navigator.of(context);
    bool atPanel = false;
    nav.popUntil((Route<dynamic> r) {
      if (r.settings.name == AppRouter.adminPanel) {
        atPanel = true;
        return true;
      }
      return r.isFirst || !isAdminRoute(r.settings.name);
    });
    if (route == AppRouter.adminPanel && atPanel) return;
    nav.pushNamed(route, arguments: arguments);
  }

  /// Leaves the admin area for the app.
  static void exitAdmin(BuildContext context) {
    final NavigatorState nav = Navigator.of(context);
    String? landedOn;
    nav.popUntil((Route<dynamic> r) {
      final bool stop = r.isFirst || !isAdminRoute(r.settings.name);
      if (stop) landedOn = r.settings.name;
      return stop;
    });
    // Admins who logged straight into the panel have no app page beneath it.
    if (isAdminRoute(landedOn)) {
      nav.pushReplacementNamed(AppRouter.dashboardFeed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final ScreenClass screen = Breakpoints.classOf(width);
    if (screen == ScreenClass.compact) return child;

    final bool extended = screen == ScreenClass.expanded;
    final double sidebar = extended ? 264 : 84;
    // The sidebar and content stay together as one group centred in the
    // window. The group's width doesn't depend on the page, so the sidebar
    // stays put while moving between list and form pages.
    final double group = math.min(
      width,
      sidebar + 1 + wideContentFor(width) + 2 * _gutter,
    );
    final double area = group - sidebar - 1 - 2 * _gutter;
    final double content = _widePages.contains(routeName)
        ? area
        : math.min(area, formContent);

    return AdminShellScope(
      // The sidebar sits beside the page's Scaffold, so it needs its own
      // Material for text and ink to render properly.
      child: Material(
        color: AppColors.background,
        child: Center(
          child: SizedBox(
            width: group,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _AdminSidebar(
                  width: sidebar,
                  extended: extended,
                  active: _sectionFor(routeName, arguments),
                ),
                const VerticalDivider(width: 1, color: AppColors.hairline),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      // Desktop windows have no status bar to clear.
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: content,
                        child: PhoneWidthScope(width: content, child: child),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Which sidebar entry a route belongs to; detail and create pages light up
  /// their parent section.
  static String _sectionFor(String? route, Object? arguments) {
    switch (route) {
      case AppRouter.adminMarkets:
      case AppRouter.adminMarketCategorySelect:
      case AppRouter.adminMarketCreate:
        return AppRouter.adminMarkets;
      case AppRouter.adminCategories:
      case AppRouter.adminCategoryDetail:
        return AppRouter.adminCategories;
      case AppRouter.adminTopicsShelves:
      case AppRouter.adminTopicDetail:
      case AppRouter.adminCreateTopic:
      case AppRouter.adminCreateShelf:
        return AppRouter.adminTopicsShelves;
      case AppRouter.adminUsers:
      case AppRouter.adminBanners:
        return route!;
      case AppRouter.adminSection:
        return _wageVolumeKey;
      default:
        return AppRouter.adminPanel;
    }
  }

  static const String _wageVolumeKey = 'wage-volume';
}

/// Lets admin pages know the sidebar is showing, so their headers can drop
/// controls it already offers (close, side menu).
class AdminShellScope extends InheritedWidget {
  const AdminShellScope({super.key, required super.child});

  static bool hasSidebar(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminShellScope>() != null;

  @override
  bool updateShouldNotify(AdminShellScope oldWidget) => false;
}

class _Section {
  const _Section(this.key, this.label, this.icon, this.route, [this.arguments]);

  final String key;
  final String label;
  final String icon;
  final String route;
  final Object? arguments;
}

const List<_Section> _sections = <_Section>[
  _Section(
    AppRouter.adminPanel,
    'Overview',
    AppIcons.adminOverview,
    AppRouter.adminPanel,
  ),
  _Section(
    AppRouter.adminUsers,
    'Users',
    AppIcons.adminUsers,
    AppRouter.adminUsers,
  ),
  _Section(
    AdminShell._wageVolumeKey,
    'Wage Volume',
    AppIcons.adminWageVolume,
    AppRouter.adminSection,
    <String, String>{'title': 'Wage Volume'},
  ),
  _Section(
    AppRouter.adminMarkets,
    'Markets',
    AppIcons.adminMarkets,
    AppRouter.adminMarkets,
  ),
  _Section(
    AppRouter.adminCategories,
    'Categories',
    AppIcons.adminCategories,
    AppRouter.adminCategories,
  ),
  _Section(
    AppRouter.adminTopicsShelves,
    'Topics & Shelves',
    AppIcons.adminTopicsShelves,
    AppRouter.adminTopicsShelves,
  ),
  _Section(
    AppRouter.adminBanners,
    'Banners',
    AppIcons.adminBanners,
    AppRouter.adminBanners,
  ),
];

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({
    required this.width,
    required this.extended,
    required this.active,
  });

  final double width;
  final bool extended;
  final String active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: SafeArea(
        right: false,
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
                child: extended
                    ? const Row(
                        children: <Widget>[
                          SizedBox(width: 12),
                          OnboardingBrandMark(),
                          SizedBox(width: 10),
                          _AdminTag(),
                        ],
                      )
                    : const Center(
                        child: OnboardingEyeMark(width: 44, height: 23),
                      ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    for (final _Section s in _sections)
                      _SidebarItem(
                        label: s.label,
                        icon: s.icon,
                        extended: extended,
                        selected: s.key == active,
                        onTap: () => AdminShell.openSection(
                          context,
                          s.route,
                          arguments: s.arguments,
                        ),
                      ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.hairline),
              ),
              _SidebarItem(
                label: 'Back to Pigeon',
                icon: AppIcons.backToApp,
                extended: extended,
                selected: false,
                onTap: () => AdminShell.exitAdmin(context),
              ),
              const SizedBox(height: 12),
              _AdminAccount(extended: extended),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTag extends StatelessWidget {
  const _AdminTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'ADMIN',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.extended,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool extended;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Most admin icons keep their own colours; this tints the plain ones.
    final Widget glyph = AppSvgIcon(
      asset: icon,
      size: 24,
      color: selected ? AppColors.accent : AppColors.textMuted,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Tooltip(
          message: extended ? '' : label,
          child: Pressable(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (selected) return;
              HapticFeedback.selectionClick();
              onTap();
            },
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.enter,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: extended ? 14 : 0),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent.withValues(alpha: 0.12)
                    : null,
                borderRadius: BorderRadius.circular(25),
              ),
              child: extended
                  ? Row(
                      children: <Widget>[
                        glyph,
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(width: 50, child: Center(child: glyph)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminAccount extends StatelessWidget {
  const _AdminAccount({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    void open() => Navigator.of(context).pushNamed(AppRouter.account);
    if (!extended) {
      return Tooltip(
        message: 'Account',
        child: AppProfileAvatar(size: 44, onTap: open),
      );
    }
    return ValueListenableBuilder<AccountState?>(
      valueListenable: AccountService.current,
      builder: (BuildContext context, AccountState? account, _) {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        account?.handle ?? 'Admin',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Administrator',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
