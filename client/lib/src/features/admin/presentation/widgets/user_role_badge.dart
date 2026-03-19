import 'package:flutter/material.dart';
import '../../../../domain/enums/user_role.dart';

/// Бейдж для отображения роли пользователя
class UserRoleBadge extends StatelessWidget {
  final UserRole role;
  final double size;

  const UserRoleBadge({super.key, required this.role, this.size = 12.0});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(role.badgeColor, radix: 16) + 0xFF000000);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            role.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Бейдж статуса (активен/заблокирован)
class UserStatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isVerified;

  const UserStatusBadge({
    super.key,
    required this.isActive,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.red;
    final label =
        isActive
            ? (isVerified ? 'Активен' : 'Активен (не подтвержден)')
            : 'Заблокирован';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
