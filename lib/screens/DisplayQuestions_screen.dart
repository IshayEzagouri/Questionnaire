import 'dart:async';
import 'package:flutter/material.dart';
import '../Classes/Questions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? loggedInUser;
final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
CollectionReference collectionReference = _firestore.collection('questions');
List<Question> questions = [];
String questionText = '';
late int tappedIDX;
late int index;

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

class DisplayQuestions extends StatefulWidget {
  static String id = 'display_questions_page';

  @override
  State<DisplayQuestions> createState() => _DisplayQuestionsState();
}

class _DisplayQuestionsState extends State<DisplayQuestions> {
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        title: const Text('Question Bank'),
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          future: _firestore.collection('questions').orderBy('id').get(),
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
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Insert a new question',
                            ),
                            controller: TextEditingController(
                              text: documents[index]['text'],
                            ),
                            onTap: () {
                              tappedIDX = index;
                            },
                            onChanged: (value) {
                              _firestore
                                  .collection('questions')
                                  .doc(documents[index].id)
                                  .update({'text': value});
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 27),
                        child: IconButton(
                          onPressed: () async {
                            await _firestore
                                .collection('questions')
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
            }
            return CircularProgressIndicator();
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () async {
              try {
                var dataToSave = <String, dynamic>{'id': index, 'text': ''};
                setState(() {
                  collectionReference.add(dataToSave);
                });
              } catch (e) {
                print(e);
              }
            },
            backgroundColor: Colors.cyan.shade700,
            child: const Icon(Icons.add),
          ),
        ],
      )),
    );
  }
}

// ListView.builder(
// itemCount: questions.length,
// itemBuilder: (context, index) {
// return GestureDetector(
// onTap: () {
// setState(() {});
// },
// child: ListTile(
// title: TextFormField(
// controller: TextEditingController(
// text: questions[index].questionText),
// onTap: () {
// id = index;
// },
// onChanged: ((value) {
// setState(() {
// questions[index].questionText = value;
// });
// }),
// decoration: InputDecoration(
// hintText: '${questions[index].questionText}'),
// ),
// ));
// ;
// }),
