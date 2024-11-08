import 'package:calmwaves_app/palette.dart';
import 'package:flutter/material.dart';

class ChooseTimeWidget extends StatefulWidget {
  const ChooseTimeWidget({super.key});

  @override
  State<ChooseTimeWidget> createState() => _ChooseTimeWidgetState();
}

class _ChooseTimeWidgetState extends State<ChooseTimeWidget> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(), // Adjust the theme as needed
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

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
              Center(
                child: ElevatedButton(
                  onPressed: () => _selectTime(context),
                  style: ElevatedButton.styleFrom(
                      // Todo
                      ),
                  child: Text(
                    selectedTime.format(context),
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
