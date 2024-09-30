import 'package:come_n_fix/components/input_text_field.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showErrorMessage = false;
  String errorMessage = '';

  void logUserIn() async {
    late BuildContext dialogContext;

    showDialog(
        context: context,
        builder: (context) {
          dialogContext = context;
          return LoadingAnimation();
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(dialogContext);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(dialogContext);
      print(e.code);
      if (e.code == 'invalid-credential') {
        setState(() {
          showErrorMessage = true;
          errorMessage = 'Incorrect Email or Password';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //logo
              Image(
                image: AssetImage('assets/images/BantuAjaLogo.png'),
                width: 150.0,
                height: 150.0,
              ),

              SizedBox(height: 50.0),

              //email textfield
              InputTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                paddingSize: 25.0,
              ),

              SizedBox(
                height: 20.0,
              ),

              // password textfield
              InputTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                paddingSize: 25.0,
              ),

              // errorMsg
              Visibility(
                visible: showErrorMessage,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 20.0,
              ),

              // button

              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: OutlinedButton(
                      onPressed: () => logUserIn(),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          side: BorderSide(
                              width: 2.0,
                              color: Color.fromARGB(255, 72, 71, 76)),
                          backgroundColor: Color.fromARGB(255, 212, 190, 169),),),
                ),
              ),

              SizedBox(height: 10.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  GestureDetector(
                    onTap: widget.showRegisterPage,
                    child: Text(
                      'Register Now',
                      style: TextStyle(
                          color: Color.fromARGB(255, 143, 90, 38),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
