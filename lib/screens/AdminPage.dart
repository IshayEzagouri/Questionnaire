import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mashov/screens/DisplayQuestions_screen.dart';
import 'package:mashov/screens/CoursePage_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mashov/screens/HomePage.dart';
import 'package:mashov/screens/ViewScores.dart';
import 'package:mashov/screens/test.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

User? loggedInUser;
bool signedIN = false;
bool displaySignOutButton = false;

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
        signedIN = true;
        loggedInUser = user;
        print(loggedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void clearScores() {
    _firestore.collection('scores').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        var existingScores = doc['scores'] as List<dynamic>;
        var newScores = List.filled(existingScores.length, 0.0);
        doc.reference.update({'scores': newScores});
      });
    });
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
        automaticallyImplyLeading: false,
        title: Text('Admin Panel'),
      ),
      backgroundColor: animation.value,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (loggedInUser != null) // Check if loggedInUser is not null
            Center(
              child: Text(
                'Welcome ${loggedInUser!.email}',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
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
                  Navigator.pushNamed(context, ViewScores.id);
                },
                child: Text(
                  'View Scores',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      width: 2,
                      color: Colors.black87,
                    ),
                    shape: StadiumBorder()),
                onPressed: () {
                  clearScores();
                },
                child: Text(
                  'Clear Scores',
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
      floatingActionButton: Visibility(
        visible: signedIN,
        child: FloatingActionButton(
          onPressed: () {
            _auth.signOut();
            print('logged out');
            Navigator.pushNamed(context, test.id);
          },
          child: Icon(Icons.logout),
          backgroundColor: Colors.orangeAccent,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
