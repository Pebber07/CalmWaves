import "package:calmwaves_app/palette.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

class SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final double horizontalPaddding;
  final VoidCallback buttonOnPressed;
  const SocialButton(
      {super.key,
      required this.iconPath,
      required this.label,
      this.horizontalPaddding = 50,
      required this.buttonOnPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: buttonOnPressed,
      icon: SvgPicture.asset(
        iconPath,
        width: 25,
        color: Pallete.whiteColor,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Pallete.whiteColor,
          fontSize: 17,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: Pallete.gradient2,
        padding:
            EdgeInsets.symmetric(vertical: 25, horizontal: horizontalPaddding),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Pallete.borderColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
