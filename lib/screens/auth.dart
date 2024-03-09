import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/screens/dashboard/dashViewModel.dart';
import 'package:lets_chat/widgets/user_image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  File? _selectedImage;
  var _isAuthenticating = false;
  var _islogin = false;
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signInWithGoogle(BuildContext context) async {
    final DashView = Provider.of<dashViewModel>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = authResult.user;

        // Check if user is signed in
        if (user != null) {
          // Create a reference to the Firebase Realtime Database
          final userReference =
              FirebaseDatabase.instance.ref().child('users').child(user.uid);

          // Store user's information in the database
          await userReference.set({
            'username': user.displayName,
            'email': user.email,
            // Add more user information as needed
          });

          prefs.setString('username', user.displayName!);
          DashView.setDisplayName();
          DashView.fetchQuestionAndStore();

          // Handle signed-in user
        }
      }
    } catch (error) {
      // Handle sign-in errors
      print('Error signing in with Google: $error');
    }
  }

  void _submit(BuildContext context) async {
    final dashModel = Provider.of<dashViewModel>(context, listen: false);
    final isValid = _form.currentState!.validate();

    if (!isValid || (!_islogin && _selectedImage == null)) {
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (_islogin) {
        final _userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final userReference = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(_userCredentials.user!.uid);

        print('Name is  1!!!!!!!!!!! ${userReference}');

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Authentication success'),
        ));

        prefs.setString('username', _enteredUsername);
        dashModel.setDisplayName();
        dashModel.fetchQuestionAndStore();
      } else {
        final _userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final StorageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${_userCredentials.user!.uid}.jpg');

        await StorageRef.putFile(_selectedImage!);
        final imageUrl = await StorageRef.getDownloadURL();

        final userReference = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(_userCredentials.user!.uid);

        // Save username to SharedPreferences

        await userReference.set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'password': _enteredPassword,
          'image_url': imageUrl,
        });

        prefs.setString('username', _enteredUsername ?? '');
        prefs.setString('imgUser', imageUrl);
        dashModel.setDisplayName();
        dashModel.fetchQuestionAndStore();
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed'),
      ));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final widthS = MediaQuery.of(context).size.width;
    final heightS = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: heightS * 0.01,
              ),
              Lottie.asset('images/Quiz.json', height: heightS * 0.2),
              Card(
                margin: const EdgeInsets.all(20),
                elevation: 5.0,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_islogin)
                              UserImagePicker(
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email adzdress';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.none,
                            ),
                            if (!_islogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                enableSuggestions: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 4) {
                                    return 'Please enter a valid username (must be atleast 4 characters.)';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredUsername = value!;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be atleast 6 character long';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (_isAuthenticating) CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: () {
                                  _submit(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                child: Text(_islogin ? 'Login' : 'Sign Up'),
                              ),
                            if (!_isAuthenticating)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _islogin = !_islogin;
                                    });
                                  },
                                  child: Text(_islogin
                                      ? 'Create an account'
                                      : 'I already have an account')),
                          ],
                        )),
                  ),
                ),
              ),
              GestureDetector(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: heightS / 18,
                  width: _isAuthenticating ? 0 : widthS / 1.5,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))),
                  child: Visibility(
                    visible: !_isAuthenticating,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'images/LogoG.png',
                          width: 20,
                          height: 20,
                        ),
                        SizedBox(
                          width: widthS / 40,
                        ),
                        Text(
                          'Sign In with Google',
                          style: TextStyle(
                              fontSize: heightS / 40, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 500))
                      .then((value) => _signInWithGoogle(context));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
