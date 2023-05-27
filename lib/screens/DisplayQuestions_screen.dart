import 'package:mashov/screens/AdminPage.dart';
import 'package:mashov/screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

User? loggedInUser;
final _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final CollectionReference questionsCollectionReference =
    _firestore.collection('questions');
final CollectionReference scoresCollectionReference =
    _firestore.collection('scores');

String questionText = '';
late int tappedIDX;
late int index;

Future<void> deleteScore(int index) async {
  final scoresRef = _firestore.collection('scores');

  final querySnapshot = await scoresRef.get();

  for (final docSnapshot in querySnapshot.docs) {
    final scoresList = docSnapshot.get('scores') ?? [];

    if (scoresList.isNotEmpty && scoresList.length > index) {
      scoresList.removeAt(index);
      await scoresRef.doc(docSnapshot.id).update({
        'scores': FieldValue.arrayRemove([index])
      });
    }
  }
}

Future<void> deleteDocument(
    int index, String collection, List<DocumentSnapshot> documents) async {
  await _firestore.collection(collection).doc(documents[index].id).delete();
}

Future<void> sortDocumentID(int id, String collection) async {
  final collectionReference = FirebaseFirestore.instance.collection(collection);

  // Update the IDs of subsequent documents
  final querySnapshot = await collectionReference.orderBy('id').get();
  final batch = FirebaseFirestore.instance.batch();
  int index = 0;

  querySnapshot.docs.forEach((doc) {
    final docId = doc.get('id');
    if (docId != null) {
      if (docId != index) {
        batch.update(doc.reference, {'id': index});
      }
      index++;
    }
  });

  await batch.commit();
}

Future<void> addZeroToScores() async {
  final collectionRef = FirebaseFirestore.instance.collection('scores');
  final querySnapshot = await collectionRef.get();

  for (final docSnapshot in querySnapshot.docs) {
    final scoresList = docSnapshot.get('scores') as List<dynamic>;
    scoresList.add(0);
    await docSnapshot.reference.update({'scores': scoresList});
  }
}

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
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, AdminPage.id);
            }),
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

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading');
            }
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
                            await deleteDocument(index, 'questions', documents);
                            await sortDocumentID(index, 'questions');
                            deleteScore(index);
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
              try {
                var dataToSave = <String, dynamic>{
                  'id': index,
                  'text': '',
                  'usersVoted': 0
                };
                setState(() {
                  questionsCollectionReference.add(dataToSave);
                  addZeroToScores();
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
