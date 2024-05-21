// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Firebase/firestore.dart';
import 'package:insta_app22/Screens/comment.dart';
import 'package:insta_app22/Screens/widget/loadImages.dart';
import 'package:intl/intl.dart';

class Postwidget extends StatelessWidget {
  final Map<String, dynamic> postmap;
  const Postwidget({super.key, required this.postmap});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                circulCatchImageNetwork(postmap['userimage'], w / 55),

                SizedBox(
                  width: w * 0.05,
                ),
                Text(
                  postmap['username'],
                  style: TextStyle(fontSize: 22),
                ),
                Spacer(),
                // IconButton(
                //     onPressed: () {
                //       FirestoreMethod().delete_post(postmap: postmap);
                //     },
                //     icon: Icon(Icons.remove))
              ],
            ),
          ),
          Image.network(
            postmap['imagepost'],
            height: 0.5 * h,
            width: double.infinity,
            fit: BoxFit.fill,
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    FirestoreMethod().addpost(postmap: postmap);
                  },
                  icon: Icon(
                    Icons.favorite,
                    color: postmap['likes']
                            .contains(FirebaseAuth.instance.currentUser!.uid)
                        ? Colors.red
                        : Colors.white,
                  )),
              IconButton(onPressed: () {}, icon: Icon(Icons.comment))
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${postmap['likes'].length}likes ',
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              postmap['des'],
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return Comment(
                    postid: postmap['postid'],
                  );
                }));
              },
              child: Text(
                'Add comment ',
                style: TextStyle(color: Colors.grey),
              )),
          Text(DateFormat.MMMEd().format(postmap['date'].toDate()),
              style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
