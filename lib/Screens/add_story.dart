// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../Firebase/firestore.dart';

import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../provider/user_provider.dart';

class AddStory extends StatefulWidget {
  const AddStory({super.key});

  @override
  State<AddStory> createState() => _AddPostState();
}

class _AddPostState extends State<AddStory> {
  late VideoPlayerController videcontroller;

  File? pickedimage;
  File? pickedvideo;
  final des = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videcontroller = VideoPlayerController.file(File(''));
  }

  void selectimage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    var selected = File(image!.path);

    if (image != null) {
      setState(() {
        pickedimage = selected;
        pickedvideo = null;
        videcontroller.pause();
      });
    }
  }

  void selectvideo() async {
    var video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    var selected = File(video!.path);

    if (video != null) {
      setState(() {
        pickedvideo = selected;
        pickedimage = null;
        videcontroller = VideoPlayerController.file(pickedvideo!);
        videcontroller.initialize();
        videcontroller.play();
      });
    }
  }

  Widget build(BuildContext context) {
    final userprovider = Provider.of<UserProvider>(context);

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            pickedimage = null;
                            des.text = '';
                          });
                        },
                        icon: Icon(
                          Icons.cancel,
                          size: 26,
                        )),
                    Text(
                      'New Story',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                        onPressed: () async {
                          if (pickedimage != null || pickedvideo != null) {
                            String uid = FirebaseAuth.instance.currentUser!.uid;
                            String uuid = Uuid().v4();
                            var media =
                                pickedvideo != null ? pickedvideo : pickedimage;

                            final rref = FirebaseStorage.instance
                                .ref()
                                .child('usersstories')
                                .child(uuid + 'jpg');
                            await rref.putFile(media!);
                            final content = await rref.getDownloadURL();

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(uid)
                                .update({
                              'stories': FieldValue.arrayUnion([
                                {
                                  'uid': uid,
                                  'storyid': uuid,
                                  'content': content,
                                  'type':
                                      pickedvideo != null ? 'video' : 'image',
                                  'date': Timestamp.now(),
                                  'viweies': []
                                }
                              ])
                            });

                            userprovider.fetchuser(userid: uid);
                          }

                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('done')));

                          setState(() {
                            pickedimage = null;
                            pickedvideo = null;
                          });
                        },
                        child: Text('Next ', style: TextStyle(fontSize: 22))),
                  ],
                ),
                pickedimage != null
                    ? Image.file(
                        pickedimage!,
                        height: h * 0.4,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      )
                    : pickedvideo != null
                        ? Container(
                            width: double.infinity,
                            height: h * 0.5,
                            child: VideoPlayer(videcontroller),
                          )
                        : SizedBox(height: h * 0.5),
                PopupMenuButton<String>(
                  icon: Center(
                      child: Icon(
                    Icons.upload,
                    size: 30,
                  )),
                  onSelected: (String choice) {
                    // اكتب الكود الذي يتم تنفيذه عند اختيار خيار من القائمة
                    if (choice == 'option1') {
                      selectvideo();

                      // اختر الخيار الأول
                    } else if (choice == 'option2') {
                      selectimage();

                      // اختر الخيار الثاني
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'option1',
                        child: Text('select video'),
                      ),
                      PopupMenuItem<String>(
                        value: 'option2',
                        child: Text('select image'),
                      ),
                    ];
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
