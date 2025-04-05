import "package:calmwaves_app/widgets/custom_app_bar.dart";
import "package:calmwaves_app/widgets/custom_drawer.dart";
import "package:calmwaves_app/widgets/forum_post_tile.dart";
import "package:flutter/material.dart";

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.forum,
              ),
              label: "Fórum"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Kezdőlap"),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Események",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Fórum",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Új bejegyzés', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView(
                children: const [
                  // Create ForumPostTile widget and fill with example content.
                  ForumPostTile(
                    title: "Example Title",
                    category: "Example Category",
                    categoryColor: Colors.lightBlue,
                    date: "Example Date",
                    profilePic: "Example Profile Picture",
                  ), // Lter convert to time datatype
                  // ...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
