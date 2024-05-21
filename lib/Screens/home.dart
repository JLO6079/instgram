// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Screens/storyview.dart';
import 'package:insta_app22/Screens/widget/loadImages.dart';

import 'package:insta_app22/Screens/widget/post.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import 'chat ui/Chats.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    userprovider.fetchuser(userid: FirebaseAuth.instance.currentUser!.uid);
  }

  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Instagram ',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return Chats();
                          }));
                        },
                        icon: Icon(Icons.message))
                  ],
                ),
                SizedBox(
                  height: h * 0.2,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('stories', isNotEqualTo: [])
                          .where('followers',
                              arrayContains:
                                  FirebaseAuth.instance.currentUser!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.data == null ||
                            snapshot.data!.docs.isEmpty) {
                          return Text(
                            "not found data",
                            style: TextStyle(color: Colors.white),
                          );
                        }
                        return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> usermap =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;

                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return Story(
                                      stories: usermap['stories'],
                                    );
                                  }));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      netWorkImage(usermap['userimage']),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(usermap['username'])
                                    ],
                                  ),
                                ),
                              );
                            });
                      }),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'error',
                          style: TextStyle(color: Colors.white),
                        );
                      }
                      if (snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return Text(
                          "not found data",
                          style: TextStyle(color: Colors.white),
                        );
                      }
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> postmap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return Postwidget(postmap: postmap);
                          });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
