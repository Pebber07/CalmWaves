import "package:calmwaves_app/palette.dart";
import "package:calmwaves_app/widgets/activity_type.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        final gsUrl = userDoc['userinfo']['profileImage'] ?? '';
        if (gsUrl.startsWith('gs://')) {
          final ref = FirebaseStorage.instance.refFromURL(gsUrl);
          final downloadUrl = await ref.getDownloadURL();
          return downloadUrl;
        }
        return gsUrl;
      }
    } catch (e) {
      print("Error occured during downloading profile picture: $e");
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

                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black,
                        backgroundImage: snapshot.hasData &&
                                snapshot.data!.isNotEmpty
                            ? NetworkImage(snapshot.data!)
                            : const AssetImage(
                                    'assets/images/template_profile_pic.png')
                                as ImageProvider,
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
