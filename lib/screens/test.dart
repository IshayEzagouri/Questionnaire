import 'package:flutter/material.dart';
import 'package:mashov/screens/DisplayQuestions_screen.dart';
import 'package:mashov/Classes/Questions.dart';

class test extends StatefulWidget {
  static String id = 'test_page';
  @override
  State<test> createState() => _testState();
}

class _testState extends State<test> {
  Future<Text> getQuestions(List<Question> questions) async {
    return Text('${questions[0]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Text('${questions[0].questionText}'),
        ),
      ),
    );
  }
}
