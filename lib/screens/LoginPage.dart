import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mashov/screens/AdminPage.dart';
import 'package:mashov/screens/AnswerQuestions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

String userName = "";
String password = "";
final _auth = FirebaseAuth.instance;
String error = '';

class LoginPage extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your email address'),
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  userName = value;
                },
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Type your password'),
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  password = value;
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              Button(
                onpress: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final userCredential =
                        await _auth.signInWithEmailAndPassword(
                            email: userName, password: password);
                    final user = userCredential.user;
                    final uid = user!.uid;
                    print(uid);
                    final userDocRef =
                        FirebaseFirestore.instance.collection('Users').doc(uid);
                    final userDocSnapshot = await userDocRef.get();
                    if (userDocSnapshot.exists) {
                      final userDocData = userDocSnapshot.data();
                      if (userDocData != null &&
                          userDocData.containsKey('role')) {
                        final role = userDocData['role'];
                        if (role == 'user') {
                          Navigator.pushNamed(context, AnswerQuestions.id);
                        } else if (role == 'admin') {
                          Navigator.pushNamed(context, AdminPage.id);
                        }
                      }
                    } else {
                      setState(() {
                        showSpinner = false;
                      });
                      print(userDocSnapshot.exists);
                    }
                  } catch (e) {
                    setState(() {
                      showSpinner = false;
                    });
                    int ch = e.toString().indexOf(']');
                    error = e.toString().substring(ch + 1);
                  }
                },
                text: 'Log In',
                color: Colors.blue,
              ),
              Text(
                ('$error'),
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final String text;
  final void Function()? onpress;
  final Color color;

  Button({required this.text, required this.onpress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onpress,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            '$text',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
