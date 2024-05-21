// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructor, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_app22/Firebase/firestore.dart';
import 'package:overlay_progress_indicator/overlay_progress_indicator.dart';
import 'package:insta_app22/Screens/widget/dialogMessage.dart';
import 'package:insta_app22/main.dart';
import 'package:insta_app22/models/usermodel.dart';
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;
  const EditProfile({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isloading = false;

  final name = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name.text = widget.user.username;
  }

  void dispose() {
    name.dispose();

    super.dispose();
  }

  final formkey = GlobalKey<FormState>();
  File? pickedimage;

  void selectimage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    var selected = File(image!.path);

    if (image != null) {
      setState(() {
        pickedimage = selected;
      });
    }
  }

  void edit_method() async {
    setState(() {
      isloading = true;
    });

    try {
      String imagUrl = auth.currentUser!.photoURL ?? "";
      dialogPrograss(context);
      if (pickedimage != null) {
        final uuid = Uuid().v4();
        final rref = FirebaseStorage.instance
            .ref()
            .child('postsimage')
            .child(uuid + 'jpg');
        await rref.putFile(pickedimage!);
        imagUrl = await rref.getDownloadURL();

        await auth.currentUser?.updatePhotoURL(pickedimage!.path);
      }
      UserModel user = UserModel(
          "", "", name.text, imagUrl, auth.currentUser!.uid, [], [], []);
      await FirestoreMethod().updateUser(userMap: user.converttomap());
      OverlayProgressIndicator.hide();

      setState(() {
        isloading = false;
      });
    } on FirebaseException catch (error) {
      OverlayProgressIndicator.hide();

      setState(() {
        isloading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(children: [
                SizedBox(
                  height: h * 0.1,
                ),
                Text(
                  'Update User',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: h * 0.05,
                ),
                Stack(
                  children: [
                    pickedimage != null
                        ? CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: FileImage(pickedimage!),
                          )
                        : CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                                'https://www.chartattack.com/wp-content/uploads/2019/07/insta.jpg'),
                          ),
                    Positioned(
                        top: 25,
                        left: 25,
                        child: IconButton(
                            onPressed: () {
                              selectimage();
                            },
                            icon: Icon(
                              Icons.add,
                              color: Colors.grey,
                            )))
                  ],
                ),
                SizedBox(
                  height: h * 0.05,
                ),
                Form(
                    key: formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'please enter your name';
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'name',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                      ],
                    )),
                SizedBox(
                  height: h * 0.05,
                ),
                SizedBox(
                    height: h * 0.05,
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          formkey.currentState!.save();
                          if (formkey.currentState!.validate()) {
                            edit_method();
                            //sign up
                          }
                        },
                        child: isloading == true
                            ? CircularProgressIndicator()
                            : Text('Edit Profile'))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
