import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/feeling_card.dart";
import "package:calmwaves_app/widgets/gradient_button.dart";
import "package:flutter/material.dart";

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Text(
                "How are you today?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  FeelingCard(
                    caption: "Angry",
                    cardColor: Colors.red,
                    emoji: "\ud83d\ude20",
                    cardWidth: 100,
                  ),
                  FeelingCard(
                    caption: "Sad",
                    cardColor: Colors.orange,
                    emoji: "\ud83d\ude41",
                    cardWidth: 100,
                  ),
                  FeelingCard(
                    caption: "Meh",
                    cardColor: Colors.yellow,
                    emoji: "\ud83d\ude10",
                    cardWidth: 100,
                  ),
                ],
              ), // I could create an Enum for this.
              Row(
                children: [
                  FeelingCard(
                    caption: "Happy",
                    cardColor: Colors.lightBlue,
                    emoji: "\ud83d\ude0a",
                    cardWidth: 100,
                  ),
                  FeelingCard(
                    caption: "Exited",
                    cardColor: Colors.cyan,
                    emoji: "\ud83d\ude04",
                    cardWidth: 100,
                  ),
                  FeelingCard(
                    caption: "Loved",
                    cardColor: Colors.purple,
                    emoji: "\ud83d\ude0d",
                    cardWidth: 100,
                  ),
                ],
              ),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Describe your mood...",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Mood History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              FeelingCard(
                  caption: "2024/11/05",
                  cardColor: Colors.grey,
                  emoji: "Happy",
                  cardWidth: 300),
              FeelingCard(
                  caption: "2024/11/06",
                  cardColor: Colors.grey,
                  emoji: "Sad",
                  cardWidth: 300),
              FeelingCard(
                  caption: "2024/11/07",
                  cardColor: Colors.grey,
                  emoji: "Meh",
                  cardWidth: 300),
              SizedBox(
                height: 10,
              ),
              Text(
                "Mood Trends",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              // Todo: Create a diagram here.
              //GradientButton(onPressed: (){print("Requested Peronalized Advice");}, text: "Request Personalized Advice"),
            ],
          ),
        ),
      ),
    );
  }
}
