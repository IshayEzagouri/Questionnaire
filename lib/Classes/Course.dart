// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class ScoreBrain {
//   String? professorID;
//   String? courseID;
//   int? questionID;
//
//   ScoreBrain(this.professorID, this.courseID, this.questionID);
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<double> calc(professorID, courseID, questionID) {
//     if (courseID == null && questionID == null && professorID != null)
//       return calcAvgByProf(professorID);
//     else if (professorID == null && questionID == null && courseID != null) {
//       return calcAvgPerCourse(courseID);
//     } else if (professorID == null && courseID == null && questionID != null) {
//       //TODO calc by question
//     }
//   }
//
//   Future<int> fetchTotalQuestions() async {
//     final QuerySnapshot<Map<String, dynamic>> snapshot =
//         await _firestore.collection('questions').get();
//
//     return snapshot.size;
//   }
//
//   Future<int> fetchUsersVoted(String documentId) async {
//     final DocumentSnapshot<Map<String, dynamic>> snapshot =
//         await _firestore.collection('scores').doc(documentId).get();
//
//     if (snapshot.exists) {
//       final data = snapshot.data();
//       if (data != null && data.containsKey('usersVoted')) {
//         return data['usersVoted'] as int;
//       }
//     }
//
//     return 0; // Default value if the field is not present or an error occurred
//   }
//
//   Future<double> calculateTotalScore(String documentId) async {
//     final DocumentSnapshot<Map<String, dynamic>> snapshot =
//         await _firestore.collection('scores').doc(documentId).get();
//
//     if (snapshot.exists) {
//       final data = snapshot.data();
//       if (data != null && data.containsKey('scores')) {
//         List<dynamic> scores = data['scores'];
//         double totalScore = scores.fold(0, (sum, score) => sum + (score ?? 0));
//         return totalScore;
//       }
//     }
//
//     return 0; // Default value if the field is not present or an error occurred
//   }
//
//   Future<double> calcAvgPerCourse(String documentID) async {
//     final totalScore = await calculateTotalScore(documentID);
//     final usersVoted = await fetchUsersVoted(documentID);
//     final sumOfQuestions = await fetchTotalQuestions();
//
//     return totalScore / sumOfQuestions / usersVoted;
//   }
// }
//
// Future<double> calcByQuestion(int questionID) async {
//   final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
//       .instance
//       .collection('scores')
//       .where('question', isEqualTo: questionID)
//       .get();
//
//   List<DocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
//   double averageTotal = 0.0;
//   int numberOfDocuments = documents.length;
//
//   for (DocumentSnapshot<Map<String, dynamic>> document in documents) {
//     double average = await calculateTotalScore(document.id);
//     averageTotal += average;
//   }
//
//   return averageTotal / numberOfDocuments;
// }
//
// Future<double> calcAvgByProf(professorID) async {
//   if (professorID == null)
//     return -99.0;
//   else {
//     final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
//         .instance
//         .collection('scores')
//         .where('professor', isEqualTo: professorID)
//         .get();
//
//     List<DocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
//     double averageTotal = 0.0;
//     int numberOfDocuments = documents.length;
//
//     for (DocumentSnapshot<Map<String, dynamic>> document in documents) {
//       double average = await calcAvgByProf(professorID);
//       averageTotal += average;
//     }
//
//     return averageTotal / numberOfDocuments;
//   }
// }
