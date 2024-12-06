import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/activity_type.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class EventCard extends StatelessWidget {
  final String author;
  final Timestamp createTime;
  final String description;
  final String title;
  final String time;
  final DateTime eventDate;
  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.createTime,
    required this.time,
    required this.eventDate,
  });

  Future<String> _getProfileImage(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final gsUrl = userDoc['userinfo']['profilePicture'] ?? '';
        if (gsUrl.startsWith('gs://')) {
          final filePath = gsUrl.replaceFirst(
              'gs://calmwaves-c6569.firebasestorage.app', '');
          final downloadUrl =
              await FirebaseStorage.instance.ref(filePath).getDownloadURL();
          return downloadUrl;
        }
        return gsUrl;
      }
    } catch (e) {
      print("Hiba történt a profilkép lekérésekor: $e");
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(eventDate);
    final timeParts =
        time.split(':'); // 13:22 idő formátum miatt kell összeszerkeszteni.
    final eventTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    String formattedTime = DateFormat('HH:mm').format(eventTime);

    return Card(
      color: Pallete.gradient1,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                FutureBuilder<String>(
                    future: _getProfileImage(author),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      final profileImage =
                          snapshot.hasData && snapshot.data!.isNotEmpty
                              ? snapshot.data!
                              : 'assets/images/template_profile_pic.png';

                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        backgroundImage: NetworkImage(profileImage),
                      );
                    }),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
