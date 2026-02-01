import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isOnline;
  final bool isDanger;

  const StatusBadge({
    super.key,
    required this.isOnline,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (!isOnline) {
      badgeColor = Colors.grey;
      statusText = 'OFFLINE';
      statusIcon = Icons.cloud_off_rounded;
    } else if (isDanger) {
      badgeColor = Colors.red;
      statusText = 'ТРЕВОГА: ПЕРЕГРЕВ';
      statusIcon = Icons.warning_rounded;
    } else {
      badgeColor = Colors.green;
      statusText = 'STATUS: OK';
      statusIcon = Icons.check_circle_rounded;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            statusIcon,
            color: badgeColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
