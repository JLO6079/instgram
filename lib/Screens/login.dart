// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Screens/widget/dialogMessage.dart';
import 'package:insta_app22/main.dart';
import 'package:overlay_progress_indicator/overlay_progress_indicator.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _SignupState();
}

class _SignupState extends State<Login> {
  bool isloading = false;

  final email = TextEditingController();
  final password = TextEditingController();

  void dispose() {
    email.dispose();

    password.dispose();

    super.dispose();
  }

  final formkey = GlobalKey<FormState>();

  void login_method() async {
    setState(() {
      isloading = true;
    });

    try {
      dialogPrograss(context);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
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
                  'insta app',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  height: h * 0.05,
                ),
                Form(
                    key: formkey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: h * 0.03,
                        ),
                        TextFormField(
                          controller: email,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'please enter a vaild email';
                            }
                            return null;
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
                            return null;
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
                            login_method();
                            //login
                          }
                        },
                        child: isloading == true
                            ? CircularProgressIndicator()
                            : Text('Login'))),
                TextButton(onPressed: () {}, child: Text('Sign up'))
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
