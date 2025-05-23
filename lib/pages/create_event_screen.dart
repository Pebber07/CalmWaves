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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The screen where the users can create events for themselves.
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

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fillRequiredFields),
        ),
      );
      return;
    }

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

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.eventSuccessfullyCreated),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error} $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmation),
            content:
                Text(AppLocalizations.of(context)!.cancelEventCreationPrompt),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.yes),
              ),
            ],
          ),
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  AppLocalizations.of(context)!.createEvent,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                CalendarThemeCard(
                  themeCaption:
                      AppLocalizations.of(context)!.setThemeAndLeaveNotes,
                  themeDescription: AppLocalizations.of(context)!.enterTheme,
                  themeNote: AppLocalizations.of(context)!.note,
                  backgroundColor: Pallete.gradient2,
                  hintTextFirst: AppLocalizations.of(context)!.enterTheme,
                  hintTextSecond: AppLocalizations.of(context)!.enterComment,
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
                GradientButton(
                    onPressed: saveEvent,
                    text: AppLocalizations.of(context)!.saveDate,
                    buttonMargin: 20), // after 'Press' writes it out in a Toast.
                const SizedBox(
                  width: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
