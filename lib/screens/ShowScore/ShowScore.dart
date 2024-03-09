import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/Animations/FadeAnimation.dart';
import 'package:lets_chat/Components/Options.dart';
import 'package:lets_chat/screens/dashboard/dashViewModel.dart';
import 'package:lets_chat/screens/dashboard/dashboard.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ShowScore extends StatefulWidget {
  const ShowScore({super.key});

  @override
  State<ShowScore> createState() => _ShowScoreState();
}

class _ShowScoreState extends State<ShowScore> {
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
              height: heightS * 0.75,
              child: Stack(children: [
                Container(
                  height: heightS * 0.65,
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(heightS * 0.05),
                          bottomRight: Radius.circular(heightS * 0.05))),
                ),
                Positioned(
                  top: heightS * 0.08,
                  left: heightS * 0.03,
                  child: FadeAnimation(
                    1.5,
                    Text(
                      'Hi,',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: heightS * 0.045,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: heightS * 0.15,
                  left: heightS * 0.03,
                  child: FadeAnimation(
                    2,
                    Text(
                      dashModel.displayName.toUpperCase(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: heightS * 0.045,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: heightS * 0.04,
                  child: Container(
                      height: heightS * 0.35,
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
                        child: Column(
                          children: [
                            SizedBox(
                              height: heightS * 0.08,
                            ),
                            Text(
                              'Previous Score',
                              style: TextStyle(
                                  fontSize: heightS * 0.035,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: heightS * 0.01,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                dashModel.score.toString(),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: heightS * 0.1,
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ),
                Positioned(
                  bottom: heightS * 0.28,
                  left: heightS * 0.01,
                  child: Lottie.asset('images/quizWinner.json',
                      height: heightS * 0.25, width: widthS * 0.5),
                ),
              ]),
            ),
            SizedBox(
              height: heightS * 0.05,
            ),
            SizedBox(
              height: heightS * 0.08,
              width: widthS * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(),
                    ),
                  );
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xffD2B558)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(heightS * 0.05),
                            side: BorderSide(color: Colors.amberAccent)))),
                child: Text(
                  'Start',
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
