import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/components/shared/app_svg_icon.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/live_models.dart';
import 'package:pigeon/services/data_source_service.dart';
import 'package:pigeon/services/live_data_service.dart';

class PostComposerScreen extends StatefulWidget {
  const PostComposerScreen({
    super.key,
    this.initialText = '',
    this.marketId,
    this.parentId,
  });

  final String initialText;

  /// Attaches the post to a market's discussion (live data only).
  final String? marketId;

  /// Publishes a reply to this post instead (live data only).
  final String? parentId;

  @override
  State<PostComposerScreen> createState() => _PostComposerScreenState();
}

class _PostComposerScreenState extends State<PostComposerScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  bool _posting = false;

  /// The signed-in user's handle, shown in place of the stock one.
  String? _liveHandle;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    if (DataSourceService.isLive) {
      LiveDataService.fetchProfile().then((LiveProfile? p) {
        if (mounted && p != null) setState(() => _liveHandle = p.handle);
      }, onError: (_) {});
    }
  }

  Future<void> _post() async {
    if (!DataSourceService.isLive) return;
    if (LiveDataService.currentUserId == null) {
      AppToast.show(context, message: 'Log in to post.');
      return;
    }
    setState(() => _posting = true);
    try {
      await LiveDataService.createPost(
        _controller.text,
        marketId: widget.marketId,
        parentId: widget.parentId,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _posting = false);
      AppToast.show(context, message: liveErrorMessage(e));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canPost = _controller.text.trim().isNotEmpty && !_posting;
    final double sheetHeight = MediaQuery.of(context).size.height * 0.95;

    return SizedBox(
      height: sheetHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const _SheetGrabber(),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.parentId == null ? 'Create post' : 'Reply',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    height: 32,
                    child: FilledButton(
                      onPressed: canPost ? _post : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: canPost
                            ? AppColors.surface
                            : AppColors.surfaceDisabled,
                        disabledBackgroundColor: AppColors.surfaceDisabled,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Post'),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF1C2D),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const AppSvgIcon(
                          asset: AppIcons.pigeonUniverse,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _liveHandle ?? '@PigeonUniverse',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                    cursorColor: AppColors.accent,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: 'Say it before it happens.',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceDisabled,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Resolves to true when a post was published (live data only).
Future<bool?> showPostComposerSheet(
  BuildContext context, {
  String? marketId,
  String? parentId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    sheetAnimationStyle: AppMotion.sheet,
    backgroundColor: AppColors.background,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) =>
        PostComposerScreen(marketId: marketId, parentId: parentId),
  );
}
