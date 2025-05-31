import 'package:flutter/material.dart';

class AdminHomeButton extends StatelessWidget {
  const AdminHomeButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  final String buttonText;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      label: Text(buttonText, style: TextStyle(color: Colors.white54)),
      icon: Icon(Icons.add_outlined, color: Colors.white54),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
      ),
    );
  }
}
