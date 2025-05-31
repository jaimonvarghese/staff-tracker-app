import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SiginSignupButton extends StatelessWidget {
  const SiginSignupButton({
    super.key,
    required this.text1,
    required this.text2, required this.widget,
  });
  final String text1;
  final String text2;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text1, style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (ctx) => widget));
          },
          child: Text(
            text2,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
