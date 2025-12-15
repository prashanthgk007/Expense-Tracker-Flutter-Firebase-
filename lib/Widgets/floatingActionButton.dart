import 'package:flutter/material.dart';

class CommonFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const CommonFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.black,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}
