import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mashov/screens/LoginPage.dart';
import 'package:mashov/screens/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

//TODO buttons are still visible if user logs out and back in.
//TODO on the first vote the usersvoted isn't updated and the button doesn't vanish
bool isVisible = false;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
int courseId = 0;
bool ratingBarVisibility = false;
String headlineText = 'Choose a course';

class AnswerQuestions extends StatefulWidget {
  static String id = 'answer_questions';
  @override
  State<AnswerQuestions> createState() => _AnswerQuestionsState();
}

class _AnswerQuestionsState extends State<AnswerQuestions> {
  List<double> scoreList = [];
  String? uid = '';

  Future<bool> checkUserVotedOnAllCourses(String? userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('courses')
        .where('alreadyRatedUsersID', arrayContains: userId)
        .get();

    return snapshot.docs.length == snapshot.size;
  }

  Future<void> incrementUsersVoted(String courseId) async {
    final courseRef = _firestore.collection('scores').doc(courseId);

    await courseRef.update({'usersVoted': FieldValue.increment(1)});
  }

  Future<void> addUserToRatedList(String courseId, String userId) async {
    print('addUserToRatedList called');
    try {
      final courseDoc = _firestore.collection('courses').doc(courseId);
      final courseSnapshot = await courseDoc.get();
      if (courseSnapshot.exists) {
        final courseData = courseSnapshot.data()!;
        List<String> alreadyRatedUsersID =
            List<String>.from(courseData['alreadyRatedUsersID']);
        if (!alreadyRatedUsersID.contains(userId)) {
          alreadyRatedUsersID.add(userId);
          await courseDoc.update({'alreadyRatedUsersID': alreadyRatedUsersID});
          print('User added to rated list for course $courseId');
        } else {
          print('User $userId already in rated list for course $courseId');
        }
      } else {
        print('Course $courseId does not exist');
      }
    } catch (e) {
      print('Error adding user to rated list: $e');
    }
  }

  Future<void> fetchScoreList() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('scores')
        .doc(tappedCourseID)
        .collection('scoreList')
        .get();

    if (snapshot != null && snapshot.docs.isNotEmpty) {
      scoreList = snapshot.docs
          .map((doc) => (doc.data()['scores'] as List<dynamic>)
              .map((value) => double.parse(value.toString()))
              .toList())
          .expand((i) => i)
          .toList();
    }

    final courseDoc = _firestore.collection('courses').doc(tappedCourseID);
    final courseSnapshot = await courseDoc.get();
    if (courseSnapshot.exists) {
      final courseData = courseSnapshot.data()!;
      final alreadyRatedUsersID =
          List<String>.from(courseData['alreadyRatedUsersID']);
      if (alreadyRatedUsersID.contains(uid)) {
        setState(() {
          ratingBarVisibility = false;
        });
      }
    }
  }

  void updateScoresArr(List<double> scoreList) async {
    var scoresRef = _firestore.collection('scores').doc(tappedCourseID);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(scoresRef);
      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }

      var existingScores = snapshot.get('scores') as List<dynamic>;
      var newScores =
          List<double>.from(existingScores.map((score) => score.toDouble()));
      for (int i = 0; i < scoreList.length && i < newScores.length; i++) {
        newScores[i] += scoreList[i];
      }

      transaction.update(scoresRef, {'scores': newScores});
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

  void getTappedCourseID(var list) {
    _firestore
        .collection('courses')
        .doc(list)
        .get()
        .then((DocumentSnapshot snapshot) {
      String id = snapshot.id;
      tappedCourseID = id;
      print(tappedCourseID);
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  String tappedCourseID = '';

  void _showNextQuestion() {
    setState(() {
      _currentIndex++;
      print(_currentIndex);
    });
  }

  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<User?> getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        print(user.email);
        return user;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> getUserId(User? user) async {
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _fetchQuestions();
    getCurrentUser().then((user) {
      if (user != null) {
        loggedInUser = user;
        uid = user.uid;
        addUserToRatedList(tappedCourseID, uid!);
      }
    });
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
            headlineText,
            style: TextStyle(fontSize: 20),
          ),
          FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('courses').orderBy('name').get(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                final documents = snapshot.data!.docs;
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    scrollDirection: Axis.horizontal,
                    itemCount: documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final course = documents[index];
                      final alreadyRatedUsersId = List<String>.from(
                          course['alreadyRatedUsersID'] ?? []);

                      if (checkUserVotedOnAllCourses(loggedInUser?.uid) ==
                          true) {
                        headlineText = 'Thanks for your input';
                        // The current user has already rated this course, don't show the button.
                        return const SizedBox.shrink();
                        setState(() {});
                      } else {
                        headlineText = 'Choose a course';
                      }

                      return Row(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: _selectedButtonIndex == index &&
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
                              getTappedCourseID(documents[index].id);

                              setState(() {
                                _selectedButtonIndex = index;
                                ratingBarVisibility = true;
                              });
                            },
                            child: Text(
                              course['name'],
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
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
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
              //_questions.length
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) async {
                setState(() {
                  scoreList.add(rating);
                  print(scoreList);
                });

                if (_currentIndex < _questions.length - 1) {
                  _showNextQuestion();
                } else {
                  // scoreList.clear();
                  _firestore.collection('courses');
                  loggedInUser = await getCurrentUser();
                  uid = await getUserId(loggedInUser);
                  print('uid is $uid');
                  if (uid != null) {
                    await addUserToRatedList(
                        tappedCourseID, uid ?? 'default_user_id');
                    await incrementUsersVoted(tappedCourseID);
                  } else {
                    // Handle the case where uid is null
                  }

                  setState(() {
                    ratingBarVisibility = false;
                  });
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
          Navigator.pushNamed(context, HomePage.id);
        },
        child: Icon(Icons.logout),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
