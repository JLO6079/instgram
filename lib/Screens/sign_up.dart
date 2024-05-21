// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructor, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_app22/Screens/login.dart';
import 'package:insta_app22/Screens/widget/dialogMessage.dart';
import 'package:insta_app22/main.dart';
import 'package:insta_app22/models/usermodel.dart';
import 'package:overlay_progress_indicator/overlay_progress_indicator.dart';

import 'Bottombar.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isloading = false;

  final email = TextEditingController();
  final name = TextEditingController();
  final password = TextEditingController();

  void dispose() {
    email.dispose();
    name.dispose();
    password.dispose();

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

  void signup_method() async {
    setState(() {
      isloading = true;
    });

    try {
      dialogPrograss(context);
      await auth.createUserWithEmailAndPassword(
          email: email.text, password: password.text);
      if (pickedimage != null) {
        await auth.currentUser?.updatePhotoURL(pickedimage!.path);
      }
      UserModel user = UserModel(password.text, email.text, name.text,
          auth.currentUser!.photoURL ?? "", auth.currentUser!.uid, [], [], []);

      FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .set(user.converttomap());
      OverlayProgressIndicator.hide();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (route) => false,
      );

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
                  'تسجيل الدخول',
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
                        TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'please enter a vaild email';
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'email',
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: password,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 7) {
                              return 'please enter a vaild password';
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'password',
                            suffixIcon: Icon(Icons.visibility_off),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey)),
                          ),
                        )
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
                            signup_method();
                            //sign up
                          }
                        },
                        child: isloading == true
                            ? CircularProgressIndicator()
                            : Text('Sign up'))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return Login();
                      }));
                    },
                    child: Text('do you have an account?'))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
