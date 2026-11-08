import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/components/dashboard/post_detail_action_sheet.dart';
import 'package:pigeon/components/dashboard/post_detail_composer.dart';
import 'package:pigeon/components/dashboard/post_detail_post_card.dart';
import 'package:pigeon/components/dashboard/post_detail_reply_item.dart';
import 'package:pigeon/components/dashboard/post_detail_top_bar.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/live_widgets.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/router/app_router.dart';
import 'package:pigeon/screens/dashboard_screens/post_composer_screen.dart'
    show showPostComposerSheet;
import 'package:pigeon/services/live_data_service.dart';
import 'package:pigeon/utils/live_formatters.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, this.showTopSort = false, this.postId});

  final bool showTopSort;

  /// Shows this post from the database instead of the stock thread.
  final String? postId;

  @override
  Widget build(BuildContext context) {
    if (postId != null) return _LivePostDetail(postId: postId!);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
              children: staggeredEntrance([
                const PostDetailTopBar(),
                const SizedBox(height: 26),
                const PostDetailPostCard(
                  avatar: 'P',
                  avatarColor: Color(0xFFFFD6D6),
                  avatarImage: AppIcons.pigeonUniverse,
                  iconBgColor: Color(0xFFFF1C2D),
                  handle: '@PigeonUniverse',
                  timeLabel: '6h',
                  body:
                      'Users will now be able to create their own nests to hang out with each other on anything and specific topic/interests. Nests will officially launch tomorrow!',
                  reactions: <PostDetailReaction>[
                    PostDetailReaction(icon: '❤️', count: '26'),
                  ],
                ),
                if (showTopSort) ...const [SizedBox(height: 12), _SortRow()],
                const SizedBox(height: 18),
                const PostDetailReplyItem(
                  avatar: 'Z',
                  avatarImage: AppIcons.pigeonUniverse,
                  iconBgColor: Color(0xFFFF1C2D),
                  avatarColor: Color(0xFFFF1C2D),
                  handle: '@Z',
                  timeLabel: '6h',
                  body:
                      'Users will now be able to create their own nests to hang out with each other on anything and specific topic/interests. Nests will officially launch tomorrow!',
                  reactions: <PostDetailReaction>[
                    PostDetailReaction(icon: '❤️', count: '26'),
                  ],
                  showConnector: true,
                  replyCountLabel: '1.4K replies',
                ),
                const Divider(height: 1, color: Color(0xFF2A2A2A)),
                const PostDetailReplyItem(
                  avatar: 'P',
                  avatarImage: AppIcons.pigeonUniverse,
                  iconBgColor: Color(0xFFFF1C2D),
                  avatarColor: Color(0xFFFF1C2D),
                  handle: '@beebz',
                  timeLabel: '6h',
                  body:
                      'Users will be able to host sub channels in their Nest for specific topics or events. Also, Users will be able to administer roles and wager on real world events.',
                  reactions: <PostDetailReaction>[
                    PostDetailReaction(icon: '👌', count: '93'),
                  ],
                  replyCountLabel: '1.4K replies',
                ),
                const SizedBox(height: 4),
                const PostDetailReplyItem(
                  avatar: 'P',
                  avatarImage: AppIcons.pigeonUniverse,
                  iconBgColor: Color(0xFFFF1C2D),
                  avatarColor: Color(0xFFFF1C2D),
                  handle: '@beebz',
                  timeLabel: '6h',
                  body:
                      'Users will be able to host sub channels in their Nest for specific topics or events. Also, Users will be able to administer roles and wager on real world events.',
                  reactions: <PostDetailReaction>[
                    PostDetailReaction(icon: '👌', count: '93'),
                  ],
                  replyCountLabel: '1.4K replies',
                ),
              ]),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: const PostDetailComposer(),
            ),
            Positioned(
              right: 18,
              top: 18,
              child: Pressable(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    sheetAnimationStyle: AppMotion.sheet,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const Padding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 24),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: PostDetailActionSheet(),
                      ),
                    ),
                  );
                },
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Top',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 6),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textMuted,
          size: 18,
        ),
      ],
    );
  }
}

class _LiveThread {
  const _LiveThread(this.post, this.replies);

  final LivePost? post;
  final List<LivePost> replies;
}

/// A post and its replies from the `feed_posts` view, with replying and
/// reacting wired to the database.
class _LivePostDetail extends StatefulWidget {
  const _LivePostDetail({required this.postId});

  final String postId;

  @override
  State<_LivePostDetail> createState() => _LivePostDetailState();
}

class _LivePostDetailState extends State<_LivePostDetail> {
  final GlobalKey<LiveLoaderState<_LiveThread>> _loader =
      GlobalKey<LiveLoaderState<_LiveThread>>();

  Future<_LiveThread> _load() async {
    final List<Object?> r = await Future.wait(<Future<Object?>>[
      LiveDataService.fetchPost(widget.postId),
      LiveDataService.fetchReplies(widget.postId),
    ]);
    return _LiveThread(r[0] as LivePost?, r[1]! as List<LivePost>);
  }

  bool _requireSignIn() {
    if (LiveDataService.currentUserId != null) return true;
    AppToast.show(context, message: 'Log in to join the conversation.');
    return false;
  }

  Future<void> _reply() async {
    if (!_requireSignIn()) return;
    final bool? posted = await showPostComposerSheet(
      context,
      parentId: widget.postId,
    );
    if (posted == true) _loader.currentState?.reload();
  }

  Future<void> _react(LivePost post) async {
    if (!_requireSignIn()) return;
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (final String type in kReactionTypes)
                Pressable(
                  onTap: () => Navigator.of(context).pop(type),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: post.myReactions.contains(type)
                          ? AppColors.surfaceMuted
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      kReactionArt[type]!.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    try {
      await LiveDataService.setReaction(
        post.id,
        picked,
        on: !post.myReactions.contains(picked),
      );
      _loader.currentState?.reload();
    } catch (e) {
      if (mounted) AppToast.show(context, message: liveErrorMessage(e));
    }
  }

  static List<PostDetailReaction> _reactions(LivePost p) =>
      <PostDetailReaction>[
        for (final MapEntry<String, int> r in p.visibleReactions)
          PostDetailReaction(
            icon: kReactionArt[r.key]?.emoji ?? '❤️',
            count: LiveFormatters.countCompact(r.value),
          ),
      ];

  static String _initial(LivePost p) =>
      p.authorUsername.isEmpty ? '?' : p.authorUsername[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            LiveLoader<_LiveThread>(
              key: _loader,
              load: _load,
              placeholder: const Padding(
                padding: EdgeInsets.fromLTRB(18, 72, 18, 0),
                child: LiveSkeleton(cards: 1, rows: 3),
              ),
              builder: (BuildContext context, _LiveThread thread, reload) {
                final LivePost? post = thread.post;
                if (post == null) {
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                    children: const <Widget>[
                      PostDetailTopBar(),
                      LiveEmptyState(
                        message: 'This post is no longer available.',
                      ),
                    ],
                  );
                }
                return RefreshIndicator(
                  onRefresh: reload,
                  color: AppColors.accent,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                    children: staggeredEntrance(<Widget>[
                      const PostDetailTopBar(),
                      const SizedBox(height: 26),
                      PostDetailPostCard(
                        avatar: _initial(post),
                        avatarColor: livePostAvatarColor(post),
                        avatarUrl: post.authorAvatarUrl,
                        handle: post.handle,
                        timeLabel: LiveFormatters.timeAgo(post.createdAt),
                        body: post.body,
                        replyCount: LiveFormatters.countCompact(
                          post.replyCount,
                        ),
                        reactionCount: LiveFormatters.countCompact(
                          post.reactionCount,
                        ),
                        reactions: _reactions(post),
                        onAddReaction: () => _react(post),
                      ),
                      const SizedBox(height: 18),
                      if (thread.replies.isEmpty)
                        const LiveEmptyState(
                          icon: Icons.mode_comment_outlined,
                          message: 'No replies yet.',
                        ),
                      for (
                        int i = 0;
                        i < thread.replies.length;
                        i++
                      ) ...<Widget>[
                        if (i > 0)
                          const Divider(height: 1, color: Color(0xFF2A2A2A)),
                        Pressable(
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRouter.postDetail,
                            arguments: thread.replies[i].id,
                          ),
                          child: PostDetailReplyItem(
                            avatar: _initial(thread.replies[i]),
                            avatarColor: livePostAvatarColor(thread.replies[i]),
                            handle: thread.replies[i].handle,
                            timeLabel: LiveFormatters.timeAgo(
                              thread.replies[i].createdAt,
                            ),
                            body: thread.replies[i].body,
                            reactions: _reactions(thread.replies[i]),
                            replyCountLabel: thread.replies[i].replyCount > 0
                                ? '${LiveFormatters.countCompact(thread.replies[i].replyCount)} replies'
                                : null,
                          ),
                        ),
                      ],
                    ]),
                  ),
                );
              },
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: PostDetailComposer(onTap: _reply),
            ),
          ],
        ),
      ),
    );
  }
}
