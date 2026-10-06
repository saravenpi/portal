import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/app_dialog.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../core/ui/widgets/pixel_text_field.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/link_item.dart';
import '../../../../domain/services/metadata_fetcher.dart';

class LinkEditorDialog extends StatefulWidget {
  const LinkEditorDialog({
    super.key,
    required this.categories,
    this.initialLink,
    this.initialCategoryId,
    this.initialUrl,
    this.metadataFetcher = const MetadataFetcher(),
  });

  final List<Category> categories;
  final LinkItem? initialLink;
  final String? initialCategoryId;
  final String? initialUrl;
  final MetadataFetcher metadataFetcher;

  static Future<LinkEditorResult?> show({
    required BuildContext context,
    required List<Category> categories,
    LinkItem? initialLink,
    String? initialCategoryId,
    String? initialUrl,
    MetadataFetcher? metadataFetcher,
  }) {
    return showDialog<LinkEditorResult>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => LinkEditorDialog(
        categories: categories,
        initialLink: initialLink,
        initialCategoryId: initialCategoryId,
        initialUrl: initialUrl,
        metadataFetcher: metadataFetcher ?? const MetadataFetcher(),
      ),
    );
  }

  @override
  State<LinkEditorDialog> createState() => _LinkEditorDialogState();
}

class LinkEditorResult {
  const LinkEditorResult({
    required this.link,
    required this.categoryId,
  });

  final LinkItem link;
  final String categoryId;
}

class _LinkEditorDialogState extends State<LinkEditorDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _tagsController;

  late String _selectedCategoryId;
  late bool _isFavorite;
  String? _faviconUrl;
  bool _isFetching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final LinkItem? initial = widget.initialLink;
    final String startingUrl = initial?.url ?? widget.initialUrl ?? '';
    _urlController = TextEditingController(text: startingUrl);
    _nameController = TextEditingController(text: initial?.name ?? '');
    _descController = TextEditingController(text: initial?.description ?? '');
    _tagsController =
        TextEditingController(text: initial?.tags.join(', ') ?? '');

    _selectedCategoryId = widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : 'Default');
    _isFavorite = initial?.isFavorite ?? false;
    _faviconUrl = initial?.faviconUrl;

    _urlController.addListener(_onUrlChanged);
    if (startingUrl.isNotEmpty && (initial?.name.isEmpty ?? true)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fetchMetadataForUrl(startingUrl);
        }
      });
    }
  }

  String _lastFetchedUrl = '';

  void _onUrlChanged() {
    final String url = _urlController.text.trim();
    if (url.length > 8 &&
        url != _lastFetchedUrl &&
        (url.startsWith('http://') ||
            url.startsWith('https://') ||
            url.startsWith('www.'))) {
      _fetchMetadataForUrl(url);
    }
  }

  Future<void> _fetchMetadataForUrl(String url) async {
    _lastFetchedUrl = url;
    setState(() => _isFetching = true);

    final MetadataResult result =
        await widget.metadataFetcher.fetchMetadata(url);

    if (!mounted) return;

    setState(() {
      _isFetching = false;
      if (result.faviconUrl != null && result.faviconUrl!.isNotEmpty) {
        _faviconUrl = result.faviconUrl;
      }
      if (_nameController.text.trim().isEmpty &&
          result.title != null &&
          result.title!.isNotEmpty) {
        _nameController.text = result.title!;
      }
      if (_descController.text.trim().isEmpty &&
          result.description != null &&
          result.description!.isNotEmpty) {
        _descController.text = result.description!;
      }
    });
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _urlController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onSave() {
    final String url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'URL IS REQUIRED');
      return;
    }

    final String name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : url;

    final List<String> tags = _tagsController.text
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();

    final LinkItem resultLink = widget.initialLink?.copyWith(
          name: name,
          url: url,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          clearDescription: _descController.text.trim().isEmpty,
          tags: tags,
          isFavorite: _isFavorite,
          faviconUrl: _faviconUrl,
        ) ??
        LinkItem(
          id: '${DateTime.now().microsecondsSinceEpoch}_${url.hashCode}',
          name: name,
          url: url,
          description: _descController.text.trim().isNotEmpty
              ? _descController.text.trim()
              : null,
          tags: tags,
          isFavorite: _isFavorite,
          faviconUrl: _faviconUrl,
          createdAt: DateTime.now(),
        );

    Navigator.of(context).pop(
      LinkEditorResult(
        link: resultLink,
        categoryId: _selectedCategoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initialLink != null;

    return AppDialog(
      title: isEdit ? 'EDIT LINK' : 'ADD NEW LINK',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: PixelTextField(
                  controller: _urlController,
                  label: 'URL',
                  hintText: 'https://example.com',
                  autofocus: !isEdit,
                  errorText: _error,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: PixelButton(
                  label: _isFetching ? 'FETCHING...' : 'FETCH',
                  icon: PixelIcons.download,
                  variant: PixelButtonVariant.secondary,
                  onPressed: _isFetching
                      ? null
                      : () => _fetchMetadataForUrl(_urlController.text.trim()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PixelTextField(
            controller: _nameController,
            label: 'TITLE',
            hintText: 'Link title or service name',
          ),
          const SizedBox(height: AppSpacing.md),
          PixelTextField(
            controller: _descController,
            label: 'DESCRIPTION',
            hintText: 'Short notes or summary',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('CATEGORY', style: AppTypography.overline),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.rule,
                    width: AppSpacing.hairline,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.categories
                            .any((Category c) => c.id == _selectedCategoryId)
                        ? _selectedCategoryId
                        : (widget.categories.isNotEmpty
                            ? widget.categories.first.id
                            : null),
                    dropdownColor: AppColors.surfaceRaised,
                    isExpanded: true,
                    style: AppTypography.body,
                    items: <DropdownMenuItem<String>>[
                      for (final Category cat in widget.categories)
                        DropdownMenuItem<String>(
                          value: cat.id,
                          child: Text(cat.name.toUpperCase()),
                        ),
                    ],
                    onChanged: (String? val) {
                      if (val != null) {
                        setState(() => _selectedCategoryId = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PixelTextField(
            controller: _tagsController,
            label: 'TAGS',
            hintText: 'dev, docs, tools (comma-separated)',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              InkWell(
                onTap: () => setState(() => _isFavorite = !_isFavorite),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      _isFavorite ? PixelIcons.heart : PixelIcons.heart,
                      size: 16,
                      color: _isFavorite
                          ? AppColors.accent
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'FAVORITE',
                      style: AppTypography.captionStrong.copyWith(
                        color: _isFavorite
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        PixelButton(
          label: 'CANCEL',
          variant: PixelButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        PixelButton(
          label: isEdit ? 'UPDATE' : 'SAVE',
          variant: PixelButtonVariant.primary,
          onPressed: _onSave,
        ),
      ],
    );
  }
}
