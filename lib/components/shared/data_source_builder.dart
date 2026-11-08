import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/services/data_source_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Builds [stock] or [live] depending on the admin's data-source setting, and
/// rebuilds when it changes.
class DataSourceBuilder extends StatelessWidget {
  const DataSourceBuilder({super.key, required this.stock, required this.live});

  final WidgetBuilder stock;
  final WidgetBuilder live;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserDataSource>(
      valueListenable: DataSourceService.current,
      builder: (BuildContext context, UserDataSource source, _) =>
          source == UserDataSource.live ? live(context) : stock(context),
    );
  }
}

/// Runs [load] and builds its result, with a skeleton while loading, an error
/// state with retry, and pull-to-refresh-friendly [reload].
class LiveLoader<T> extends StatefulWidget {
  const LiveLoader({
    super.key,
    required this.load,
    required this.builder,
    this.placeholder,
    this.refreshKey,
  });

  final Future<T> Function() load;
  final Widget Function(
    BuildContext context,
    T data,
    Future<void> Function() reload,
  )
  builder;
  final Widget? placeholder;

  /// Change this to force a reload (e.g. a selected filter).
  final Object? refreshKey;

  @override
  State<LiveLoader<T>> createState() => LiveLoaderState<T>();
}

/// Reach this through a `GlobalKey<LiveLoaderState<T>>` to [reload] from
/// outside, e.g. a RefreshIndicator wrapping the loader.
class LiveLoaderState<T> extends State<LiveLoader<T>> {
  late Future<T> _future = widget.load();

  @override
  void didUpdateWidget(covariant LiveLoader<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _future = widget.load();
    }
  }

  Future<void> reload() async {
    final Future<T> next = widget.load();
    setState(() {
      _future = next;
    });
    try {
      await next;
    } catch (_) {
      // Surfaced by the FutureBuilder below.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return LiveErrorState(error: snapshot.error!, onRetry: reload);
        }
        if (!snapshot.hasData) {
          return widget.placeholder ?? const LiveSkeleton();
        }
        return widget.builder(context, snapshot.data as T, reload);
      },
    );
  }
}

/// Non-scrolling shimmer placeholder, safe to put inside a scroll view.
class LiveSkeleton extends StatelessWidget {
  const LiveSkeleton({super.key, this.cards = 3, this.rows = 0});

  final int cards;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < cards; i++) ...<Widget>[
            const SkeletonCard(),
            const SizedBox(height: 14),
          ],
          for (int i = 0; i < rows; i++) const SkeletonListTile(trailing: true),
        ],
      ),
    );
  }
}

class LiveErrorState extends StatelessWidget {
  const LiveErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.textMuted,
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load this right now.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            liveErrorMessage(error),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try again',
                style: TextStyle(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LiveEmptyState extends StatelessWidget {
  const LiveEmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon ?? Icons.inbox_outlined,
            color: AppColors.textMuted,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Turns a Supabase/Postgres error into something a user can read. RPCs in
/// supabase/schema.sql raise human-readable messages, so those pass through.
String liveErrorMessage(Object error) {
  if (error is PostgrestException) return error.message;
  if (error is AuthException) return error.message;
  return error.toString().replaceFirst('Exception: ', '');
}
