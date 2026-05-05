import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool isOnline;
  final bool showStatus;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 44,
    this.isOnline = false,
    this.showStatus = false,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size + (showStatus ? 6 : 0),
        height: size + (showStatus ? 6 : 0),
        child: Stack(
          children: [
            _buildAvatar(),
            if (showStatus) _buildStatusDot(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildPlaceholder(),
          errorWidget: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final initials = _getInitials();
    final bgColor = backgroundColor ?? AppColors.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withAlpha(30),
        shape: BoxShape.circle,
        border: Border.all(color: bgColor.withAlpha(80), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
            color: bgColor,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDot() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: size * 0.28,
        height: size * 0.28,
        decoration: BoxDecoration(
          color: isOnline ? AppColors.statusAvailable : AppColors.statusOffline,
          shape: BoxShape.circle,
          border: const Border.fromBorderSide(
            BorderSide(color: AppColors.white, width: 2),
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}
