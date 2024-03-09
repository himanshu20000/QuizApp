import 'package:flutter/material.dart';
import 'package:lets_chat/Animations/ListAnimation.dart';
import 'package:lets_chat/screens/dashboard/dashViewModel.dart';
import 'package:provider/provider.dart';

class OptionsQuiz extends StatefulWidget {
  const OptionsQuiz({
    Key? key,
    required this.options,
    required this.correctOption,
  });

  final Map<String, String> options;
  final String correctOption;

  @override
  _OptionsQuizState createState() => _OptionsQuizState();
}

class _OptionsQuizState extends State<OptionsQuiz> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final dashModel = Provider.of<dashViewModel>(context);
    final widthS = MediaQuery.of(context).size.width;
    final heightS = MediaQuery.of(context).size.height;

    List<Widget> optionWidgets = [];

    bool anyIncorrectSelected = false;
    String? correctAnswerText;

    // Build option widgets
    for (var entry in widget.options.entries) {
      String optionKey = entry.key;
      String optionValue = entry.value;

      bool isSelected = dashModel.selecOpt == optionKey;
      bool isCorrect = dashModel.isCorrect == 'yes';

      Color color;
      if (isSelected && !isCorrect) {
        color = Colors.red;
        anyIncorrectSelected =
            true; // Mark that an incorrect option is selected
        correctAnswerText = 'Correct Answer: ${widget.correctOption}';
      } else if (isSelected && isCorrect) {
        color = Colors.green;
      } else {
        color = Colors.grey;
      }

      optionWidgets.add(
        GestureDetector(
            onTap: () {
              dashModel.changeSelectOption(optionKey);
              dashModel.onSelectedOption(optionKey, widget.correctOption);
            },
            child: ListAnimate(
              1.5,
              Container(
                height: heightS * 0.06,
                width: widthS * 0.85,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.all(Radius.circular(heightS * 0.1)),
                ),
                margin: EdgeInsets.symmetric(vertical: 5.0),
                child: Padding(
                  padding: EdgeInsets.all(heightS * 0.015),
                  child: Text(
                    '$optionKey: ${optionValue.toUpperCase()}',
                    style: TextStyle(
                      fontSize: heightS * 0.025,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            )),
      );
    }

    // Add correct answer text at the end if any incorrect option is selected
    if (anyIncorrectSelected) {
      optionWidgets.add(
        Visibility(
          visible: true, // Always visible at the end
          child: Text(
            correctAnswerText!,
            style: TextStyle(
              fontSize: heightS * 0.03,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: optionWidgets,
    );
  }
}
