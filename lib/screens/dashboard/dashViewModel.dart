import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/QuestionModel.dart';
import 'package:lets_chat/screens/ShowScore/ShowScore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashScreenViewModel {
  String name = '';
  List<Question> questions = [];
  String isCorrect = 'start';
  set displayName(String value) {
    name = value;
  }

  bool _isNext = false;
  String? userImg;

  String? selectedOption;
  int score = 0;

  int _initialTimerValue = 15;

  int get initialTimerValue => _initialTimerValue;
  void resetTimer() {
    timerValue = initialTimerValue;
  }

  void resetIsNext() {
    _isNext = false;
  }

  int index = 0;
  int _currentIndex = 0;

  String _questionTitle = ''; // Corrected variable name
  String _correctAns = '';
  Map<String, String> _optionsQuiz = {};

  String get questionTitle => _questionTitle;
  String get correctAns => _correctAns;
  String? get SelectedOption => selectedOption;
  int get currentIndex => _currentIndex;
  bool get isNext => _isNext;
  Map<String, String> get optionsQuiz => _optionsQuiz;

  set changeIsNext(bool value) {
    _isNext = value;
  }

  set questionTitle(String value) {
    _questionTitle = value;
  }

  set CurrentInd(int value) {
    _currentIndex = value;
  }

  set correctAns(String value) {
    _correctAns = value;
  }

  set optionsQuiz(Map<String, String> value) {
    _optionsQuiz = value;
  }

  set ChangeSelectOpt(String? value) {
    selectedOption = value;
  }

  int timerValue = 15;
}

class dashViewModel extends ChangeNotifier {
  final DashScreenViewModel dashScreenViewModel = DashScreenViewModel();
  String get displayName => dashScreenViewModel.name;
  String get isCorrect => dashScreenViewModel.isCorrect;

  get questions => dashScreenViewModel.questions;
  get timerValue => dashScreenViewModel.timerValue;
  get currentIndex => dashScreenViewModel._currentIndex;
  get questionTitle => dashScreenViewModel._questionTitle;
  get optionsQuiz => dashScreenViewModel._optionsQuiz;
  get indexQuiz => dashScreenViewModel.index;
  get isNextt => dashScreenViewModel._isNext;
  get selecOpt => dashScreenViewModel.selectedOption;
  get correctAns => dashScreenViewModel._correctAns;
  get score => dashScreenViewModel.score;
  get userImg => dashScreenViewModel.userImg;

  void setDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    dashScreenViewModel.name = prefs.getString('username').toString();
    dashScreenViewModel.userImg = prefs.getString('imgUser').toString();
    dashScreenViewModel.score = prefs.getInt('Score')!;
    print(dashScreenViewModel.userImg);
    notifyListeners();
  }

  void changeSelectOption(String? value) {
    dashScreenViewModel.ChangeSelectOpt = value;
    notifyListeners();
  }

  setQuestions(List<Question> newQuestions) {
    dashScreenViewModel.questions = newQuestions;
    notifyListeners();
  }

  Future<void> fetchQuestionAndStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('Score', 0);
      dashScreenViewModel.questions.clear();
      DatabaseReference reference =
          FirebaseDatabase.instance.ref().child('questions');
      DatabaseEvent dbEvent = await reference.once();

      // Handle potential null value from Firebase snapshot
      if (dbEvent.snapshot.value != null) {
        // Check if the snapshot value is a list
        final dynamic snapshotValue = dbEvent.snapshot.value;
        if (snapshotValue is List<dynamic>) {
          // Parse each question object in the list
          snapshotValue.forEach((questionJson) {
            if (questionJson['options'] is Map<dynamic, dynamic>) {
              final Map<String, String> options =
                  questionJson['options'].cast<String, String>();

              // Handle potential casting errors (optional)
              if (options != null) {
                questions.add(Question(
                    question: questionJson['question'],
                    options: options,
                    correctOption: questionJson['correctOption']));
              } else {
                print('Invalid options format for question: $questionJson');
              }
            } else {
              print('Unexpected format for question options: $questionJson');
            }
          });

          await setQuestion(questions, currentIndex);
          await startTimer(currentIndex);

          // Now you have the list of parsed questions
          // You can store or use this list as needed
          print("Parsed Questions:");
          print(questions);

          // Notify listeners that the questions list has been updated
          notifyListeners();
        } else {
          // Handle unexpected format for snapshot data
          print('Unexpected format for snapshot data: $snapshotValue');
        }
      } else {
        print('No data found in the snapshot.');
      }
    } catch (error) {
      print('Error fetching questions: $error');
    }
  }

  void onSelectedOption(String selectedOption, String correctOption) {
    print('checking************');
    if (selectedOption == correctOption) {
      dashScreenViewModel.isCorrect = 'yes';
      dashScreenViewModel.score += 10;
    } else {
      dashScreenViewModel.isCorrect = 'no';
    }
    notifyListeners();
  }

  Future startTimer(int currentIndex) async {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isNextt) {
        if (dashScreenViewModel.timerValue > 0) {
          dashScreenViewModel.timerValue--;
        } else {
          timer.cancel();
          // Stop the timer when it reaches 0
          dashScreenViewModel.isCorrect = 'no';

          if (dashScreenViewModel.index + 1 < questions.length) {
            dashScreenViewModel.index++;
            changeSelectOption(null);
            dashScreenViewModel.CurrentInd =
                dashScreenViewModel.index; // Increment the index
            setQuestion(questions, dashScreenViewModel.index);
            dashScreenViewModel.resetTimer();
            startTimer(dashScreenViewModel._currentIndex);
            dashScreenViewModel.isCorrect = 'start';
          } else {
            timer.cancel();
          }
        }
      } else {
        timer.cancel();
        dashScreenViewModel.resetIsNext();
      }
      notifyListeners();
    });
  }

  Future setQuestion(List<Question> questions, int index) async {
    dashScreenViewModel.questionTitle = questions[index].question;
    dashScreenViewModel.optionsQuiz = questions[index].options;
    dashScreenViewModel.correctAns = questions[index].correctOption;

    notifyListeners();
  }

  Future<void> nextQuestion(int currentIndex, BuildContext context) async {
    if (currentIndex + 1 < questions.length) {
      changeSelectOption(null);
      dashScreenViewModel.changeIsNext = true;
      dashScreenViewModel.resetTimer();

      startTimer(currentIndex + 1);
      dashScreenViewModel.CurrentInd = currentIndex + 1;
      await setQuestion(questions, currentIndex + 1);
      print(dashScreenViewModel.currentIndex);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('Score', dashScreenViewModel.score);
      dashScreenViewModel.CurrentInd = 0;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShowScore(),
        ),
      );
    }
    notifyListeners();
  }
}
