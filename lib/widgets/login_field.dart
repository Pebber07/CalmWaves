import "package:flutter/material.dart";
import "package:calmwaves_app/palette.dart";

class LoginField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller; // I'm not sure if this is correct
  final String buttonLabelText;
  final bool hideText;
  const LoginField({super.key, required this.hintText, required this.controller, required this.buttonLabelText, required this.hideText});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: hideText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Pallete.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Pallete.gradient2,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          labelText: buttonLabelText ,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: hintText,
        ),
      ),
    );
  }
}