import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final Color? badgeColor;
  final Color? textColor;
  final double? iconSize;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.onTap,
    this.badgeColor,
    this.textColor,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications,
              size: iconSize ?? 28,
              color: Colors.white,
            ),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationBadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? badgeColor;
  final double? size;

  const NotificationBadgeIcon({
    Key? key,
    required this.icon,
    required this.count,
    this.onTap,
    this.iconColor,
    this.badgeColor,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: size ?? 24,
              color: iconColor ?? Colors.grey[700],
            ),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationCountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const NotificationCountBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}