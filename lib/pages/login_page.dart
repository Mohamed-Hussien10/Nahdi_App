import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nahdy/admin/main_admin_page.dart';
import 'package:nahdy/components/text_form_field.dart';
import 'package:nahdy/pages/forgot_password_page.dart';
import 'package:nahdy/pages/home_page.dart';
import 'package:nahdy/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

final _formKey = GlobalKey<FormState>();

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;

  String email = '';
  String password = '';
  bool isLoading = false;

  //Sign in function
  Future<bool> signIn() async {
    bool valid = false;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists && userDoc['role'] == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MainAdminPage(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
      valid = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE0F2F1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100),
          child: Center(
            child: Column(
              children: [
                const Column(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                      child: Image(
                        image: AssetImage(
                          'assets/images/logo.png',
                        ),
                      ),
                    ),
                    Text(
                      'Alnahdi',
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        letterSpacing: 3,
                        color: Colors.red,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'For Medical Services',
                      style: TextStyle(
                        letterSpacing: 2,
                        color: Colors.blueGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Form(
                  key: _formKey,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 35),
                    child: Column(
                      children: [
                        TextFField(
                          const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                          'Email',
                          'Enter your email',
                          TextInputType.emailAddress,
                          false,
                          (value) {
                            if (value!.isEmpty) {
                              return 'Email is required';
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
                        const SizedBox(height: 25),
                        TextFField(
                          const Icon(
                            Icons.lock,
                            color: Colors.black,
                          ),
                          'Password',
                          'Enter your password',
                          TextInputType.visiblePassword,
                          true,
                          (value) {
                            if (value!.isEmpty) {
                              return 'Password is required';
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
                        const SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _formKey.currentState!.save();
                                    if (await signIn()) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text("Login successful")),
                                      );
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Invalid email or password")),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: isLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.teal,
                                      strokeWidth: 5,
                                    ),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 12),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 13),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPassword(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                ' Sign up.',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
