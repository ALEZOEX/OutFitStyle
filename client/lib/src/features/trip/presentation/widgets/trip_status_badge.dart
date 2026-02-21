import 'package:flutter/material.dart';

import '../../domain/entities/trip.dart';

/// Виджет бейджа статуса поездки
class TripStatusBadge extends StatelessWidget {
  final TripStatus status;
  final double? size;

  const TripStatusBadge({
    super.key,
    required this.status,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors(status);
    final size = this.size ?? 24;

    return Container(
      width: size * 2.5,
      height: size,
      padding: EdgeInsets.symmetric(horizontal: size * 0.4, vertical: size * 0.15),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(size),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size * 0.3,
            height: size * 0.3,
            decoration: BoxDecoration(
              color: colors.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: size * 0.2),
          Text(
            status.name,
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w600,
              color: colors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusColors _getStatusColors(TripStatus status) {
    switch (status) {
      case TripStatus.planned:
        return const _StatusColors(
          backgroundColor: Color(0xFFE3F2FD),
          dotColor: Color(0xFF2196F3),
          textColor: Color(0xFF1565C0),
        );
      case TripStatus.active:
        return const _StatusColors(
          backgroundColor: Color(0xFFE8F5E9),
          dotColor: Color(0xFF4CAF50),
          textColor: Color(0xFF2E7D32),
        );
      case TripStatus.completed:
        return const _StatusColors(
          backgroundColor: Color(0xFFF5F5F5),
          dotColor: Color(0xFF9E9E9E),
          textColor: Color(0xFF616161),
        );
    }
  }
}

class _StatusColors {
  final Color backgroundColor;
  final Color dotColor;
  final Color textColor;

  const _StatusColors({
    required this.backgroundColor,
    required this.dotColor,
    required this.textColor,
  });
}
