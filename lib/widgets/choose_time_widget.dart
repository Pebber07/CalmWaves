import 'dart:async';

import 'package:calmwaves_app/palette.dart';
import 'package:flutter/material.dart';

class ChooseTimeWidget extends StatefulWidget {
  final Function(TimeOfDay) onTimeChanged;
  const ChooseTimeWidget({super.key, required this.onTimeChanged});

  @override
  State<ChooseTimeWidget> createState() => _ChooseTimeWidgetState();
}

class _ChooseTimeWidgetState extends State<ChooseTimeWidget> {
  late TimeOfDay selectedTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    selectedTime = TimeOfDay.now();
    _startTimeUpdater();
  }

  void _startTimeUpdater() {
    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      setState(() {
        selectedTime = TimeOfDay.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );

        if (newTime != null) {
          setState(() {
            selectedTime = newTime;
          });
          widget.onTimeChanged(newTime);
        }
      },
      child: Container(
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
                    Icon(Icons.access_time, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Choose a time",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Selected time: ${TimeOfDay.now().format(context)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
