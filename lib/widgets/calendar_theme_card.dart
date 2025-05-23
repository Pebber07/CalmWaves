import "package:calmwaves_app/palette.dart";
import "package:flutter/material.dart";

/// Card where the user enter the events title, and description.
class CalendarThemeCard extends StatelessWidget {
  final String themeCaption;
  final String themeDescription;
  final String themeNote;
  final Color backgroundColor;
  final String hintTextFirst;
  final String hintTextSecond;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  const CalendarThemeCard(
      {super.key,
      required this.themeCaption,
      required this.themeDescription,
      required this.themeNote,
      required this.backgroundColor,
      required this.titleController,
      required this.descriptionController,
      required this.hintTextFirst,
      required this.hintTextSecond});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            themeCaption,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: titleController,
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
                  color: Pallete.borderColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hintTextFirst,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: descriptionController,
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
                  color: Pallete.borderColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hintTextSecond,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
