import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/calendar_theme_card.dart";
import "package:calmwaves_app/widgets/choose_day_widget.dart";
import "package:calmwaves_app/widgets/choose_time_widget.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDay = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  void saveEvent() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final day = DateFormat('yyyy-MM-dd').format(selectedDay);
    final time = selectedTime.format(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance.collection('events').add({
          'title': title,
          'description': description,
          'day': day,
          'time': time,
          'author': userId,
          'createTime': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Az esemény sikeresen létrejött!')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hiba: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Text(
                "Create event",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              CalendarThemeCard(
                themeCaption: "Set theme and leave notes",
                themeDescription: "Enter theme",
                themeNote: "Note",
                backgroundColor: Pallete.gradient2,
                hintText: "Enter theme",
                titleController: titleController,
                descriptionController: descriptionController,
              ),
              ChooseDayWidget(
                onDateChanged: (DateTime newDate) {
                  setState(() {
                    selectedDay = newDate;
                  });
                },
              ),
              ChooseTimeWidget(
                onTimeChanged: (TimeOfDay newTime) {
                  setState(() {
                    selectedTime = newTime;
                  });
                },
              ), // needs an argument
              const SizedBox(
                width: 50,
              ),
              GradientButton(
                  onPressed: saveEvent,
                  text: "Save date",
                  buttonMargin: 20), //Press után kiírja toastba a dolgokat.
              const SizedBox(
                width: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
