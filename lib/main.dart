import 'package:flutter/material.dart';
import 'package:mashov/screens/CoursePage_screen.dart';
import 'package:mashov/screens/AdminPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mashov/screens/LoginPage.dart';
import 'Classes/firebase_options.dart';
import 'package:mashov/screens/DisplayQuestions_screen.dart';
import 'screens/test.dart';
import 'screens/HomePage.dart';
import 'screens/AnswerQuestions.dart';
import 'screens/RegistrationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          bottomAppBarTheme: BottomAppBarTheme(
              color: Colors.cyan, padding: EdgeInsets.only(top: 20)),
          appBarTheme: AppBarTheme(
            shadowColor: Colors.orange,
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(35),
            )),
          )),
      initialRoute: HomePage.id,
      routes: {
        RegistrationPage.id: (context) => RegistrationPage(),
        AnswerQuestions.id: (context) => AnswerQuestions(),
        HomePage.id: (context) => HomePage(),
        LoginPage.id: (context) => LoginPage(),
        AdminPage.id: (context) => AdminPage(),
        DisplayQuestions.id: (context) => DisplayQuestions(),
        CoursePage.id: (context) => CoursePage(),
        test.id: (context) => test(),
      },
    );
  }
}
