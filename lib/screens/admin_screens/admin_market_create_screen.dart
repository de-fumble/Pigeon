import 'package:flutter/material.dart';
import 'package:pigeon/components/shared/motion/pressable.dart';
import 'package:pigeon/components/shared/motion/fade_slide_in.dart';
import 'package:pigeon/constants/app_motion.dart';
import 'package:pigeon/components/admin/admin_market_create_detail_row.dart';
import 'package:pigeon/components/admin/admin_market_create_option_row.dart';
import 'package:pigeon/components/admin/admin_section_label.dart';
import 'package:pigeon/constants/app_colors.dart';
import 'package:pigeon/screens/admin_screens/admin_market_resolution_sheet.dart';
import 'package:pigeon/components/shared/app_dialogs.dart';
import 'package:pigeon/components/shared/app_toast.dart';
import 'package:pigeon/components/shared/data_source_builder.dart';
import 'package:pigeon/models/admin_models.dart';
import 'package:pigeon/services/admin_service.dart';

class AdminMarketCreateScreen extends StatefulWidget {
  const AdminMarketCreateScreen({super.key, required this.category});

  final AdminCategory category;

  @override
  State<AdminMarketCreateScreen> createState() =>
      _AdminMarketCreateScreenState();
}

/// Where a market sits under its category: a subcategory (Football) or a
/// topic (Elections). Null means the category itself.
typedef _Scope = ({String label, String? subcategoryId, String? topicId});

class _AdminMarketCreateScreenState extends State<AdminMarketCreateScreen> {
  late final AdminCategory _category = widget.category;
  _Scope? _scope;
  List<_Scope> _scopes = <_Scope>[];
  String _status = 'active';
  String _period = '';
  String _seed = '₦0.00';
  String _resolution = '';
  String _settlement = '';
  String _wagerTerms = '';
  final List<String> _links = <String>[];
  final List<_OptionEntry> _options = <_OptionEntry>[];
  final TextEditingController _titleController = TextEditingController();
  final _SeedTextController _seedController = _SeedTextController(text: '0.00');
  bool _saving = false;

  bool get _isSports => _category.slug == 'sports';

  @override
  void initState() {
    super.initState();
    _seedController.addListener(_onSeedChanged);
    _titleController.addListener(_onTitleChanged);
    _loadScopes();
  }

  @override
  void dispose() {
    _seedController.removeListener(_onSeedChanged);
    _seedController.dispose();
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadScopes() async {
    try {
      final (List<AdminCategory> categories, List<AdminTopic> topics) = await (
        AdminService.instance.fetchCategories(),
        AdminService.instance.fetchTopics(),
      ).wait;
      if (!mounted) return;
      setState(() {
        _scopes = <_Scope>[
          for (final AdminCategory c in categories)
            if (c.parentId == _category.id)
              (label: c.name, subcategoryId: c.id, topicId: null),
          for (final AdminTopic t in topics)
            if (t.categoryId == _category.id)
              (label: t.name, subcategoryId: null, topicId: t.id),
        ];
      });
    } catch (e) {
      if (mounted) AppToast.show(context, message: liveErrorMessage(e));
    }
  }

  void _onTitleChanged() => setState(() {});

  void _onSeedChanged() {
    setState(() {
      _seed = '₦${_seedController.text}';
    });
  }

  num? get _parsedValue {
    final String digits = _seedController.text
        .split('.00')
        .first
        .replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return num.tryParse(digits);
  }

  Future<String?> _openTextSheet({
    required String title,
    required String hint,
    required String initial,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: AppMotion.sheet,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      builder: (_) => AdminMarketResolutionSheet(
        initial: initial,
        title: title,
        hint: hint,
      ),
    );
  }

  Future<void> _openResolutionSheet() async {
    final String? result = await _openTextSheet(
      title: 'Resolution',
      hint: 'Describe how this market will be resolved',
      initial: _resolution,
    );
    if (result != null && mounted) {
      setState(() => _resolution = result);
    }
  }

  Future<void> _openSettlementSheet() async {
    final String? result = await _openTextSheet(
      title: 'Settlement',
      hint: 'When and how winners are paid out',
      initial: _settlement,
    );
    if (result != null && mounted) {
      setState(() => _settlement = result);
    }
  }

  Future<void> _openWagerTermsSheet() async {
    final String? result = await _openTextSheet(
      title: 'Wage terms',
      hint: 'Limits, fees and rules for wagers on this market',
      initial: _wagerTerms,
    );
    if (result != null && mounted) {
      setState(() => _wagerTerms = result);
    }
  }

  Future<void> _addLink() async {
    final String? url = await showTextInputDialog(
      context,
      title: 'Add link source',
      hint: 'https://…',
      confirmLabel: 'Add',
      keyboardType: TextInputType.url,
    );
    if (url != null && mounted) setState(() => _links.add(url));
  }

  Future<void> _openPeriod() async {
    final String? period = await showTextInputDialog(
      context,
      title: 'Period',
      hint: 'e.g. 1H, FT',
      initial: _period,
    );
    if (period != null && mounted) setState(() => _period = period);
  }

  /// Adds an option, or edits the one at [index]. A leading emoji becomes the
  /// option's avatar ("🎩 Bola Tinubu"). Clearing an existing option's text
  /// removes it.
  Future<void> _editOption([int? index]) async {
    final _OptionEntry? current = index == null ? null : _options[index];
    final String? text = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => TextInputDialog(
        title: current == null ? 'Add option' : 'Edit option',
        hint: 'e.g. 🎩 Bola Ahmed Tinubu',
        initial: current == null
            ? ''
            : '${current.avatar == null ? '' : '${current.avatar} '}'
                  '${current.label}',
        removeLabel: current == null ? null : 'Remove',
      ),
    );
    if (text == null || !mounted) return;
    final _OptionEntry? entry = _OptionEntry.parse(text);
    setState(() {
      if (index == null) {
        if (entry != null) _options.add(entry);
      } else if (entry == null) {
        _options.removeAt(index);
      } else {
        _options[index] = entry;
      }
    });
  }

  void _toggleSeed() {
    final num? current = _parsedValue;
    if (current == null || current == 0) {
      _seedController.text = '100000.00';
    } else {
      _seedController.text = '0.00';
    }
  }

  /// Active and Live markets open for trading, which needs a seed; without
  /// one the market is saved as a draft.
  bool get _savesAsDraft =>
      (_status == 'active' || _status == 'live') && (_parsedValue ?? 0) == 0;

  bool get _canSubmit =>
      !_saving &&
      _titleController.text.trim().length >= 3 &&
      _options.length >= 2;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);
    final bool ok = await runWithToast(
      context,
      () => AdminService.instance.createMarket(
        title: _titleController.text.trim(),
        categoryId: _category.id,
        subcategoryId: _scope?.subcategoryId,
        topicIds: <String>[?_scope?.topicId],
        options: <({String label, String? emoji})>[
          for (final _OptionEntry o in _options)
            (label: o.label, emoji: o.avatar),
        ],
        linkUrls: _links,
        period: _isSports && _period.isNotEmpty ? _period : null,
        resolutionCriteria: _resolution.isEmpty ? null : _resolution,
        settlementTerms: _settlement.isEmpty ? null : _settlement,
        wagerTerms: _wagerTerms.isEmpty ? null : _wagerTerms,
        seedKobo: ((_parsedValue ?? 0) * 100).toInt(),
        status: _savesAsDraft ? 'draft' : _status,
      ),
      success: _savesAsDraft ? 'Saved as a draft.' : 'Market published.',
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
    }
  }

  Future<void> _openCategoryMenu(BuildContext anchorContext) async {
    final RenderBox? renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final List<_Scope?> scopes = <_Scope?>[null, ..._scopes];

    final int? selected = await showMenu<int>(
      context: anchorContext,
      color: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      position: RelativeRect.fromLTRB(
        offset.dx - 180,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height + 360,
      ),
      items: <PopupMenuEntry<int>>[
        for (int i = 0; i < scopes.length; i++)
          PopupMenuItem<int>(
            padding: EdgeInsets.zero,
            value: i,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      scopes[i]?.label ?? _category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (scopes[i] == _scope)
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    if (selected != null && mounted) {
      setState(() => _scope = scopes[selected]);
    }
  }

  Future<void> _openStatusMenu(BuildContext anchorContext) async {
    final RenderBox? renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final List<String> statuses = kAdminSettableStatuses
        .where((String s) => s != 'closed')
        .toList();

    final String? selected = await showMenu<String>(
      context: anchorContext,
      color: AppColors.backgroundSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      position: RelativeRect.fromLTRB(
        offset.dx - 180,
        offset.dy + size.height + 4,
        offset.dx + size.width,
        offset.dy + size.height + 280,
      ),
      items: <PopupMenuEntry<String>>[
        for (final String value in statuses)
          PopupMenuItem<String>(
            padding: EdgeInsets.zero,
            value: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      kAdminMarketStatusLabels[value]!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (value == _status)
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    if (selected != null && mounted) {
      setState(() => _status = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_OptionEntry> options = _options;
    final bool hasOptions = options.isNotEmpty;
    final int optionCount = options.length < 2 ? 2 : options.length;
    final String optionPrice = '₦${(100 / optionCount).round()}';
    final String optionPercent = '${(100 / optionCount).round()}%';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Pressable(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: staggeredEntrance(<Widget>[
                    const AdminSectionLabel('Title'),
                    const SizedBox(height: 12),
                    _TitleRow(
                      controller: _titleController,
                      hasOptions: hasOptions,
                    ),
                    const SizedBox(height: 28),
                    const AdminSectionLabel('Category'),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (BuildContext anchorContext) {
                        return Pressable(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openCategoryMenu(anchorContext),
                          child: RichText(
                            text: TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: _category.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ⌄ ',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      _scope?.label ??
                                      (_scopes.isEmpty ? '' : 'None'),
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const AdminSectionLabel('Status'),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (BuildContext anchorContext) {
                        return Pressable(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openStatusMenu(anchorContext),
                          child: Row(
                            children: <Widget>[
                              Text(
                                kAdminMarketStatusLabels[_status]!,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    if (_isSports) ...<Widget>[
                      const SizedBox(height: 24),
                      const AdminSectionLabel('Period'),
                      const SizedBox(height: 12),
                      Pressable(
                        behavior: HitTestBehavior.opaque,
                        onTap: _openPeriod,
                        child: Text(
                          _period.isEmpty ? 'Not set' : _period,
                          style: TextStyle(
                            color: _period.isEmpty
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const AdminSectionLabel('Options'),
                    const SizedBox(height: 12),
                    for (int i = 0; i < options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Pressable(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _editOption(i),
                          child: AdminMarketCreateOptionRow(
                            avatar: options[i].avatar,
                            label: options[i].label,
                            amount: optionPrice,
                            percentage: optionPercent,
                          ),
                        ),
                      ),
                    for (int i = options.length; i < 2; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Pressable(
                          behavior: HitTestBehavior.opaque,
                          onTap: _editOption,
                          child: AdminMarketCreateOptionRow(
                            label: 'Option ${i + 1}',
                            amount: optionPrice,
                            percentage: optionPercent,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Pressable(
                        behavior: HitTestBehavior.opaque,
                        onTap: _editOption,
                        child: const AdminMarketCreateOptionRow(
                          isAddOther: true,
                          label: 'Add other option',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AdminSectionLabel('Market Details'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: <Widget>[
                          AdminMarketCreateDetailRow(
                            label: 'Resolution',
                            onTap: _openResolutionSheet,
                          ),
                          const Divider(color: Color(0x22333333), height: 1),
                          AdminMarketCreateDetailRow(
                            label: 'Settlement',
                            onTap: _openSettlementSheet,
                          ),
                          const Divider(color: Color(0x22333333), height: 1),
                          AdminMarketCreateDetailRow(
                            label: 'Wage terms',
                            onTap: _openWagerTermsSheet,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AdminSectionLabel('Related News'),
                    const SizedBox(height: 12),
                    Pressable(
                      behavior: HitTestBehavior.opaque,
                      onTap: _addLink,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Link sources',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              _links.isEmpty ? '' : '${_links.length}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (_links.isEmpty)
                              const Icon(
                                Icons.public_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        const Expanded(child: AdminSectionLabel('Market Seed')),
                        Pressable(
                          onTap: _toggleSeed,
                          child: Text(
                            _seed,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 398,
                        height: 90,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF262626),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Text(
                                  '₦',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _seedController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  cursorColor: AppColors.accent,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
              Center(
                child: SizedBox(
                  width: 398,
                  height: 50,
                  child: FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.surfaceDisabled,
                      foregroundColor: AppColors.buttonText,
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      _saving
                          ? 'Saving…'
                          : _savesAsDraft
                          ? 'Save draft'
                          : 'Publish',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionEntry {
  const _OptionEntry({this.avatar, required this.label});

  /// "🎩 Bola Tinubu" → avatar 🎩, label "Bola Tinubu". Null for empty text.
  static _OptionEntry? parse(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    final int space = trimmed.indexOf(' ');
    if (space > 0) {
      final String first = trimmed.substring(0, space);
      if (!RegExp(r'[A-Za-z0-9]').hasMatch(first)) {
        final String rest = trimmed.substring(space + 1).trim();
        if (rest.isNotEmpty) return _OptionEntry(avatar: first, label: rest);
      }
    }
    return _OptionEntry(label: trimmed);
  }

  final String? avatar;
  final String label;
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.controller, required this.hasOptions});

  final TextEditingController controller;
  final bool hasOptions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: hasOptions ? const Color(0xFF34343A) : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add_rounded,
            color: hasOptions ? Colors.white : AppColors.textMuted,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: controller,
            maxLines: null,
            cursorColor: AppColors.accent,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration.collapsed(
              hintText: 'Title',
              hintStyle: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SeedTextController extends TextEditingController {
  _SeedTextController({super.text});

  @override
  set value(TextEditingValue newValue) {
    final String raw = newValue.text
        .split('.00')
        .first
        .replaceAll(RegExp(r'[^0-9]'), '');
    final String digits = raw.isEmpty ? '0' : raw;
    final String formatted = _formatWithCommas(digits);
    super.value = TextEditingValue(
      text: '$formatted.00',
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String _formatWithCommas(String digits) {
    final reversed = digits.split('').reversed.toList();
    final withCommas = <String>[];
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withCommas.add(',');
      }
      withCommas.add(reversed[i]);
    }
    return withCommas.reversed.join();
  }
}
