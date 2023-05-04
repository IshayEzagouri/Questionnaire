import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mashov/screens/HomePage.dart';
import 'package:mashov/screens/LoginPage.dart';
import 'package:mashov/screens/test.dart';
import 'package:firebase_auth/firebase_auth.dart';

//TODO user can only vote once
//TODO scores are added to all the questions not the specific one im answering--V done
//TODO scores array needs to be in the same length as the questions
//TODO if there are no questions, i shouldn't be able to see the rating bar
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
  List<double> scoreList = [];
  Map<String, bool> _ratedCourses = {};

  Future<void> fetchScoreList() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('scores')
        .where('id', isEqualTo: tappedCourseID)
        .get();

    if (snapshot != null && snapshot.docs.isNotEmpty) {
      scoreList = snapshot.docs
          .map((doc) => (doc.data()['scores'] as List<dynamic>)
              .map((value) => double.parse(value.toString()))
              .toList())
          .expand((i) => i)
          .toList();
    }
  }

  void updateScoresArr(List<double> scoreList) {
    _firestore
        .collection('scores')
        .where('id', isEqualTo: tappedCourseID)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        var existingScores = doc['scores'] as List<dynamic>;
        var newScores =
            List<double>.from(existingScores.map((score) => score.toDouble()));
        for (int i = 0; i < scoreList.length && i < newScores.length; i++) {
          newScores[i] += scoreList[i];
        }
        await FirebaseFirestore.instance
            .collection('scores')
            .doc(doc.id)
            .update({'scores': newScores});
      });
    });
  }

  static List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _selectedButtonIndex = -1;

  void _fetchQuestions() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('questions')
        .orderBy('id')
        .get();
    setState(() {
      _questions = querySnapshot.docs
          .map((doc) => {'id': doc['id'], 'text': doc['text']})
          .toList();
    });
  }

  void setRatedCourse(int courseId) async {
    String? courseName = await getCourseDocID(courseId);
    if (courseName != null) {
      setState(() {
        _ratedCourses[courseName] = true;
      });
    }
  }

  Future<String?> getCourseDocID(int courseId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .where('id', isEqualTo: courseId)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }
    return null;
  }

  void getTappedCourseIDFieldValue(var list) {
    _firestore
        .collection('courses')
        .doc(list)
        .get()
        .then((DocumentSnapshot snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      int id = data['id'] as int;

      tappedCourseID = id;
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  int tappedCourseID = -1;

  void _showNextQuestion() {
    setState(() {
      _currentIndex++;
      print(_currentIndex);
    });
  }

  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    _fetchQuestions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Questionnaire'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
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
                        final courseId = documents[index].id;
                        if (_ratedCourses.containsKey(
                                courseId) && //Hides the button after rating is over.
                            _ratedCourses[courseId]!) {
                          // The user has rated this course, don't show the button
                          return SizedBox.shrink();
                        } else {
                          // The user has not rated this course, show the button
                          return Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      _selectedButtonIndex == index &&
                                              ratingBarVisibility == true
                                          ? Colors.orangeAccent
                                          : Colors.lightBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () {
                                  _currentIndex = 0;
                                  scoreList.clear();
                                  getTappedCourseIDFieldValue(courseId);

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
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              SizedBox(width: 25),
                            ],
                          );
                        }
                      },
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              }),
          _questions.isEmpty
              ? CircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Visibility(
                    visible: ratingBarVisibility,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Text(
                        '${_questions[_currentIndex]['text']}',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
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
                print('question index $_currentIndex');
                setState(() {
                  scoreList.add(rating);
                });

                print(rating);
                if (_currentIndex < _questions.length - 1)
                  _showNextQuestion();
                else {
                  // scoreList.clear();
                  setRatedCourse(
                      tappedCourseID); // Hides the button after rating is over;
                  ratingBarVisibility = false;
                  updateScoresArr(scoreList);
                  print('visibilty turned false');
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _auth.signOut();
          print('logged out');
          Navigator.pushNamed(context, test.id);
        },
        child: Icon(Icons.logout),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
