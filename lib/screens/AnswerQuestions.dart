import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mashov/screens/test.dart';
import 'package:firebase_auth/firebase_auth.dart';

int questionsRated = 0; // Reset questionsRated to 0 for the next course

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
    if (tappedCourseID.isNotEmpty) {
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

      final currentUserID = loggedInUser?.uid;
      final courseDoc =
          await _firestore.collection('courses').doc(tappedCourseID).get();
      final alreadyRatedUsersID =
          List<String>.from(courseDoc['alreadyRatedUsersID'] ?? []);

      if (alreadyRatedUsersID.contains(currentUserID)) {
        setState(() {
          ratingBarVisibility = false;
        });
      }
    }
  }

  void updateScoresArr(String courseId, List<double> scoreList) async {
    try {
      final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .doc(courseId)
          .get();

      if (documentSnapshot.exists) {
        final Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('scores')) {
          final List<dynamic> existingScores = data['scores'] as List<dynamic>;
          final List<double> newScores = List<double>.from(
              existingScores.map((score) => score.toDouble()));

          for (int i = 0; i < scoreList.length && i < newScores.length; i++) {
            newScores[i] += scoreList[i];
          }

          await FirebaseFirestore.instance
              .collection('scores')
              .doc(courseId)
              .update({'scores': newScores});

          // Check if all questions have been rated
          final bool allRated =
              newScores.every((score) => score >= 1 && score <= 5);

          if (allRated) {
            // Increment the usersVoted value by 1
            await FirebaseFirestore.instance
                .collection('scores')
                .doc(courseId)
                .update({'usersVoted': FieldValue.increment(1)});

            // Reset the questionsRated counter for the current course
            questionsRated = 0;

            // Increment usersVoted in all documents inside the questions collection
            final QuerySnapshot<Map<String, dynamic>> questionsSnapshot =
                await FirebaseFirestore.instance.collection('questions').get();

            for (final DocumentSnapshot<Map<String, dynamic>> questionDoc
                in questionsSnapshot.docs) {
              final Map<String, dynamic>? questionData = questionDoc.data();
              final int currentUsersVoted = questionData?['usersVoted'] ?? 0;
              await questionDoc.reference.update({
                'usersVoted': currentUsersVoted + 1,
              });
            }
          }
        } else {
          print('Field "scores" does not exist in the document');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error updating scores: $e');
    }
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

  Future<String?> getTappedCourseID(String courseId) async {
    try {
      final courseDoc =
          await _firestore.collection('courses').doc(courseId).get();
      if (courseDoc.exists) {
        return courseDoc.id;
      } else {
        print('Course $courseId does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
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
    getCurrentUser();
    fetchScoreList(); // Call fetchScoreList to check if the user has already rated the course
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

                      if (alreadyRatedUsersId.contains(loggedInUser?.uid)) {
                        // The current user has already rated this course, don't show the button.
                        return const SizedBox.shrink();
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
                            onPressed: () async {
                              final course = documents[index];
                              final courseId = course.id;
                              final tappedCourseId =
                                  await getTappedCourseID(courseId);
                              if (tappedCourseId != null) {
                                setState(() {
                                  _selectedButtonIndex = index;
                                  ratingBarVisibility = true;
                                  tappedCourseID = tappedCourseId;
                                  headlineText =
                                      'Thanks for your input'; // Move it here
                                });
                              }
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
              itemCount: 5,
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
                questionsRated++; // Increment the questionsRated variable

                if (questionsRated == _questions.length) {
                  // All questions have been rated for the current course
                  _firestore.collection('courses');
                  getCurrentUser();
                  uid = await getUserId(loggedInUser);
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

                  // Call updateScoresArr to update the scores and usersVoted fields
                  updateScoresArr(tappedCourseID, scoreList);
                  _currentIndex = 0;
                  print('visibilty turned false');

                  questionsRated =
                      0; // Reset questionsRated to 0 for the next course
                } else {
                  // Continue to the next question
                  _showNextQuestion();
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
