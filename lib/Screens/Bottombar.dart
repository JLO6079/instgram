// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/Screens/postscreen.dart';
import 'package:insta_app22/Screens/profile.dart';
import 'package:insta_app22/Screens/search.dart';

import 'Home.dart';

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  int selctead = 0;

  void selectepage(int index) {
    setState(() {
      selctead = index;
    });
  }

  final List pagelist = [
    Home(),
    SearchScreen(),
    AddPost(),
    Profile(
      userid: FirebaseAuth.instance.currentUser!.uid,
    )
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pagelist[selctead],
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: Colors.white,
          currentIndex: selctead,
          onTap: selectepage,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 26,
                  color: Colors.white,
                ),
                label: 'HOME',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  size: 26,
                  color: Colors.white,
                ),
                label: 'search',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.add,
                  size: 26,
                  color: Colors.white,
                ),
                label: 'add post',
                backgroundColor: Colors.black),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 26,
                  color: Colors.white,
                ),
                label: 'profile',
                backgroundColor: Colors.black)
          ]),
    );
  }
}
