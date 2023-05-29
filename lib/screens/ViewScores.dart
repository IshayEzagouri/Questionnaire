import 'package:flutter/material.dart';
import 'package:mashov/Classes/scoreBrain.dart';
import 'package:flutter/cupertino.dart';

class ViewScores extends StatefulWidget {
  static String id = 'ViewScores';

  @override
  _ViewScoresState createState() => _ViewScoresState();
}

class _ViewScoresState extends State<ViewScores> {
  ScoreBrain scoreBrain = ScoreBrain();
  TextEditingController inputController = TextEditingController();
  String averageResult = '';
  String selectedOption = 'Professor'; // Default selected option
  String selectedValue = ''; // Initially empty selected value

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch initial data for dropdowns
  }

  Future<void> fetchData() async {
    try {
      final courses = await scoreBrain.fetchAllCourses();
      final professors = await scoreBrain.fetchAllProfessors();

      print('Fetched Courses: $courses'); // Debug print
      print('Fetched Professors: $professors'); // Debug print
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error appropriately (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculate Average'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Professor'),
                      leading: Radio<String>(
                        value: 'Professor',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                            selectedValue = '';
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Course'),
                      leading: Radio<String>(
                        value: 'Course',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                            selectedValue = '';
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Question'),
                      leading: Radio<String>(
                        value: 'Question',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                            selectedValue = '';
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              if (selectedOption == 'Question')
                FutureBuilder<List<String>>(
                  future: scoreBrain.fetchAllQuestions(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      print(
                          'Error loading questions: ${snapshot.error}'); // Debug print
                      return Text('Error loading questions');
                    } else {
                      List<String> questions = snapshot.data ?? [];
                      print('Fetched Questions: $questions'); // Debug print
                      return DropdownButtonFormField<String>(
                        value: selectedValue.isNotEmpty ? selectedValue : null,
                        hint: Text('Select Question'),
                        items: questions.map((question) {
                          return DropdownMenuItem<String>(
                            value: question,
                            child: Text(question),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value!;
                            print(
                                'Selected Question: $selectedValue'); // Debug print
                          });
                        },
                      );
                    }
                  },
                ),
              if (selectedOption == 'Course' || selectedOption == 'Professor')
                FutureBuilder<List<String>>(
                  future: selectedOption == 'Course'
                      ? scoreBrain.fetchAllCourses()
                      : scoreBrain.fetchAllProfessors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      print(
                          'Error loading ${selectedOption}s: ${snapshot.error}'); // Debug print
                      return Text('Error loading ${selectedOption}s');
                    } else {
                      List<String> options = snapshot.data ?? [];
                      print('Dropdown Options: $options'); // Debug print
                      return DropdownButtonFormField<String>(
                        value: selectedValue.isNotEmpty ? selectedValue : null,
                        hint: Text('Select ${selectedOption}'),
                        items: options.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value!;
                            print(
                                'Selected Value: $selectedValue'); // Debug print
                          });
                        },
                      );
                    }
                  },
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  int? questionID;
                  String? courseID;
                  String? professorID;

                  if (selectedOption == 'Question') {
                    // Retrieve the selected question ID
                    // You can use the selectedValue variable here
                    questionID = selectedValue.isNotEmpty
                        ? int.tryParse(selectedValue)
                        : null;
                  } else if (selectedOption == 'Course') {
                    // Retrieve the selected course ID
                    // You can use the selectedValue variable here
                    print('selected value is $selectedValue');
                    courseID = selectedValue.isNotEmpty ? selectedValue : null;
                    courseID = await scoreBrain.fetchCourseID(selectedValue);
                    print(courseID);
                  } else if (selectedOption == 'Professor') {
                    // Retrieve the selected professor ID
                    // You can use the selectedValue variable here
                    professorID =
                        selectedValue.isNotEmpty ? selectedValue : null;
                  }
                  print("professor $professorID");
                  print("Course is $courseID");
                  print("question is $questionID ");

                  double average = await scoreBrain.calculateAverage(
                    questionID: questionID,
                    courseID: courseID,
                    professorID: professorID,
                  );

                  setState(() {
                    averageResult = average.toStringAsFixed(2);
                    print('Average Result: $averageResult'); // Debug print
                  });
                },
                child: Text('Calculate Average'),
              ),
              SizedBox(height: 16.0),
              Text(
                'Average Result: $averageResult',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
