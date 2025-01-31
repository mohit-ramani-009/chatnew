import 'dart:async';

import 'package:chatnew/firebase_options.dart';
import 'package:chatnew/screens/chat_screen.dart';
import 'package:chatnew/screens/home_screen.dart';
import 'package:chatnew/screens/login_screen.dart';
import 'package:chatnew/screens/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      // home: LoginPage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: FirebaseAuth.instance.currentUser?.uid != null ? "home_page" : "/",
      getPages: [
        GetPage(
          name: "/",
          page: () => LoginScreen(),
        ),
        GetPage(
          name: "/home_page",
          page: () => HomeScreen(),
        ),
        GetPage(
          name: "/users_page",
          page: () => UserScreen(),
        ),
        GetPage(
          name: "/chat",
          page: () => ChatScreen(),
        )
      ],
    );
  }
}