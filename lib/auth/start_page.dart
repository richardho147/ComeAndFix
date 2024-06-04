import "package:come_n_fix/auth/auth_page.dart";
import "package:come_n_fix/pages/main/main_page.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            return MainPage();
          }
          else{
            return AuthPage();
          }
        }
      )
    );
  }
}