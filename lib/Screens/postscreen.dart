// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_app22/Screens/widget/dialogMessage.dart';
import 'package:overlay_progress_indicator/overlay_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../provider/user_provider.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  @override
  File? pickedimage;
  final des = TextEditingController();

  void selectimage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    var selected = File(image!.path);

    if (image != null) {
      setState(() {
        pickedimage = selected;
      });
    }
  }

  void upload_post() async {
    final userprovider = Provider.of<UserProvider>(context, listen: false);
    if (pickedimage != null) {
      try {
        dialogPrograss(context);
        final uuid = Uuid().v4();
        final rref = FirebaseStorage.instance
            .ref()
            .child('postsimage')
            .child(uuid + 'jpg');
        await rref.putFile(pickedimage!);
        final imageurl = await rref.getDownloadURL();
        FirebaseFirestore.instance.collection('posts').doc(uuid).set({
          'username': userprovider.getuser!.username,
          'uid': userprovider.getuser!.uid,
          'userimage': userprovider.getuser!.userimage,
          'imagepost': imageurl,
          'postid': uuid,
          'des': des.text,
          'likes': [],
          'date': Timestamp.now()
        });

        setState(() {
          pickedimage = null;
          des.text = '';
        });
        OverlayProgressIndicator.hide();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('done ')));
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("pkease select file")));
    }
  }

  Widget build(BuildContext context) {
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
                      'New post',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                        onPressed: () {
                          upload_post();
                        },
                        child: Text('Next ', style: TextStyle(fontSize: 22)))
                  ],
                ),
                pickedimage == null
                    ? SizedBox(
                        height: h * 0.4,
                      )
                    : Image.file(
                        pickedimage!,
                        height: h * 0.4,
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                IconButton(
                    onPressed: () {
                      selectimage();
                    },
                    icon: Icon(
                      Icons.upload,
                      size: 28,
                    )),
                TextField(
                  controller: des,
                  maxLines: 15,
                  decoration: InputDecoration(
                      hintText: 'add comment ',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black))),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
