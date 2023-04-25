import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mashov/screens/AdminPage.dart';
import 'package:mashov/screens/AnswerQuestions.dart';
import 'package:mashov/screens/LoginPage.dart';
import 'package:mashov/screens/Register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool SignedIN = false;
bool cheating = false;

class HomePage extends StatefulWidget {
  static String id = 'home_page';
  @override
  State<HomePage> createState() => _HomePageState();
}

final _auth = FirebaseAuth.instance;
User? loggedInUser;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
void getCurrentUser() async {
  try {
    final user = await _auth.currentUser;
    if (user != null) {
      SignedIN = true;
      loggedInUser = user;
      print(loggedInUser!.email);
      print(SignedIN);
    }
  } catch (e) {
    print(e);
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    cheating = false;
    getCurrentUser();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    animation =
        ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    getCurrentUser();
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppBar'),
      ),
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                'Feedback Program',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 30,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 40, right: 40),
                child: Divider(
                  color: Colors.orangeAccent,
                  thickness: 2,
                ),
              ),
            ),
            SizedBox(
              height: controller.value * 18,
            ),
            Row(
              children: <Widget>[
                Container(
                  child: Image.asset('images/logo.png'),
                  height: controller.value * 55,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 2,
                        color: Colors.black87,
                      ),
                      shape: StadiumBorder()),
                  onPressed: () {
                    // can add an admin bool. then check if admin. needs to correlate to the signedOut bool.
                    print(SignedIN);
                    if (!SignedIN)
                      Navigator.pushNamed(context, LoginPage.id);
                    else
                      Navigator.pushNamed(context, AdminPage.id);
                  },
                  child: Text(
                    'Admin Panel',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  child: Image.asset('images/logo.png'),
                  height: controller.value * 55,
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 2,
                        color: Colors.black87,
                      ),
                      shape: StadiumBorder()),
                  onPressed: () {
                    if (!SignedIN) {
                      Navigator.pushNamed(
                        context,
                        LoginPage.id,
                        arguments: {'isFromQuestionnaire': true},
                      );
                    } else if (SignedIN &&
                        _auth.currentUser!.email != 'ishay7@gmail.com') {
                      Navigator.pushNamed(
                        context,
                        AnswerQuestions.id,
                        arguments: {
                          'from': 'start_questionnaire'
                        }, // pass a parameter indicating which button was pressed
                      );
                    } else if (SignedIN &&
                        _auth.currentUser!.email == 'ishay7@gmail.com') {
                      setState(() {
                        cheating = true;
                      });
                      print('thats cheating :)');
                    }
                  },
                  child: Text(
                    'Start Questionnaire',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: !SignedIN,
              child: Row(
                children: <Widget>[
                  Container(
                    child: Image.asset('images/logo.png'),
                    height: controller.value * 55,
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          width: 2,
                          color: Colors.black87,
                        ),
                        shape: StadiumBorder()),
                    onPressed: () {
                      Navigator.pushNamed(context, Registration.id);
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Visibility(
                visible: cheating,
                child: Text(
                  'thats cheating 😁',
                  style: (TextStyle(fontSize: 20)),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: SignedIN,
        child: FloatingActionButton(
          onPressed: () {
            _auth.signOut();
            SignedIN = false;
            setState(() {});
            print('logged out');
          },
          child: Icon(Icons.logout),
          backgroundColor: Colors.orangeAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
