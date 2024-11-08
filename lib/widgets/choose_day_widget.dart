import 'package:calmwaves_app/palette.dart';
import 'package:flutter/material.dart';

class ChooseDayWidget extends StatelessWidget {
  const ChooseDayWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Card(
        color: Pallete.gradient2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Choose a day",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "January 2023",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  bool isUpgradeDay =
                      index == 27; 
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Pallete.gradient1,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (isUpgradeDay)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            child: const Text(
                              "Nice",
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
