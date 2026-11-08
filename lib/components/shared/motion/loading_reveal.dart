import 'package:flutter/material.dart';
import 'package:pigeon/constants/app_motion.dart';

/// Shows [placeholder] (usually a shimmering skeleton) while content loads,
/// then cross-fades into [builder]'s content.
///
/// Pass [future] to wait on real work. Without one, the skeleton is held for
/// [AppMotion.simulatedLoad] — screens still backed by mock data use this so
/// the loading state matches what users will see once data is fetched.
///
/// Give a [cacheKey] to show the skeleton only on the first visit in a
/// session, the way cached data would behave — tab switches stay instant.
class LoadingReveal extends StatefulWidget {
  const LoadingReveal({
    super.key,
    required this.placeholder,
    required this.builder,
    this.future,
    this.cacheKey,
  });

  final Widget placeholder;
  final WidgetBuilder builder;
  final Future<void>? future;
  final String? cacheKey;

  static final Set<String> _loaded = <String>{};

  @override
  State<LoadingReveal> createState() => _LoadingRevealState();
}

class _LoadingRevealState extends State<LoadingReveal>
    with SingleTickerProviderStateMixin {
  // Ticker-based wait instead of a Timer, so nothing is left pending if the
  // screen is popped mid-load.
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: AppMotion.simulatedLoad,
  );
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.future == null &&
        LoadingReveal._loaded.contains(widget.cacheKey)) {
      _ready = true;
      return;
    }
    final Future<void> wait =
        widget.future ?? _hold.forward().orCancel.catchError((_) {});
    wait.whenComplete(() {
      if (widget.cacheKey != null) LoadingReveal._loaded.add(widget.cacheKey!);
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.slow,
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[...previous, ?current],
      ),
      child: _ready
          ? KeyedSubtree(
              key: const ValueKey<String>('content'),
              child: Builder(builder: widget.builder),
            )
          : KeyedSubtree(
              key: const ValueKey<String>('placeholder'),
              child: widget.placeholder,
            ),
    );
  }
}
