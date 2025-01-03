import "package:flutter/material.dart";
import "package:calmwaves_app/palette.dart";

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double buttonMargin;
  const GradientButton({super.key, required this.onPressed, required this.text, required this.buttonMargin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(buttonMargin),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [
          Pallete.gradient1,
          Pallete.gradient2,
        ],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(300, 55),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
