import "package:calmwaves_app/palette.dart";
import "package:flutter/material.dart";

class CalendarThemeCard extends StatelessWidget {
  final String themeCaption;
  final String themeDescription;
  final String themeNote;
  final Color backgroundColor;
  final String hintText;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  const CalendarThemeCard(
      {super.key,
      required this.themeCaption,
      required this.themeDescription,
      required this.themeNote,
      required this.backgroundColor,
      required this.hintText,
      required this.titleController,
      required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
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
              hintText: hintText,
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
              hintText: hintText,
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
