import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum BadgeVariant { success, warning, error, info, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final bool small;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.info,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 10 : 12, color: colors.$2),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: colors.$2,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (variant) {
      case BadgeVariant.success:
        return (AppColors.successSurface, AppColors.success);
      case BadgeVariant.warning:
        return (AppColors.warningSurface, AppColors.warning);
      case BadgeVariant.error:
        return (AppColors.errorSurface, AppColors.error);
      case BadgeVariant.info:
        return (AppColors.primarySurface, AppColors.primary);
      case BadgeVariant.neutral:
        return (AppColors.grey200, AppColors.grey700);
    }
  }
}

class VerifiedBadge extends StatelessWidget {
  final bool small;
  const VerifiedBadge({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: 'Verificado',
      variant: BadgeVariant.info,
      icon: Icons.verified,
      small: small,
    );
  }
}

class AvailabilityDot extends StatelessWidget {
  final bool isAvailable;
  final double size;
  const AvailabilityDot({
    super.key,
    required this.isAvailable,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.statusAvailable : AppColors.statusOffline,
        shape: BoxShape.circle,
      ),
    );
  }
}
