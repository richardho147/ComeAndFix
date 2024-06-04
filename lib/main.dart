import 'package:come_n_fix/auth/start_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StartPage(),
    routes: {
      '/start': (context) => StartPage(),
    },
  ));
}

// logo 22, title 20, quite big title, considered a title but not 16, normal 14, incitation 11
// Color.fromARGB(255, 124, 102, 89) coklat abu
// Color.fromARGB(255, 211, 212, 214) abu
// Color.fromARGB(255, 212, 190, 169) colkat terang
// Color.fromARGB(255, 72, 71, 76) abu gelap
// Color.fromARGB(255, 143, 90, 38) coklat coklat

// username
// gender
// location
// profile picture
// telephone number
// description - worker
// title - worker
// rating - worker

// AIzaSyDggbKl8W70Z0Jam3urxJzpyza3TETuiZU