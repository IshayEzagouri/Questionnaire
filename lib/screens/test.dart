import 'package:flutter/material.dart';
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
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                      Text(
                        'test',
                        style: TextStyle(fontSize: 34),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                  Text(
                    'test',
                    style: TextStyle(fontSize: 34),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
