import 'package:flutter/material.dart';

class AdminAxisLabel extends StatelessWidget {
  const AdminAxisLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB0B0B0),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.2,
      ),
    );
  }
}
