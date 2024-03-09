import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/Animations/FadeAnimation.dart';
import 'package:lets_chat/Components/Options.dart';
import 'package:lets_chat/screens/dashboard/dashViewModel.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Provider.of<dashViewModel>(context, listen: false)
          .fetchQuestionAndStore();
      Provider.of<dashViewModel>(context, listen: false).setDisplayName();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashModel = Provider.of<dashViewModel>(context);
    final widthS = MediaQuery.of(context).size.width;
    final heightS = MediaQuery.of(context).size.height;
    return Consumer<dashViewModel>(builder: (context, eventProvider, child) {
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: heightS * 0.55,
              child: Stack(children: [
                Container(
                  height: heightS * 0.45,
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(heightS * 0.05),
                          bottomRight: Radius.circular(heightS * 0.05))),
                ),
                Positioned(
                  top: heightS * 0.08,
                  left: heightS * 0.15,
                  child: Row(
                    children: [
                      Text(
                        'Score:\t',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: heightS * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        eventProvider.score.toString(),
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: heightS * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: heightS * 0.04,
                  child: Container(
                      height: heightS * 0.25,
                      width: widthS * 0.85,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(heightS * 0.05),
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 1),
                                blurRadius: 5,
                                spreadRadius: 5,
                                color: Color(0xffD2B558).withOpacity(0.4))
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11),
                        child: eventProvider.questions.isNotEmpty
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: heightS * 0.05,
                                  ),
                                  Text(
                                    'Question ${eventProvider.currentIndex + 1} / ${eventProvider.questions.length}',
                                    style: TextStyle(
                                      fontSize: heightS * 0.025,
                                    ),
                                  ),
                                  SizedBox(
                                    height: heightS * 0.01,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FadeAnimation(
                                        1,
                                        Text(
                                          eventProvider.questions.isNotEmpty
                                              ? eventProvider.questionTitle
                                              : '',
                                          style: TextStyle(
                                            fontSize: heightS * 0.028,
                                          ),
                                        ),
                                      ))
                                ],
                              )
                            : SizedBox(
                                child: CircularProgressIndicator(),
                                height: heightS * 0.01,
                                width: widthS * 0.01,
                              ),
                      )),
                ),
                Positioned(
                  bottom: heightS * 0.21,
                  left: heightS * 0.155,
                  child: CircleAvatar(
                    radius: heightS * 0.075,
                    backgroundColor: Colors.white,
                    child: Center(
                        child: Text(
                      eventProvider.timerValue.toString(),
                      style: TextStyle(
                        fontSize: heightS * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
              ]),
            ),
            SizedBox(
              height: heightS * 0.01,
            ),
            OptionsQuiz(
              options: eventProvider.optionsQuiz,
              correctOption: eventProvider.correctAns,
            ),
            SizedBox(
              height: heightS * 0.01,
            ),
            SizedBox(
              height: heightS * 0.08,
              width: widthS * 0.5,
              child: ElevatedButton(
                onPressed: () async {
                  eventProvider.nextQuestion(
                      eventProvider.currentIndex, context);
                  // eventProvider.startTimer();
                  // eventProvider.fetchQuestionAndStore();
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xffD2B558)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(heightS * 0.05),
                            side: BorderSide(color: Colors.amberAccent)))),
                child: dashModel.currentIndex != 9
                    ? Text(
                        'Next Question',
                        style: TextStyle(
                            fontSize: heightS * 0.02,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: heightS * 0.02,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            )
          ],
        ),
      );
    });
  }
}
