import 'package:flutter/material.dart';


class SigninSignupText extends StatelessWidget {
  const SigninSignupText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}