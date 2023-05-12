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
//TODO if there are no questions, i shouldn't be able to see the rating baraz
//TODO i need every document inside the users collection to have an array of map<string,bool>. inside the map i need to have the course id and true if finished rating.i will need to add to the map every time a course has been created, and vice versa.  then the future builder will need to have a condition and to only build buttons for courses that have a false value inside the array of map<string,bool> in the users collection.

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
  }

  void updateScoresArr(List<double> scoreList) {
    _firestore
        .collection('scores')
        .doc(tappedCourseID)
        .collection('scoreList')
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
            .doc(tappedCourseID)
            .collection('scoreList')
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

  void getTappedCourseID(var list) {
    _firestore
        .collection('courses')
        .doc(list)
        .get()
        .then((DocumentSnapshot snapshot) {
      String id = snapshot.id;
      tappedCourseID = id;
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
                  // TODO i can create a map of bools for the courses and add a condition here.
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
                                getTappedCourseID(documents[index].id);

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
              itemCount: _questions.length,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) async {
                setState(() {
                  scoreList.add(rating);
                });

                print(rating);
                if (_currentIndex < _questions.length - 1)
                  _showNextQuestion();
                else {
                  // scoreList.clear();
                  _firestore.collection('courses');
                  getCurrentUser();
                  String? uid = await getUserId(loggedInUser);
                  print(uid);
                  if (uid != null) {
                    await addUserToRatedList(
                        tappedCourseID, uid ?? 'default_user_id');
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
          Navigator.pushNamed(context, test.id);
        },
        child: Icon(Icons.logout),
        backgroundColor: Colors.orangeAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
