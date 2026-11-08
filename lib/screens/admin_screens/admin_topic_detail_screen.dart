import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/admin/admin_market_picker.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_market_list_tile.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

typedef _TopicData = ({List<AdminMarket> all, List<String> ids});

class AdminTopicDetailScreen extends StatefulWidget {
  const AdminTopicDetailScreen({super.key, required this.topic});

  final AdminTopic topic;

  @override
  State<AdminTopicDetailScreen> createState() => _AdminTopicDetailScreenState();
}

class _AdminTopicDetailScreenState extends State<AdminTopicDetailScreen> {
  final GlobalKey<LiveLoaderState<_TopicData>> _loaderKey =
      GlobalKey<LiveLoaderState<_TopicData>>();

  /// Last loaded data, for the add button outside the loader.
  _TopicData? _data;

  Future<_TopicData> _load() async {
    final (List<AdminMarket> all, List<String> ids) = await (
      AdminService.instance.fetchMarkets(),
      AdminService.instance.fetchTopicMarketIds(widget.topic.id),
    ).wait;
    return _data = (all: all, ids: ids);
  }

  Future<void> _save(List<String> ids, {String? success}) async {
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.setTopicMarkets(widget.topic.id, ids),
      success: success,
    );
    if (ok) await _loaderKey.currentState?.reload();
  }

  Future<void> _remove(String marketId) async {
    final _TopicData? data = _data;
    if (data == null) return;
    await _save(
      data.ids.where((String id) => id != marketId).toList(),
      success: 'Removed from ${widget.topic.name}.',
    );
  }

  Future<void> _addMarkets() async {
    final _TopicData? data = _data;
    if (data == null) return;
    final List<String>? picked = await showAdminMarketPicker(
      context,
      markets: data.all,
      selected: data.ids,
      title: 'Markets in ${widget.topic.name}',
    );
    if (picked == null || !mounted) return;
    await _save(picked, success: '${widget.topic.name} updated.');
  }

  Future<void> _delete() async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete ${widget.topic.name}?',
      message: 'The topic is removed from the app. Its markets are kept.',
    );
    if (!confirmed || !mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.deleteTopic(widget.topic.id),
      success: '${widget.topic.name} deleted.',
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminPageHeader(
                  title: widget.topic.name,
                  trailing: Pressable(
                    onTap: _delete,
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFD90125),
                      size: 24,
                    ),
                  ),
                ),
                Expanded(
                  child: LiveLoader<_TopicData>(
                    key: _loaderKey,
                    load: _load,
                    builder:
                        (
                          BuildContext context,
                          _TopicData data,
                          Future<void> Function() reload,
                        ) {
                          final Map<String, AdminMarket> byId =
                              <String, AdminMarket>{
                                for (final AdminMarket m in data.all) m.id: m,
                              };
                          final List<AdminMarket> markets = <AdminMarket>[
                            for (final String id in data.ids) ?byId[id],
                          ];
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(20, 25, 20, 120),
                            children: staggeredEntrance([
                              const Text(
                                'Markets',
                                style: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (markets.isEmpty)
                                const LiveEmptyState(
                                  message:
                                      'No markets in this topic yet. Tap + to '
                                      'add some.',
                                  icon: Icons.storefront_outlined,
                                ),
                              for (int i = 0; i < markets.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: AdminMarketRow(
                                    market: markets[i],
                                    showDivider: i < markets.length - 1,
                                    trailing: Pressable(
                                      onTap: () => _remove(markets[i].id),
                                      child: const Icon(
                                        Icons.remove_circle_outline_rounded,
                                        color: Color(0xFFE84A1F),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          );
                        },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 65,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _addMarkets,
                elevation: 0,
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.black,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
