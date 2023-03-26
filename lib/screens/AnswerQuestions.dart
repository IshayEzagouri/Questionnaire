import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool isVisible = false;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
int courseId = 0;
bool ratingBarVisibility = false;

class AnswerQuestions extends StatefulWidget {
  static String id = 'answer_questions';
  @override
  State<AnswerQuestions> createState() => _AnswerQuestionsState();
}

class _AnswerQuestionsState extends State<AnswerQuestions> {
  static List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _selectedButtonIndex = -1;

  void _fetchQuestions() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('questions').get();
    setState(() {
      _questions = querySnapshot.docs
          .map((doc) => {'id': doc['id'], 'text': doc['text']})
          .toList();
    });
  }

  void _showNextQuestion() {
    setState(() {
      _currentIndex++;
      print(_currentIndex);
    });
  }

  @override
  void initState() {
    _fetchQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Choose a Course',
            style: TextStyle(fontSize: 20),
          ),
          FutureBuilder<QuerySnapshot>(
              future: _firestore.collection('courses').orderBy('name').get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data?.docs != null) {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return SizedBox(
                    height: 100,
                    child: ListView.builder(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      scrollDirection: Axis.horizontal,
                      itemCount: documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: _selectedButtonIndex == index
                                    ? Colors.orangeAccent
                                    : Colors.lightBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedButtonIndex = index;
                                  ratingBarVisibility = true;
                                });
                              },
                              child: Text(
                                documents[index]['name'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            SizedBox(width: 25),
                          ],
                        );
                      },
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              }),
          _questions.isEmpty
              ? CircularProgressIndicator()
              : Padding(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: Text(
                    '${_questions[_currentIndex]['text']}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
          Visibility(
            visible: ratingBarVisibility,
            child: RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(_questions.length);
                if (_currentIndex < _questions.length - 1)
                  _showNextQuestion();
                else {
                  //TODO do something here-questions over
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
