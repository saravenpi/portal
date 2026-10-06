import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/ui/pixel_icons.dart';
import '../../../../core/ui/widgets/layout_primitives.dart';
import '../../../../core/ui/widgets/pixel_button.dart';
import '../../../../core/ui/widgets/pixel_text_field.dart';
import '../../../../data/storage/portal_vault.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _validating = false;
  bool _exporting = false;
  String? _statusMessage;

  Future<void> _pickDirectory(PortalVault vault) async {
    final String? selectedDirectory =
        await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
      await vault.setVaultDirectory(selectedDirectory);
      if (mounted) {
        setState(() {
          _statusMessage = 'VAULT DIRECTORY UPDATED: $selectedDirectory';
        });
      }
    }
  }

  Future<void> _switchActiveFile(BuildContext context, PortalVault vault) async {
    final TextEditingController fileController = TextEditingController(
      text: vault.activeFilePath.split(Platform.pathSeparator).last,
    );

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('SWITCH ACTIVE FILE', style: AppTypography.title),
        content: PixelTextField(
          controller: fileController,
          label: 'FILE NAME',
          hintText: 'portal.yml',
          autofocus: true,
        ),
        actions: <Widget>[
          PixelButton(
            label: 'CANCEL',
            variant: PixelButtonVariant.ghost,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          PixelButton(
            label: 'SWITCH',
            variant: PixelButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(fileController.text.trim()),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await vault.setActiveFile(result);
      if (mounted) {
        setState(() {
          _statusMessage = 'ACTIVE FILE SET TO: $result';
        });
      }
    }
  }

  Future<void> _checkHealth(PortalVault vault) async {
    setState(() {
      _validating = true;
      _statusMessage = 'CHECKING LINK HEALTH...';
    });
    try {
      await vault.validateAllLinks();
      if (mounted) {
        setState(() {
          _statusMessage = 'ALL LINKS VALIDATED SUCCESSFULLY';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'ERROR VALIDATING LINKS: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _validating = false);
      }
    }
  }

  Future<void> _exportHtml(PortalVault vault) async {
    setState(() {
      _exporting = true;
      _statusMessage = 'GENERATING HTML EXPORT...';
    });
    try {
      await vault.exportHtml();
      if (mounted) {
        setState(() {
          _statusMessage =
              'HTML EXPORTED TO: ${vault.vaultDirectory}/index.html';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'EXPORT FAILED: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PortalVault vault = context.watch<PortalVault>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppLayout.maxTextMeasure),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('SETTINGS', style: AppTypography.display),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'LOCAL VAULT AND FILE CONFIGURATION',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Rule(),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: 'STORAGE & SYNC',
                children: <Widget>[
                  _SettingRow(
                    label: 'VAULT DIRECTORY',
                    value: vault.vaultDirectory,
                    action: PixelButton(
                      label: 'CHANGE',
                      variant: PixelButtonVariant.secondary,
                      onPressed: () => _pickDirectory(vault),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingRow(
                    label: 'ACTIVE FILE',
                    value: vault.activeFilePath,
                    action: PixelButton(
                      label: 'SWITCH',
                      variant: PixelButtonVariant.secondary,
                      onPressed: () => _switchActiveFile(context, vault),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingRow(
                    label: 'LIVE WATCHER',
                    value: vault.isWatching
                        ? 'WATCHING FOR CHANGES'
                        : 'WATCHER PAUSED / DISABLED',
                    valueColor: vault.isWatching
                        ? AppColors.success
                        : AppColors.textTertiary,
                    action: PixelButton(
                      label: 'RELOAD',
                      variant: PixelButtonVariant.ghost,
                      onPressed: vault.load,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Rule(),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: 'MAINTENANCE & EXPORT',
                children: <Widget>[
                  _SettingRow(
                    label: 'DEAD LINK CHECKER',
                    value: 'VALIDATE REACHABILITY OF ALL BOOKMARKED LINKS',
                    action: PixelButton(
                      label: _validating ? 'VALIDATING...' : 'RUN CHECK',
                      icon: PixelIcons.heart,
                      variant: PixelButtonVariant.secondary,
                      onPressed: _validating ? null : () => _checkHealth(vault),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SettingRow(
                    label: 'STATIC HTML EXPORT',
                    value: 'COMPILES SELF-CONTAINED INDEX.HTML IN VAULT',
                    action: PixelButton(
                      label: _exporting ? 'EXPORTING...' : 'EXPORT',
                      icon: PixelIcons.download,
                      variant: PixelButtonVariant.secondary,
                      onPressed: _exporting ? null : () => _exportHtml(vault),
                    ),
                  ),
                ],
              ),
              if (_statusMessage != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border.all(
                      color: AppColors.textPrimary,
                      width: AppSpacing.hairline,
                    ),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: AppTypography.captionStrong,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              const Rule(),
              const SizedBox(height: AppSpacing.lg),
              const _AboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: AppTypography.overline),
        const SizedBox(height: AppSpacing.md),
        ...children,
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.action,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.rule,
          width: AppSpacing.hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text('PORTAL v0.1.0', style: AppTypography.headline),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'MINIMAL, LOCAL-FIRST BOOKMARKS MANAGER BUILT WITH INVERTED SWISS TYPOGRAPHY.',
          style: AppTypography.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'AUTHOR: SARAVENPI',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
