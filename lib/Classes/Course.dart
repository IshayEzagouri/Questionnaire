import 'package:flutter/material.dart';
import 'package:mashov/Classes/Questions.dart';

class Course {
  late String name;
  late String professor;
  List<Question> questions;
  List<int> grades;

  Course(
      {this.professor = '',
      this.questions = const [],
      this.grades = const [],
      this.name = ""});

  void addQuestion(String question) => questions.add(Question());
  void addGrade(int grade) => grades.add(grade);

  void removeQuestion(int questionNumber) {
    questions.remove(questionNumber);
    grades.remove(questionNumber);
  }

  double getAvg() =>
      grades.fold(0, (previousValue, element) => previousValue + element) /
      grades.length;
}
