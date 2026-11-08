import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_shell.dart';
import 'package:pigeon/components/dashboard/dashboard_shell.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/utils/responsive.dart';

/// How a page is laid out on tablets and laptops (phones always get the page
/// as designed).
enum PageFrame {
  /// Shown inside the app frame: sidebar, phone-width column and side panel
  /// (DashboardShell).
  app,

  /// Lays itself out for wide windows.
  own,

  /// Wrapped in the admin sidebar layout (AdminShell).
  admin,
}

enum AppTransition {
  /// Default drill-in: the new screen glides in from the right while the
  /// previous one drifts left and dims underneath it.
  push,

  /// Sibling screens such as bottom-navigation tabs: a quick cross-fade with a
  /// slight scale so the switch feels instant but not abrupt.
  fadeThrough,

  /// Confirmation and success screens: the new screen settles in from a
  /// slightly larger scale.
  reveal,

  /// Full-screen composers: slides up from the bottom like a sheet.
  modal,
}

class AppPageRoute<T> extends PageRoute<T> {
  AppPageRoute({
    required this.builder,
    this.transition = AppTransition.push,
    this.frame = PageFrame.app,
    super.settings,
  });

  final WidgetBuilder builder;
  final AppTransition transition;

  /// How the page is laid out on tablets and laptops.
  final PageFrame frame;

  @override
  Duration get transitionDuration => switch (transition) {
    AppTransition.fadeThrough => AppMotion.medium,
    _ => AppMotion.page,
  };

  @override
  Duration get reverseTransitionDuration => switch (transition) {
    AppTransition.fadeThrough => AppMotion.fast,
    _ => AppMotion.pageReverse,
  };

  @override
  bool get opaque => true;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is PageRoute && !nextRoute.fullscreenDialog;

  AnimationController? get _gestureController => controller;

  bool get _swipeBackEnabled =>
      transition == AppTransition.push &&
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget page = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: switch (frame) {
        PageFrame.own => page,
        PageFrame.app => DashboardShell(child: page),
        PageFrame.admin => AdminShell(
          routeName: settings.name,
          arguments: settings.arguments,
          child: page,
        ),
      },
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return child;
    }

    // Follow the finger 1:1 while swiping back; ease everywhere else.
    final bool linear = navigator?.userGestureInProgress ?? false;
    final Animation<double> primary = linear
        ? animation
        : CurvedAnimation(
            parent: animation,
            curve: AppMotion.enter,
            reverseCurve: AppMotion.exit,
          );
    final Animation<double> secondary = linear
        ? secondaryAnimation
        : CurvedAnimation(
            parent: secondaryAnimation,
            curve: AppMotion.enter,
            reverseCurve: AppMotion.exit,
          );

    // Beside a sidebar, sliding the whole page would drag the sidebar along;
    // cross-fade instead.
    final AppTransition effective =
        frame != PageFrame.own &&
            MediaQuery.sizeOf(context).width >= Breakpoints.medium
        ? AppTransition.fadeThrough
        : transition;

    Widget page = switch (effective) {
      AppTransition.push => _PushTransition(animation: primary, child: child),
      AppTransition.fadeThrough => FadeTransition(
        opacity: primary,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1).animate(primary),
          child: child,
        ),
      ),
      AppTransition.reveal => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.6, curve: Curves.easeOut),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.06, end: 1).animate(primary),
          child: child,
        ),
      ),
      AppTransition.modal => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(primary),
        child: child,
      ),
    };

    // The route underneath recedes while this one is covered by a new push.
    page = _CoveredTransition(animation: secondary, child: page);

    if (_swipeBackEnabled) {
      page = _SwipeBackDetector<T>(route: this, child: page);
    }
    return page;
  }
}

class _PushTransition extends StatelessWidget {
  const _PushTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double t = animation.value;
        return FractionalTranslation(
          translation: Offset(lerpDouble(1, 0, t)!, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45 * t),
                  blurRadius: 24,
                  offset: const Offset(-6, 0),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _CoveredTransition extends StatelessWidget {
  const _CoveredTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double t = animation.value;
        if (t == 0) return child!;
        return FractionalTranslation(
          translation: Offset(-0.28 * t, 0),
          child: Transform.scale(
            scale: 1 - 0.03 * t,
            child: Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: AppColors.background.withValues(alpha: 0.55 * t),
                    ),
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

/// iOS-style edge swipe to go back, driving the route's own controller so the
/// custom push transition tracks the finger.
class _SwipeBackDetector<T> extends StatefulWidget {
  const _SwipeBackDetector({required this.route, required this.child});

  final AppPageRoute<T> route;
  final Widget child;

  @override
  State<_SwipeBackDetector<T>> createState() => _SwipeBackDetectorState<T>();
}

class _SwipeBackDetectorState<T> extends State<_SwipeBackDetector<T>> {
  static const double _edgeWidth = 24;
  static const double _flingVelocity = 1;

  bool _dragging = false;

  AppPageRoute<T> get _route => widget.route;

  bool get _canSwipe =>
      !_route.isFirst &&
      _route.isCurrent &&
      !_route.willHandlePopInternally &&
      _route.popDisposition == RoutePopDisposition.pop &&
      !(_route.navigator?.userGestureInProgress ?? true);

  void _start(DragStartDetails _) {
    if (!_canSwipe) return;
    _dragging = true;
    _route.navigator!.didStartUserGesture();
  }

  void _update(DragUpdateDetails details) {
    if (!_dragging) return;
    final double width = context.size?.width ?? 1;
    _route._gestureController!.value -= details.primaryDelta! / width;
  }

  void _end(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;

    final AnimationController controller = _route._gestureController!;
    final NavigatorState navigator = _route.navigator!;
    final double velocity =
        details.velocity.pixelsPerSecond.dx / (context.size?.width ?? 1);

    final bool goBack = velocity.abs() >= _flingVelocity
        ? velocity > 0
        : controller.value < 0.5;

    if (goBack) {
      navigator.pop();
    } else {
      final int ms = math.max(
        120,
        (AppMotion.pageReverse.inMilliseconds * (1 - controller.value)).round(),
      );
      controller.animateTo(
        1,
        duration: Duration(milliseconds: ms),
        curve: AppMotion.standard,
      );
    }

    if (controller.isAnimating) {
      late final AnimationStatusListener listener;
      listener = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(listener);
      };
      controller.addStatusListener(listener);
    } else {
      navigator.didStopUserGesture();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _start,
            onHorizontalDragUpdate: _update,
            onHorizontalDragEnd: _end,
            onHorizontalDragCancel: () => _end(DragEndDetails()),
          ),
        ),
      ],
    );
  }
}
