import 'package:flutter/material.dart';
import 'package:insta_app22/Firebase/firestore.dart';
import 'package:insta_app22/models/usermodel.dart';

class UserProvider with ChangeNotifier {
  UserModel? userdata;
  UserModel? get getuser {
    return userdata;
  }

  void fetchuser({required userid}) async {
    UserModel user = await FirestoreMethod().userdetalis(userid: userid);
    userdata = user;
    notifyListeners();
  }

  void increase_followers() {
    getuser!.followers.length++;
    notifyListeners();
  }

  void decrease_followers() {
    getuser!.followers.length--;
    notifyListeners();
  }

  void delete_storyy({required Map story}) {
    userdata!.stories.removeWhere((element) {
      return element == story;
    });
    notifyListeners();
  }
}
