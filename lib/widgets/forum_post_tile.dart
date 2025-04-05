import 'package:flutter/material.dart';

class ForumPostTile extends StatelessWidget {
  final String title;
  final String category;
  final Color categoryColor;
  final String date;
  final String? profilePic;

  const ForumPostTile({
    super.key,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.date,
    this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.square,
                    color: categoryColor,
                    size: 12,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(category),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: profilePic != null
              ? const CircleAvatar(
                  backgroundImage: NetworkImage('url'), // Todo
                  radius: 20,
                )
              : null,
        ),
        const Divider(
          color: Colors.lightBlue,
        ),
      ],
    );
  }
}
