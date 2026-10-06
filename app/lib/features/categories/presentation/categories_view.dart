import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/app_dialog.dart';
import '../../../../core/ui/widgets/layout_primitives.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../core/ui/widgets/pixel_text_field.dart';
import '../../../../data/storage/portal_vault.dart';
import '../../../../domain/models/category.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({
    super.key,
    this.onSelectCategory,
  });

  final ValueChanged<String>? onSelectCategory;

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    PortalVault vault,
  ) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AppDialog(
        title: 'NEW CATEGORY',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PixelTextField(
              controller: nameController,
              label: 'NAME',
              hintText: 'Work, Tools, Design',
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            PixelTextField(
              controller: descController,
              label: 'DESCRIPTION',
              hintText: 'Optional notes or description',
              maxLines: 2,
            ),
          ],
        ),
        actions: <Widget>[
          PixelButton(
            label: 'CANCEL',
            variant: PixelButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PixelButton(
            label: 'CREATE',
            variant: PixelButtonVariant.primary,
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      final String name = nameController.text.trim();
      final String? desc = descController.text.trim().isNotEmpty
          ? descController.text.trim()
          : null;
      await vault.addCategory(
        Category(
          id: '${DateTime.now().microsecondsSinceEpoch}_${name.hashCode}',
          name: name,
          description: desc,
        ),
      );
    }
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    PortalVault vault,
    Category category,
  ) async {
    final TextEditingController nameController =
        TextEditingController(text: category.name);
    final TextEditingController descController =
        TextEditingController(text: category.description ?? '');

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AppDialog(
        title: 'EDIT CATEGORY',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PixelTextField(
              controller: nameController,
              label: 'NAME',
              hintText: category.name,
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            PixelTextField(
              controller: descController,
              label: 'DESCRIPTION',
              hintText: 'Optional notes or description',
              maxLines: 2,
            ),
          ],
        ),
        actions: <Widget>[
          PixelButton(
            label: 'CANCEL',
            variant: PixelButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PixelButton(
            label: 'SAVE',
            variant: PixelButtonVariant.primary,
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      final String name = nameController.text.trim();
      final String? desc = descController.text.trim().isNotEmpty
          ? descController.text.trim()
          : null;
      await vault.updateCategory(
        category.copyWith(
          name: name,
          description: desc,
          clearDescription: desc == null,
        ),
      );
    }
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    PortalVault vault,
    Category category,
  ) async {
    final int linkCount = category.links.length;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AppDialog(
        title: 'DELETE CATEGORY',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ARE YOU SURE YOU WANT TO DELETE "${category.name.toUpperCase()}"?',
              style: AppTypography.body,
            ),
            if (linkCount > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'THIS WILL ALSO DELETE ALL $linkCount ASSOCIATED LINKS.',
                style: AppTypography.body.copyWith(color: AppColors.accent),
              ),
            ],
          ],
        ),
        actions: <Widget>[
          PixelButton(
            label: 'CANCEL',
            variant: PixelButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          PixelButton(
            label: 'DELETE',
            variant: PixelButtonVariant.danger,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await vault.deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final PortalVault vault = context.watch<PortalVault>();
    final List<Category> categories = vault.categories;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.rule,
                  width: AppSpacing.hairline,
                ),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  PixelIcons.folder,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${categories.length} ${categories.length == 1 ? 'CATEGORY' : 'CATEGORIES'}',
                  style: AppTypography.title,
                ),
                const Spacer(),
                PixelButton(
                  label: 'ADD CATEGORY',
                  icon: PixelIcons.plus,
                  variant: PixelButtonVariant.primary,
                  onPressed: () => _showAddCategoryDialog(context, vault),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          PixelIcons.folder,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'NO CATEGORIES DEFINED',
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          'CREATE A CATEGORY TO GROUP AND ORGANIZE YOUR LINKS.',
                          style: AppTypography.bodyMuted,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PixelButton(
                          label: 'CREATE CATEGORY',
                          variant: PixelButtonVariant.primary,
                          onPressed: () =>
                              _showAddCategoryDialog(context, vault),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: categories.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const Rule(),
                    itemBuilder: (BuildContext context, int index) {
                      final Category category = categories[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        leading: const Icon(
                          PixelIcons.folder,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                        title: Text(
                          category.name.toUpperCase(),
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: category.description != null &&
                                category.description!.isNotEmpty
                            ? Text(
                                category.description!,
                                style: AppTypography.bodyMuted,
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.rule,
                                  width: AppSpacing.hairline,
                                ),
                              ),
                              child: Text(
                                '${category.links.length} LINKS',
                                style: AppTypography.captionStrong,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            PixelIconButton(
                              icon: PixelIcons.pencil,
                              tooltip: 'RENAME',
                              onPressed: () => _showEditCategoryDialog(
                                context,
                                vault,
                                category,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            PixelIconButton(
                              icon: PixelIcons.trash,
                              color: AppColors.accent,
                              tooltip: 'DELETE',
                              onPressed: () => _confirmDeleteCategory(
                                context,
                                vault,
                                category,
                              ),
                            ),
                          ],
                        ),
                        onTap: onSelectCategory != null
                            ? () => onSelectCategory!(category.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
