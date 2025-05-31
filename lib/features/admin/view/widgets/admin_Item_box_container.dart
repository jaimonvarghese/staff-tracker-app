
import 'package:flutter/material.dart';

class AdminItemBoxContainer extends StatelessWidget {
  const AdminItemBoxContainer({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onPressed,
  });
  final String text;
  final String buttonText;
  final Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 40),
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: Offset(1, 0.5),
            color: Colors.white54,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 15),
          TextButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEB2F3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: Text(buttonText, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
