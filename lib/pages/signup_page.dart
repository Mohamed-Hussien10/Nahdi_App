// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nahdy/components/text_form_field.dart';
import 'package:nahdy/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

final _formKey = GlobalKey<FormState>();

class _SignUpPageState extends State<SignUpPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String email = '';
  String password = '';
  String phone = '';
  String name = '';
  String role = 'user';

  Future<void> signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user data like username and phone number in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'username': name,
        'phone_number': phone,
        'role': role,
      });

      // Navigate to another screen after sign up
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0F2F1),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 130,
            ),
            const Text(
              'Complete Profile',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Complete Your Details',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 35),
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 35),
                child: Column(
                  children: [
                    TextFField(
                      const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      'Name',
                      'Enter your name',
                      TextInputType.text,
                      false,
                      (value) {
                        if (value!.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                      (context) {
                        name = context!;
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFField(
                      const Icon(
                        Icons.phone,
                        color: Colors.black,
                      ),
                      'Phone',
                      'Enter your number',
                      TextInputType.phone,
                      false,
                      (value) {
                        String pattern = r'(^05[0-9]{8}$)|(^\+9665[0-9]{8}$)';
                        RegExp regExp = RegExp(pattern);
                        if (value!.isEmpty) {
                          return 'Phone is required';
                        }
                        if (!regExp.hasMatch(value)) {
                          return 'Please enter a valid Saudi phone number';
                        }
                        return null;
                      },
                      (context) {
                        phone = context!;
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFField(
                      const Icon(
                        Icons.email,
                        color: Colors.black,
                      ),
                      'Emial',
                      'Enter your email',
                      TextInputType.emailAddress,
                      false,
                      (value) {
                        if (value!.isEmpty) {
                          return 'Name is required';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Invalid email address';
                        }
                        return null;
                      },
                      (context) {
                        email = context!;
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFField(
                      const Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      'Password',
                      'Enter your password',
                      TextInputType.text,
                      true,
                      (value) {
                        if (value!.isEmpty) {
                          return 'Name is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                      (context) {
                        password = context!;
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, save the form
                  _formKey.currentState!.save();
                  signUp();

                  // Show success message or perform other actions
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Form successfully validated")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    ' Sign in.',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
