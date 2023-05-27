import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashov/screens/AdminPage.dart';
import 'package:mashov/screens/HomePage.dart';

late int tappedIDX;
late int index;
int courseId = 0;

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

Future<int> getCollectionSize(String collectionName) async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection(collectionName).get();
  return snapshot.docs.length;
}

void updateScoresDocName(String name) {
  _firestore
      .collection('questions')
      .where('id', isEqualTo: courseId)
      .get()
      .then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach(
      (doc) {
        FirebaseFirestore.instance
            .collection('scores')
            .doc(doc.id)
            .update({'name': name});
      },
    );
  });
}

//problem- course id only changes when tapped, not when added

void getTappedCourseID(var list) {
  _firestore
      .collection('courses')
      .doc(list)
      .get()
      .then((DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    int id = data['id'] as int;
    print('ID: $id');
    courseId = id;
  }).catchError((error) {
    print('Error getting document: $error');
  });
}

Future getCoursesLength() async {
  AggregateQuerySnapshot query =
      await _firestore.collection('courses').count().get();
  courseId = await query.count;
  return courseId;
}

class CoursePage extends StatefulWidget {
  static String id = 'course_page';
  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, AdminPage.id);
            }),
        title: Text('Course List'),
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          future: _firestore.collection('courses').orderBy('id').get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('error: ${snapshot.error}');
            }

            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return Text('Loading');
            // }
            if (snapshot.data?.docs != null) {
              List<DocumentSnapshot> documents = snapshot.data!.docs;
              index = documents.length;
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0, left: 15),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: Colors.orangeAccent),
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration.collapsed(
                                        hintText: 'Insert course name',
                                      ),
                                      style: TextStyle(fontSize: 25),
                                      controller: TextEditingController(
                                        text: documents[index]['name'],
                                      ),
                                      onTap: () {
                                        tappedIDX = index;
                                        print(index);
                                      },
                                      onChanged: (value) async {
                                        await _firestore
                                            .collection('courses')
                                            .doc(documents[index].id)
                                            .update({'name': value});

                                        await _firestore
                                            .collection('scores')
                                            .doc(documents[index].id)
                                            .update({'name': value});

                                        getTappedCourseID(documents[index].id);
                                        updateScoresDocName(value);
                                      },
                                    ),
                                    TextField(
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration.collapsed(
                                        hintText: 'Insert professor name',
                                      ),
                                      style: TextStyle(fontSize: 15),
                                      controller: TextEditingController(
                                        text: documents[index]['professor'],
                                      ),
                                      onTap: () {
                                        tappedIDX = index;
                                      },
                                      onChanged: (value) {
                                        _firestore
                                            .collection('courses')
                                            .doc(documents[index].id)
                                            .update({'professor': value});

                                        _firestore
                                            .collection('scores')
                                            .doc(documents[index].id)
                                            .update({'professor': value});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: IconButton(
                          onPressed: () async {
                            await _firestore
                                .collection('courses')
                                .doc(documents[index].id)
                                .delete();

                            await _firestore
                                .collection('scores')
                                .doc(documents[index].id)
                                .delete();

                            setState(() {});
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else
              return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              _auth.signOut();
              print('logged out');
              Navigator.pushNamed(context, HomePage.id);
            },
            child: Icon(Icons.logout),
            backgroundColor: Colors.orangeAccent,
          ),
          FloatingActionButton(
            onPressed: () async {
              int questionsLength = await getCollectionSize('questions');
              List<int> list = List.generate(
                  await getCollectionSize('questions'), (index) => 0);
              try {
                int courseLength = await getCoursesLength();
                print(courseLength);
                var dataToSave = <String, dynamic>{
                  'name': '',
                  'professor': '',
                  'id': courseLength,
                  'alreadyRatedUsersID': [],
                };

                var courseRef =
                    await _firestore.collection('courses').add(dataToSave);
                var scores = <String, dynamic>{
                  'name': '',
                  'id': courseLength,
                  'scores': list,
                  'usersVoted': 0,
                };
                var scoresRef = await _firestore
                    .collection('scores')
                    .doc(courseRef.id)
                    .set(scores);

                setState(() {
                  // do whatever you need to do after adding the documents
                });
              } catch (e) {
                print(e);
              }
            },
            backgroundColor: Colors.cyan.shade700,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
