import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const NotionCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }
    return content;
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warning;
      case 'accepted':
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return AppTheme.online;
      case 'rejected':
      case 'cancelled':
        return AppTheme.danger;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _label {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class OnlineBadge extends StatelessWidget {
  final bool isOnline;
  const OnlineBadge({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppTheme.online : AppTheme.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            color: isOnline ? AppTheme.online : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
