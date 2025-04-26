import "package:flutter/material.dart";

class LanguageSelector extends StatefulWidget {
  final String initialLanguage; // "hu", "gb", "de"
  final Function(String) onLanguageSelected;

  const LanguageSelector(
      {super.key,
      required this.initialLanguage,
      required this.onLanguageSelected});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String selectedLanguage;

  final Map<String, String> languageNames = {
    "hu": "Magyar",
    "gb": "English",
    "de": "Deutsch",
  };

  final Map<String, String> flagAssets = {
    "hu": "assets/flags/hu.png",
    "gb": "assets/flags/gb.png",
    "de": "assets/flags/de.png",
  };

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLanguage,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: false,
          dropdownColor: Colors.lightBlue,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedLanguage = newValue;
              });
              widget.onLanguageSelected(newValue);
            }
          },
          items: languageNames.keys.map((languageCode) {
            return DropdownMenuItem<String>(
              value: languageCode,
              child: Container(
                color: selectedLanguage == languageCode
                    ? Colors.blue[500]
                    : Colors.blue[200],
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Image.asset(
                      flagAssets[languageCode]!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      languageNames[languageCode]!,
                      style: TextStyle(
                        fontWeight: selectedLanguage == languageCode
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
