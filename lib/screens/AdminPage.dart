import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mashov/Classes/Course.dart';
import 'package:mashov/screens/CoursePage_screen.dart';
import 'package:mashov/screens/DisplayQuestions_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? loggedInUser;

class AdminPage extends StatefulWidget {
  static String id = 'admin_page';
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
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
                'Welcome ${loggedInUser!.email}',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 22,
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
                    Navigator.pushNamed(context, CoursePage.id);
                  },
                  child: Text(
                    'Add or remove Course',
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
                    Navigator.pushNamed(context, DisplayQuestions.id);
                  },
                  child: Text(
                    'Add or remove questions',
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
          ],
        ),
      ),
    );
  }
}
