// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Firebase/firestore.dart';
import 'package:insta_app22/Screens/add_story.dart';
import 'package:insta_app22/Screens/editProfile.dart';

import 'package:insta_app22/Screens/sign_up.dart';
import 'package:insta_app22/Screens/storyview.dart';
import 'package:insta_app22/Screens/widget/dialogMessage.dart';
import 'package:insta_app22/Screens/widget/loadImages.dart';
import 'package:insta_app22/main.dart';

import 'package:insta_app22/provider/user_provider.dart';
import 'package:overlay_progress_indicator/overlay_progress_indicator.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final String userid;
  const Profile({super.key, required this.userid});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late List following;
  late bool infollwing;
  bool isloading = false;
  late int postcount;

  void fetch_current_user() async {
    setState(() {
      isloading = true;
    });

    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    var snap = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.userid)
        .get();

    postcount = snap.docs.length;

    following = snapshot.data()!['following'];

    setState(() {
      infollwing = following.contains(widget.userid);

      isloading = false;
    });
  }

  List<String> selectedItem = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? dataPost;
  bool isLoading = false;
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: widget.userid)
        .get();
    setState(() {
      dataPost = data.docs;
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    userprovider.fetchuser(userid: widget.userid);

    fetch_current_user();
    fetchPosts();
  }

  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);

    double w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            if (widget.userid == FirebaseAuth.instance.currentUser!.uid)
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () async {
                  dialogPrograss(context);
                  if (selectedItem.isEmpty) {
                    await FirestoreMethod().delete_user(userId: widget.userid);
                    await auth.currentUser?.delete();

                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return Signup();
                    }));
                  } else {
                    selectedItem.forEach((element) async {
                      var index = dataPost?.indexWhere((e) => e.id == element);

                      if (index != null && index > -1) {
                        await FirestoreMethod()
                            .delete_post(postmap: dataPost![index].data());
                        dataPost?.removeAt(index);
                        selectedItem.remove(element);
                        setState(() {});
                      }
                    });
                  }
                  OverlayProgressIndicator.hide();

                  // unfollow
                },
              ),
            if (widget.userid == FirebaseAuth.instance.currentUser!.uid)
              IconButton(
                  onPressed: () async {
                    dialogPrograss(context);
                    await auth.signOut();
                    OverlayProgressIndicator.hide();
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return Signup();
                    }));
                  },
                  icon: Icon(Icons.logout)),
            IconButton(onPressed: () async {}, icon: Icon(Icons.menu_rounded)),
          ],
          title: Text(userprovider.getuser!.username),
        ),
        body: isloading == true
            ? Center(child: CircularProgressIndicator())
            : Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                userprovider.getuser!.stories.isNotEmpty
                                    ? Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                        return Story(
                                            stories:
                                                userprovider.getuser!.stories);
                                      }))
                                    : Text('');
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      circulCatchImageNetwork(
                                          userprovider.getuser!.userimage,
                                          w / 75),
                                      Positioned(
                                          left: 35,
                                          top: 30,
                                          child: IconButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return AddStory();
                                                }));
                                              },
                                              icon: widget.userid ==
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                  ? Icon(
                                                      Icons.add_circle,
                                                      color: Colors.white,
                                                      size: 30,
                                                    )
                                                  : Text('')))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(userprovider.getuser!.username,
                                      style: TextStyle(
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  postcount.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'posts',
                                  style: TextStyle(fontSize: 18),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${userprovider.getuser!.followers.length}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Followers',
                                  style: TextStyle(fontSize: 18),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${userprovider.getuser!.following.length}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  'Following',
                                  style: TextStyle(fontSize: 18),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: infollwing == true
                                      ? Colors.red
                                      : Colors.grey[900]),
                              child: widget.userid ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? Text('Edit profile')
                                  : infollwing == true
                                      ? Text('unfollow')
                                      : Text('follow'),
                              onPressed: () {
                                if (widget.userid ==
                                    FirebaseAuth.instance.currentUser!.uid) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EditProfile(
                                        user: userprovider.getuser!),
                                  ));
                                } else {
                                  if (infollwing == true) {
                                    FirestoreMethod()
                                        .unfollow_user(userid: widget.userid);
                                    userprovider.decrease_followers();

                                    setState(() {
                                      infollwing = false;
                                    });
                                  } else {
                                    setState(() {
                                      userprovider.increase_followers();
                                      infollwing = true;
                                    });

                                    FirestoreMethod()
                                        .follow_user(userid: widget.userid);
                                  }
                                }
                              },
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 3,
                        ),
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : dataPost == null || dataPost!.isEmpty
                                ? Center(child: Text("not found data"))
                                : GridView.count(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 1,
                                    childAspectRatio: 3.2 / 3,
                                    crossAxisCount: 2,
                                    children: List.generate(dataPost!.length,
                                        (index) {
                                      return Container(
                                        color: selectedItem
                                                .contains(dataPost![index].id)
                                            ? Colors.blue.withOpacity(0.5)
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: InkWell(
                                            onTap: () {
                                              if (selectedItem.isNotEmpty) {
                                                if (!selectedItem.contains(
                                                    dataPost![index].id)) {
                                                  setState(() {
                                                    selectedItem.add(
                                                        dataPost![index].id);
                                                  });
                                                } else {
                                                  setState(() {
                                                    selectedItem.remove(
                                                        dataPost![index].id);
                                                  });
                                                }
                                              }
                                            },
                                            onLongPress: () {
                                              if (selectedItem.isEmpty) {
                                                setState(() {
                                                  selectedItem
                                                      .add(dataPost![index].id);
                                                });
                                              }
                                            },
                                            child: netWorkImage(
                                              dataPost![index]['imagepost'],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                      ]),
                );
              }),
      ),
    );
  }
}
