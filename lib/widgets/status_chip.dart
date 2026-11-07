import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    switch (status) {
      case AppConstants.statusInProgress:
        background = const Color(0xFFE6E1FF);
        foreground = const Color(0xFF5B3FE0);
        break;
      case AppConstants.statusResolved:
        background = const Color(0xFFDDF5E5);
        foreground = const Color(0xFF2E8B57);
        break;
      default:
        background = const Color(0xFFFFEFC7);
        foreground = const Color(0xFFB7791F);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        AppConstants.statusLabel(status),
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}