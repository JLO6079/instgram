import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:insta_app22/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'Screens/Bottombar.dart';
import 'Screens/sign_up.dart';

late final FirebaseApp app;
late final FirebaseAuth auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  app = await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyAgu3wEw2HiKt7tswH9mk7Nzx4DVoGoCwA",
    appId: "1:674611003922:android:08e9dbbe4e5267f2964ecb",
    messagingSenderId: "674611003922",
    projectId: "lolinsta",
    storageBucket: "lolinsta.appspot.com",
  ));
  auth = FirebaseAuth.instanceFor(app: app);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          return UserProvider();
        })
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'lol',
        theme: ThemeData.dark().copyWith(
            textTheme: const TextTheme(
                bodyText1: TextStyle(fontFamily: 'Poppins'),
                bodyText2: TextStyle(fontFamily: 'Poppins')),
            scaffoldBackgroundColor: Colors.black),
            
        home: StreamBuilder<User?>(
            stream: auth.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const Bottombar();
              } else {
                return const Signup();
              }
            }),
      ),
    );
  }
}
