import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Classes/Course.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
late int tappedIDX;
late int index;
int courseId = 0;

void updateScoresDocName(String name) {
  _firestore
      .collection('scores')
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

void getCoursesLength() async {
  AggregateQuerySnapshot query =
      await _firestore.collection('courses').count().get();
  courseId = query.count;
}

class CoursePage extends StatefulWidget {
  static String id = 'course_page';
  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course List'),
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          future: _firestore.collection('courses').orderBy('name').get(),
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
                                      onChanged: (value) {
                                        _firestore
                                            .collection('courses')
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            getCoursesLength();
            var dataToSave = <String, dynamic>{
              'name': '',
              'professor': '',
              'id': courseId
            };

            var scores = <String, dynamic>{
              'name': '',
              'id': courseId,
              'scores': null,
            };
            setState(() {
              _firestore.collection('courses').add(dataToSave);
              _firestore.collection('scores').add(scores);
            });
          } catch (e) {
            print(e);
          }
        },
        backgroundColor: Colors.cyan.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }
}
