import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/calendar_theme_card.dart";
import "package:calmwaves_app/widgets/choose_day_widget.dart";
import "package:calmwaves_app/widgets/choose_time_widget.dart";
import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:flutter/material.dart";

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
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
              CalendarThemeCard(themeCaption: "Set theme and leave notes", themeDescription: "Enter theme", themeNote: "Note", backgroundColor: Pallete.gradient2, hintText: "Enter theme", controller: TextEditingController(text: "Dummy text")),
              const ChooseDayWidget(),
              const ChooseTimeWidget(),
              Row(
                children: [
                  const SizedBox(width: 50,),
                  GradientButton(onPressed: () {}, text: "Save date", buttonWidth: 100),
                  const SizedBox(width: 50,),
                  GradientButton(onPressed: () {}, text: "Save date and continue", buttonWidth: 100),  
                ],
              ),  
            ],
          ),
        ),
      ),
    );
  }
}
