import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

// Layout mode for [MotifCard].
enum MotifCardMode { grid, list }

// Reusable motif card with grid and list layouts.
class MotifCard extends StatefulWidget {
  const MotifCard.grid({
    super.key,
    required this.title,
    this.imageUrl,
    this.code,
    this.subtitle,
    this.dateText,
    this.tagLabel,
    this.heroTag,
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
    this.heroTag,
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
  final String? heroTag;
  final VoidCallback? onTap;
  final Widget? trailing;

  bool get _isNetwork => imageUrl != null && imageUrl!.startsWith('http');

  @override
  State<MotifCard> createState() => _MotifCardState();
}

class _MotifCardState extends State<MotifCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(
            color: _isHovered ? AppColors.gold : AppColors.borderGray,
            width: _isHovered ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hover) => setState(() => _isHovered = hover),
          onHighlightChanged: (highlight) => setState(() => _isHovered = highlight),
          child: widget.mode == MotifCardMode.grid ? _buildGrid() : _buildList(),
        ),
      ),
    )
    .animate(target: _isHovered ? 1 : 0)
    .scaleXY(end: 1.02, duration: 150.ms, curve: Curves.easeOut)
    .animate() // Entrance animation
    .fade(duration: 400.ms)
    .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuart);
  }

  Widget _buildGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 1, child: _Thumbnail(widget)),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.code != null) _CodeLabel(widget.code!),
              Text(
                widget.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null || widget.dateText != null)
                Text(
                  widget.subtitle ?? widget.dateText!,
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
            child: SizedBox(width: 64, height: 64, child: _Thumbnail(widget)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.code != null) _CodeLabel(widget.code!),
                Text(
                  widget.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.tagLabel != null || widget.dateText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      [widget.tagLabel, widget.dateText].whereType<String>().join(' · '),
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
          if (widget.trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            widget.trailing!,
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
    Widget child;

    if (url == null) {
      child = const _Placeholder();
    } else if (card._isNetwork) {
      child = CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const _Placeholder(),
        errorWidget: (_, __, ___) => const _Placeholder(broken: true),
      );
    } else {
      child = Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _Placeholder(broken: true),
      );
    }

    if (card.heroTag != null) {
      return Hero(
        tag: card.heroTag!,
        child: child,
      );
    }
    return child;
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
