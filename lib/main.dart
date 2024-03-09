import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/firebase_options.dart';
import 'package:lets_chat/screens/ShowScore/ShowScore.dart';
import 'package:lets_chat/screens/auth.dart';
import 'package:lets_chat/screens/dashboard/dashViewModel.dart';
import 'package:lets_chat/screens/dashboard/dashboard.dart';
import 'package:lets_chat/screens/splash.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => dashViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffD2B558)),
          useMaterial3: true,
        ),
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              if (snapshot.hasData) {
                return const ShowScore();
              }
              return const AuthScreen();
            }),
      ),
    );
  }
}
