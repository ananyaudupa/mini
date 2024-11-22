import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String selectedRole = 'Citizen'; // Default role
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Register function
  void register() async {
    if (passwordController.text != confirmPasswordController.text) {
      displayMessageToUser("Passwords don't match!");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await createUserDocument(userCredential);

      if (context.mounted) {
        Navigator.pop(context); // Close the loading dialog if open
        displayMessageToUser('Registration successful!');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email provided is not valid.';
          break;
        default:
          message = 'An error occurred. Please try again.';
      }
      displayMessageToUser(message);
    } catch (e) {
      displayMessageToUser('An error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createUserDocument(UserCredential userCredential) async {
    if (userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.email) // Use user UID as document ID
          .set({
        'email': userCredential.user!.email,
        'username': usernameController.text,
        'role': selectedRole,
      });
    }
  }

  void displayMessageToUser(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Judica"),
        backgroundColor: const Color.fromRGBO(255, 125, 41, 1),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/Background.jpg',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 40.0, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 238, 169, 1),
                        shape: BoxShape.circle),
                    child: const Icon(
                      Icons.person,
                      size: 100,
                    )),
                const SizedBox(
                  height: 10,
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const SizedBox(height: 25),
                  // Username TextField
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.person_2_outlined),
                        hintText: 'Username',
                        hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Email TextField
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.email_outlined),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        hintText: 'Email',
                        hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Password TextField
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.remove_red_eye),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Confirm Password TextField
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.remove_red_eye),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                        ),
                        hintText: 'Confirm Password',
                        hintStyle: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  // Role Dropdown
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius:  const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(color: Colors.black)
                      ),
                      child: DropdownButton<String>(
                        value: selectedRole,
                        isExpanded: true,
                        underline: const SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRole = newValue!;
                          });
                        },
                        items: <String>['Citizen', 'Police', 'Judge']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 125, 41, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text('Register'),
                    ),
                  ),
                ]),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.black),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
