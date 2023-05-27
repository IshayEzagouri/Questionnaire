import 'package:flutter/material.dart';
import 'package:mashov/Classes/Course.dart';

class ViewScores extends StatefulWidget {
  static String id = 'ViewScores';
  @override
  State<ViewScores> createState() => _ViewScoresState();
}

class _ViewScoresState extends State<ViewScores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Scores'),
      ),
      body: Text('hi'),
    );
  }
}
