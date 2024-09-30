import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:come_n_fix/components/input_text_field.dart';
import 'package:come_n_fix/components/loading_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  bool showErrorMessage = false;
  String errorMessage = '';

  Future<User?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }

  void RegisterUserIn(String role) async {
    late BuildContext dialogContext;

    showDialog(
        context: context,
        builder: (context) {
          dialogContext = context;
          return LoadingAnimation();
        });

    User? user = await registerWithEmailAndPassword(
        emailController.text.trim(), passwordController.text.trim());

    if (user != null) {
      Navigator.pop(dialogContext);
      addUserDetails(
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
          role,
          user.uid);
    } else {
      Navigator.pop(dialogContext);
    }
  }

  Future addUserDetails(String username, String role, String uid) async {
    if (role == 'Customer') {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': role,
        'username': username,
        'gender': '-',
        'profile url':
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png',
        'phone number': '-',
        'address': '-',
        'location': '-',
      });
    } else {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'role': 'Provider',
        'username': username,
        'gender': '-',
        'profile url':
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png',
        'phone number': '-',
        'description': '-',
        'location': '-',
        'services': [],
        'rating': 0.0,
        'rate amount': 0,
        'address': '-',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 130,
              ),
              //logo
              Image(
                image: AssetImage('assets/images/BantuAjaLogo.png'),
                width: 150.0,
                height: 150.0,
              ),

              SizedBox(height: 50.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InputTextField(
                        controller: firstNameController,
                        hintText: 'First Name',
                        obscureText: false,
                        paddingSize: 0,
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: InputTextField(
                        controller: lastNameController,
                        hintText: 'Last Name',
                        obscureText: false,
                        paddingSize: 0,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 20.0,
              ),

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
                      onPressed: () => RegisterUserIn('Customer'),
                      child: Text(
                        'Register as User',
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
                            width: 2.0, color: Color.fromARGB(255, 72, 71, 76)),
                        backgroundColor: Color.fromARGB(255, 124, 102, 89),
                      )),
                ),
              ),

              SizedBox(
                height: 10.0,
              ),

              // button

              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: OutlinedButton(
                      onPressed: () => RegisterUserIn('Provider'),
                      child: Text(
                        'Register as Fixer',
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
                            width: 2.0, color: Color.fromARGB(255, 72, 71, 76)),
                        backgroundColor: Color.fromARGB(255, 212, 190, 169),
                      )),
                ),
              ),

              SizedBox(
                height: 10.0,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  GestureDetector(
                    onTap: widget.showLoginPage,
                    child: Text(
                      'Login Now',
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
