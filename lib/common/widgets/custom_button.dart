import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.title, required this.onPressed});
  final String title;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEB2F3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 155),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
