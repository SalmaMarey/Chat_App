import 'dart:developer';
import 'dart:io';
import 'package:chat_app/widgets/user_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  final emailController = TextEditingController();
  final paswordController = TextEditingController();
  final usernameController = TextEditingController();
  File? _selectedImage;
  var _isUpLoading = false;
  void _submit() async {
    final valid = _formKey.currentState!.validate();
    if (!valid || (!_isLogin && _selectedImage == null)) {
      return;
    }

    try {
      setState(() {
        _isUpLoading = true;
      });
      if (_isLogin) {
        // ignore: unused_local_variable
        final UserCredential userCredentialc =
            await _firebase.signInWithEmailAndPassword(
          email: emailController.text,
          password: paswordController.text,
        );
      } else {
        final UserCredential userCredential =
            await _firebase.createUserWithEmailAndPassword(
          email: emailController.text,
          password: paswordController.text,
        );
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        log(imageUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': usernameController.text,
          'email': emailController.text,
          'image_url': imageUrl,
          'id': userCredential.user!.uid,
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed'),
        ),
      );
      setState(() {
        _isUpLoading = false;
      });
    }

    _formKey.currentState?.save();
    log(emailController.text);
    log(paswordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 30, right: 20, left: 20),
                width: 200,
                child: Image.asset('assets/photo_2023-12-31_22-41-08.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (File pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (value) => emailController.text = value!,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return '';
                              }
                              return null;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              controller: usernameController,
                              decoration:
                                  const InputDecoration(labelText: 'UserName'),
                              onSaved: (value) =>
                                  usernameController.text = value!,
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Please enter at least 4 characters.';
                                }
                                return null;
                              },
                            ),
                          TextFormField(
                            controller: paswordController,
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            onSaved: (value) => paswordController.text = value!,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isUpLoading)
                            if (!_isUpLoading)
                              const CircularProgressIndicator(),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          if (!_isUpLoading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
