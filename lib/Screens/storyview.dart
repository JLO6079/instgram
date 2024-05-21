import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Firebase/firestore.dart';
import 'package:provider/provider.dart';

import 'package:story_view/story_view.dart';

import '../provider/user_provider.dart';

class Story extends StatefulWidget {
  final List stories;
  const Story({super.key, required this.stories});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  Map storyy = {};

  final storycontroller = StoryController();
  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            controller: storycontroller,
            storyItems: widget.stories.map((story) {
              storyy = story;

              Duration dd = DateTime.now().difference(storyy['date'].toDate());
              if (dd.inMinutes >= 1) {
                FirestoreMethod().delete_story(story: storyy);
                userprovider.delete_storyy(story: storyy);
                userprovider.fetchuser(userid: storyy['uid']);
              }
              if (story['type'] == 'image') {
                return StoryItem.pageImage(
                  url: story['content'],
                  controller: storycontroller,
                );
              }
              if (story['type'] == 'video') {
                return StoryItem.pageVideo(story['content'],
                    controller: storycontroller);
              }
            }).toList(),
            repeat: false,
            onComplete: () {},
            onStoryShow: (story) async {
              //
            },
          ),
          Positioned(
              top: 45,
              left: 20,
              child: IconButton(
                  onPressed: () {
                    if (storyy['uid'] ==
                        FirebaseAuth.instance.currentUser!.uid) {
                      FirestoreMethod().delete_story(story: storyy);
                      userprovider.delete_storyy(story: storyy);
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.remove)))
        ],
      ),
    );
  }
}
