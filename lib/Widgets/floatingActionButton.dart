import 'package:expense_tracker_app/Constants/appColors.dart';
import 'package:flutter/material.dart';

class CommonFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String heroTag;

  const CommonFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      backgroundColor: AppColors.primaryBlue,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: AppColors.white, size: 26),
    );
  }
}
