// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Firebase/firestore.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../provider/user_provider.dart';

class Comment extends StatefulWidget {
  final String postid;

  const Comment({
    super.key,
    required this.postid,
  });

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final comment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Comment ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postid)
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return CircularProgressIndicator();
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> commentMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        return ListTile(
                          title: Text(commentMap['name']),
                          subtitle: Text(commentMap['comment']),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage(commentMap['userimage']),
                          ),
                          trailing: IconButton(
                              onPressed: () {}, icon: Icon(Icons.favorite)),
                        );
                      });
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(userprovider.getuser!.userimage),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: comment,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              onPressed: () {
                                if (comment.text != '') {
                                  FirestoreMethod().addcomment(
                                      comment: comment.text,
                                      userimage:
                                          userprovider.getuser!.userimage,
                                      uid: userprovider.getuser!.uid,
                                      postid: widget.postid,
                                      name: userprovider.getuser!.username);
                                }
                                comment.text = '';
                              },
                              icon: Icon(Icons.send)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue)),
                          hintText: 'add comment',
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.white))),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
