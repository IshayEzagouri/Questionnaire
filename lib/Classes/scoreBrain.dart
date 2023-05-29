import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreBrain {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> calculateAverage({
    String? professorID,
    String? courseID,
    int? questionID,
  }) async {
    if (professorID != null && courseID == null && questionID == null) {
      return await calcAvgByProf(professorID);
    } else if (professorID == null && courseID != null && questionID == null) {
      return await calcAvgPerCourse(courseID);
    } else if (professorID == null && courseID == null && questionID != null) {
      return await calcByQuestion(questionID);
    } else {
      throw Exception('Invalid parameters for calculateAverage');
    }
  }

  Future<List<String>> fetchAllProfessors() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('courses').get();

      List<String> professors = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data != null && data.containsKey('professor')) {
          return data['professor'] as String;
        } else {
          return '';
        }
      }).toList();

      return professors.where((professor) => professor.isNotEmpty).toList();
    } catch (e, stackTrace) {
      print('Error fetching professors: $e\n$stackTrace');
      return [];
    }
  }

  Future<String?> fetchCourseID(String courseName) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('courses')
          .where('name', isEqualTo: courseName)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final courseDoc = snapshot.docs.first;
        final data = courseDoc.data();
        return courseDoc.id;
      } else {
        return null; // Course not found
      }
    } catch (e) {
      print('Error fetching course ID: $e');
      return null; // Error occurred
    }
  }

  Future<List<String>> fetchAllQuestions() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('questions').get();

      List<String> questions = [];
      snapshot.docs.forEach((doc) {
        final data = doc.data();
        if (data != null && data.containsKey('name')) {
          questions.add(data['name'] as String);
        }
      });

      questions = questions.where((question) => question.isNotEmpty).toList();

      print('Fetched Questions: $questions'); // Debug print

      return questions;
    } catch (e, stackTrace) {
      print('Error fetching questions: $e\n$stackTrace');
      return [];
    }
  }

  Future<List<String>> fetchAllCourses() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('courses').get();

      List<String> courses = snapshot.docs.map((doc) {
        final data = doc.data();
        return data['name'] as String;
      }).toList();

      return courses;
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<int> fetchTotalQuestions() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection('questions').get();

    return snapshot.size;
  }

  Future<int> fetchUsersVoted(String documentID) async {
    // Retrieve the document snapshot for the specified ID
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .doc(documentID)
        .get();

    // Check if the document exists
    if (snapshot.exists) {
      // Retrieve the 'usersVoted' field from the document data
      int usersVoted = snapshot.get('usersVoted');

      return usersVoted;
    } else {
      // Handle the case when the document does not exist
      return 0;
    }
  }

  Future<double> calculateTotalScore(String documentID) async {
    // Retrieve the document snapshot for the specified ID
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .doc(documentID)
        .get();

    // Check if the document exists
    if (snapshot.exists) {
      // Retrieve the 'scores' array from the document data
      List<dynamic> scores = snapshot.get('scores');

      // Calculate the total score by summing up the scores in the array
      double totalScore = 0.0;
      for (var score in scores) {
        totalScore += score;
      }

      return totalScore;
    } else {
      // Handle the case when the document does not exist
      return 0.0;
    }
  }

  Future<double> calcAvgPerCourse(String documentID) async {
    // Remove the debug print for dropdown options if it's not available
    // print('Fetching dropdown options...');
    // final dropdownOptions = await fetchDropdownOptions();
    // print('Dropdown Options: $dropdownOptions');

    print('Fetching total score...');
    final totalScore = await calculateTotalScore(documentID);
    print('Total Score: $totalScore');

    print('Fetching users voted...');
    final usersVoted = await fetchUsersVoted(documentID);
    print('Users Voted: $usersVoted');

    print('Fetching sum of questions...');
    final sumOfQuestions = await fetchTotalQuestions();
    print('Sum of Questions: $sumOfQuestions');

    if (usersVoted > 0 && sumOfQuestions > 0) {
      final averageResult = totalScore / (sumOfQuestions * usersVoted);
      print('Average Result: $averageResult');
      return averageResult;
    } else {
      print('Average Result: 0.00');
      return 0.0; // Default value or handle the case where division by zero occurs
    }
  }

  Future<double> calcByQuestion(int questionID) async {
    try {
      final questionSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionID.toString())
          .get();

      if (!questionSnapshot.exists) {
        throw Exception('Question with ID $questionID does not exist');
      }

      final questionData = questionSnapshot.data() as Map<String, dynamic>;
      final int usersVoted = questionData['usersVoted'] ?? 0;

      if (usersVoted == 0) {
        return 0.0;
      }

      double totalScore = 0;

      final scoresSnapshot =
          await FirebaseFirestore.instance.collection('scores').get();

      for (final scoreDoc in scoresSnapshot.docs) {
        final scoreData = scoreDoc.data() as Map<String, dynamic>;
        final List<dynamic> scores = scoreData['scores'] ?? [];

        if (questionID < scores.length) {
          final double score = scores[questionID];
          totalScore += score;
        }
      }

      double averageScore = totalScore / usersVoted;

      return averageScore;
    } catch (e) {
      print('Error calculating average score: $e');
      return 0.0;
    }
  }

  Future<double> calcAvgByProf(String professorID) async {
    if (professorID == null) return -99.0;
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('scores')
        .where('professor', isEqualTo: professorID)
        .get();

    List<DocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
    double averageTotal = 0.0;
    int numberOfDocuments = documents.length;

    for (DocumentSnapshot<Map<String, dynamic>> document in documents) {
      double average = await calcAvgPerCourse(document.id);
      averageTotal += average;
    }

    return averageTotal / numberOfDocuments;
  }
}
