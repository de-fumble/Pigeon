import 'package:flutter/material.dart';
import 'package:pigeon/components/admin/admin_create_button.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/skeleton.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/components/admin/admin_page_header.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

class AdminBannersScreen extends StatefulWidget {
  const AdminBannersScreen({super.key});

  @override
  State<AdminBannersScreen> createState() => _AdminBannersScreenState();
}

class _AdminBannersScreenState extends State<AdminBannersScreen> {
  /// `app_surface` values with banners, in display order.
  static const Map<String, String> _surfaces = <String, String>{
    'markets': 'MARKETS',
    'arena': 'ARENA',
  };

  final GlobalKey<LiveLoaderState<List<AdminBanner>>> _loaderKey =
      GlobalKey<LiveLoaderState<List<AdminBanner>>>();

  Future<void> _reload() async => _loaderKey.currentState?.reload();

  Future<void> _create() async {
    final String? surface = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text(
          'Where should it show?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        children: <Widget>[
          for (final MapEntry<String, String> s in _surfaces.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(s.key),
              child: Text(
                s.value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
    if (surface == null || !mounted) return;
    final String? imageUrl = await showTextInputDialog(
      context,
      title: 'Banner image',
      hint: 'Image URL (https://…)',
      confirmLabel: 'Next',
      keyboardType: TextInputType.url,
    );
    if (imageUrl == null || !mounted) return;
    final String? title = await showTextInputDialog(
      context,
      title: 'Banner title (optional)',
      hint: 'Leave empty for none',
      confirmLabel: 'Create',
    );
    if (!mounted) return;
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.createBanner(
        surface: surface,
        imageUrl: imageUrl,
        title: title,
      ),
      success: 'Banner added.',
    );
    if (ok) await _reload();
  }

  Future<void> _openActions(AdminBanner banner) async {
    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          banner.title ?? 'Banner',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('toggle'),
            child: Text(
              banner.isActive ? 'Hide from users' : 'Show to users',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('delete'),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF4F4F), fontSize: 16),
            ),
          ),
        ],
      ),
    );
    if (action == null || !mounted) return;
    final bool ok = action == 'toggle'
        ? await runWithToast(
            context,
            () => AdminService.instance.setBannerActive(
              banner.id,
              !banner.isActive,
            ),
          )
        : await showConfirmDialog(
                context,
                title: 'Delete banner?',
                message: 'It disappears from the app straight away.',
              ) &&
              mounted &&
              await runWithToast(
                context,
                () => AdminService.instance.deleteBanner(banner.id),
                success: 'Banner deleted.',
              );
    if (ok) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminPageHeader(
              title: 'Banners',
              trailing: AdminCreateButton(onPressed: _create),
            ),
            Expanded(
              child: LiveLoader<List<AdminBanner>>(
                key: _loaderKey,
                load: AdminService.instance.fetchBanners,
                placeholder: const SkeletonPage(
                  cards: 3,
                  rows: 0,
                  padding: EdgeInsets.fromLTRB(20, 21, 20, 24),
                ),
                builder:
                    (
                      BuildContext context,
                      List<AdminBanner> banners,
                      Future<void> Function() reload,
                    ) => RefreshIndicator(
                      color: AppColors.accent,
                      onRefresh: reload,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 21, 0, 24),
                        children: staggeredEntrance([
                          for (final MapEntry<String, String> surface
                              in _surfaces.entries) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: _SectionLabel(label: surface.value),
                            ),
                            const SizedBox(height: 20),
                            _BannerRow(
                              banners: banners
                                  .where(
                                    (AdminBanner b) => b.surface == surface.key,
                                  )
                                  .toList(),
                              onTap: _openActions,
                            ),
                            const SizedBox(height: 30),
                          ],
                        ]),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow({required this.banners, required this.onTap});

  final List<AdminBanner> banners;
  final ValueChanged<AdminBanner> onTap;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'No banners yet.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      );
    }
    return SizedBox(
      height: 215,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 16),
        itemBuilder: (BuildContext context, int index) {
          final AdminBanner banner = banners[index];
          return Pressable(
            onTap: () => onTap(banner),
            child: _BannerCard(banner: banner),
          );
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final AdminBanner banner;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: banner.isActive ? 1 : 0.4,
      child: Container(
        width: 187,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF787878),
                ),
              ),
            ),
            if (banner.title != null || !banner.isActive)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  banner.isActive
                      ? banner.title!
                      : 'Hidden${banner.title == null ? '' : ' · ${banner.title}'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    shadows: <Shadow>[
                      Shadow(color: Colors.black54, blurRadius: 6),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
