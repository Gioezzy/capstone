import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// Layout mode for [MotifCard].
enum MotifCardMode { grid, list }

// Reusable motif card with grid and list layouts.
class MotifCard extends StatelessWidget {
  const MotifCard.grid({
    super.key,
    required this.title,
    this.imageUrl,
    this.code,
    this.subtitle,
    this.dateText,
    this.tagLabel,
    this.onTap,
    this.trailing,
  }) : mode = MotifCardMode.grid;

  const MotifCard.list({
    super.key,
    required this.title,
    this.imageUrl,
    this.code,
    this.subtitle,
    this.dateText,
    this.tagLabel,
    this.onTap,
    this.trailing,
  }) : mode = MotifCardMode.list;

  final MotifCardMode mode;
  final String? imageUrl;
  final String title;
  final String? code;
  final String? subtitle;
  final String? dateText;
  final String? tagLabel;
  final VoidCallback? onTap;
  final Widget? trailing;

  bool get _isNetwork => imageUrl != null && imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(
          color: AppColors.borderGray,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: mode == MotifCardMode.grid ? _buildGrid() : _buildList(),
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 1, child: _Thumbnail(this)),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (code != null) _CodeLabel(code!),
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null || dateText != null)
                Text(
                  subtitle ?? dateText!,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: SizedBox(width: 64, height: 64, child: _Thumbnail(this)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (code != null) _CodeLabel(code!),
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tagLabel != null || dateText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      [tagLabel, dateText].whereType<String>().join(' · '),
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// Resolves network/asset/placeholder image for a card.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail(this.card);

  final MotifCard card;

  @override
  Widget build(BuildContext context) {
    final url = card.imageUrl;
    if (url == null) return const _Placeholder();
    if (card._isNetwork) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const _Placeholder(),
        errorWidget: (_, __, ___) => const _Placeholder(broken: true),
      );
    }
    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _Placeholder(broken: true),
    );
  }
}

// Gray placeholder box with an icon.
class _Placeholder extends StatelessWidget {
  const _Placeholder({this.broken = false});

  final bool broken;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceGray,
      alignment: Alignment.center,
      child: Icon(
        broken ? Icons.broken_image_outlined : Icons.image_outlined,
        color: AppColors.gray,
      ),
    );
  }
}

// Uppercase code label (e.g. "GEN-042").
class _CodeLabel extends StatelessWidget {
  const _CodeLabel(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return Text(
      code.toUpperCase(),
      style: AppTypography.labelSmallCaps,
    );
  }
}
