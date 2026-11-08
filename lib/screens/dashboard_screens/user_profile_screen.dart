import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/components/dashboard/profile_info_card.dart';
import 'package:pigeon/components/dashboard/profile_menu_sheet.dart';
import 'package:pigeon/components/dashboard/profile_screen_header.dart';
import 'package:pigeon/components/dashboard/profile_stats_row.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    required this.handle,
    required this.avatar,
    required this.avatarColor,
    required this.volume,
    required this.posts,
    required this.activity,
    required this.bio,
    required this.joinedDate,
  });

  final String handle;
  final String avatar;
  final Color avatarColor;
  final String volume;
  final String posts;
  final String activity;
  final String bio;
  final String joinedDate;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void _showProfileMenu() {
    showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Align(
          alignment: Alignment.topRight,
          child: ProfileMenuSheet(
            onShare: () => Navigator.of(context).pop(),
            onSettings: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.account);
            },
            onEditProfile: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.account);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: staggeredEntrance([
              ProfileScreenHeader(
                handle: widget.handle,
                onBack: () => Navigator.of(context).pop(),
                onWalletTap: () =>
                    Navigator.of(context).pushNamed(AppRouter.wallet),
                onMoreTap: _showProfileMenu,
              ),
              const SizedBox(height: 22),
              ProfileStatsRow(
                avatar: widget.avatar,
                avatarColor: widget.avatarColor,
                volume: widget.volume,
                posts: widget.posts,
                activity: widget.activity,
              ),
              const SizedBox(height: 18),
              ProfileInfoCard(bio: widget.bio, joinedDate: widget.joinedDate),
              const SizedBox(height: 24),
              const Text(
                'Posts',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const SizedBox(height: 420),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A profile from the database: the signed-in user's own (when [userId] is
/// null) or anyone else's, with their posts.
class LiveUserProfileScreen extends StatefulWidget {
  const LiveUserProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<LiveUserProfileScreen> createState() => _LiveUserProfileScreenState();
}

class _LiveProfileData {
  const _LiveProfileData(this.profile, this.posts);

  final LiveProfile profile;
  final List<LivePost> posts;
}

class _LiveUserProfileScreenState extends State<LiveUserProfileScreen> {
  final GlobalKey<LiveLoaderState<_LiveProfileData?>> _loader =
      GlobalKey<LiveLoaderState<_LiveProfileData?>>();

  bool get _isSelf =>
      widget.userId == null || widget.userId == LiveDataService.currentUserId;

  Future<_LiveProfileData?> _load() async {
    final LiveProfile? profile = await LiveDataService.fetchProfile(
      widget.userId,
    );
    if (profile == null) return null;
    final List<LivePost> posts = await LiveDataService.fetchFeed(
      authorId: profile.id,
    );
    return _LiveProfileData(profile, posts);
  }

  void _showMenu() {
    showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
        child: Align(
          alignment: Alignment.topRight,
          child: ProfileMenuSheet(
            onShare: () => Navigator.of(context).pop(),
            onSettings: () async {
              Navigator.of(context).pop();
              await Navigator.of(context).pushNamed(AppRouter.account);
              _loader.currentState?.reload();
            },
            onEditProfile: () async {
              Navigator.of(context).pop();
              await Navigator.of(context).pushNamed(AppRouter.account);
              _loader.currentState?.reload();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId == null && LiveDataService.currentUserId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Pressable(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              const LiveSignInPrompt(message: 'Log in to see your profile.'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LiveLoader<_LiveProfileData?>(
          key: _loader,
          load: _load,
          placeholder: const Padding(
            padding: EdgeInsets.fromLTRB(18, 48, 18, 0),
            child: LiveSkeleton(cards: 1, rows: 3),
          ),
          builder: (BuildContext context, _LiveProfileData? data, reload) {
            if (data == null) {
              return const Center(
                child: LiveEmptyState(message: 'This profile does not exist.'),
              );
            }
            final LiveProfile p = data.profile;
            return RefreshIndicator(
              onRefresh: reload,
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: staggeredEntrance(<Widget>[
                  ProfileScreenHeader(
                    handle: p.handle,
                    onBack: () => Navigator.of(context).pop(),
                    onWalletTap: _isSelf
                        ? () =>
                              Navigator.of(context).pushNamed(AppRouter.wallet)
                        : () {},
                    onMoreTap: _isSelf ? _showMenu : () {},
                  ),
                  const SizedBox(height: 22),
                  ProfileStatsRow(
                    avatar: p.username.isEmpty
                        ? '?'
                        : p.username[0].toUpperCase(),
                    avatarColor: p.avatarColor != null
                        ? LiveFormatters.color(p.avatarColor)
                        : LiveFormatters.avatarColorFor(p.username),
                    avatarUrl: p.avatarUrl,
                    volume: LiveFormatters.nairaCompact(p.tradeVolumeKobo),
                    posts: LiveFormatters.countCompact(p.postsCount),
                    activity: LiveFormatters.countCompact(p.tradesCount),
                  ),
                  const SizedBox(height: 18),
                  ProfileInfoCard(
                    bio: p.bio ?? 'No bio yet.',
                    joinedDate: LiveFormatters.shortDate(p.createdAt),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Posts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (data.posts.isEmpty)
                    const LiveEmptyState(
                      icon: Icons.forum_outlined,
                      message: 'No posts yet.',
                    ),
                  for (final LivePost post in data.posts) ...<Widget>[
                    Pressable(
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRouter.postDetail, arguments: post.id),
                      child: livePostCard(post),
                    ),
                    const SizedBox(height: 28),
                  ],
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
