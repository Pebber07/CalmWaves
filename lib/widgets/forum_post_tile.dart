import 'dart:ffi';

import 'package:flutter/material.dart';

class ForumPostTile extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String? profilePic;
  final String postId;
  final String userId;
  final int likeCount;
   
  const ForumPostTile({
    super.key,
    required this.title,
    required this.date,
    this.profilePic, required this.content, required this.postId, required this.userId, required this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/forum_post_detail',
          arguments: {
            'title': title,
            'content': content,
            'date': date,
            'profilePic': profilePic,
            'postId': postId,
            'userId': userId,
            'likeCount': likeCount,
          },
        );
      },
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: profilePic != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(profilePic!),
                    radius: 24,
                  )
                : const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 24,
                    child: Icon(Icons.person),
                  ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              date,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 18, color: Colors.redAccent),
                const SizedBox(width: 4),
                Text(likeCount.toString()),
              ],
            ),
          ),
          const Divider(color: Colors.lightBlue),
        ],
      ),
    );
  }
}
