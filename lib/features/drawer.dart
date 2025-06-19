// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jeas/features/email_field.dart';
import 'package:jeas/features/help_page.dart';
import 'package:jeas/screens/common_screens/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'password_field.dart';

class MyDrawer extends StatefulWidget {
  final String personality;

  const MyDrawer(this.personality, {super.key}); // Use super(key: key)

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController skills = TextEditingController();
  final TextEditingController birthday = TextEditingController();
  String personality = "";
  @override
  void initState() {
    personality = widget.personality;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.lightBlue[50],
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue),
            child: Text(
              "Manage Account",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          InkWell(
            child: const ListTile(
              title: Text(
                "Delete Account",
                style: TextStyle(fontSize: 16),
              ),
              leading: Icon(
                Icons.delete,
                size: 25,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Container(
                      height: 200,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Colors.blue[200],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Are you sure you want to delete your account?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: MaterialButton(
                                  onPressed: () async {
                                    if (FirebaseAuth.instance.currentUser !=
                                        null) {
                                      Navigator.pop(context);
                                      try {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  height: 400,
                                                  width: 300,
                                                  child: ListView(
                                                    children: [
                                                      const Text(
                                                          "Please enter your email and password correctly to delete the account"),
                                                      EmailField(
                                                          "Email",
                                                          _email,
                                                          "Enter E-mail"),
                                                      PasswordField(
                                                          "Password",
                                                          _password,
                                                          "Enter Password"),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          if (_email.text
                                                                  .isEmpty ||
                                                              _password.text
                                                                  .isEmpty) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    "Please fill in both email and password fields"),
                                                              ),
                                                            );
                                                            return; // Stop execution if fields are empty
                                                          }

                                                          await FirebaseAuth
                                                              .instance
                                                              .signInWithEmailAndPassword(
                                                                  email: _email
                                                                      .text,
                                                                  password:
                                                                      _password
                                                                          .text)
                                                              .then((_) async {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    personality)
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .delete();
                                                            try {
                                                              await FirebaseStorage
                                                                  .instance
                                                                  .ref()
                                                                  .child(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .delete();
                                                            } catch (e) {
                                                              print(
                                                                  "There is no image to delete ");
                                                            }

                                                            await FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .delete();
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    "Your Account has been Deleted"),
                                                              ),
                                                            );
                                                            Navigator
                                                                .pushReplacement(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const LoginPage(),
                                                              ),
                                                            );
                                                          }).catchError(
                                                                  (error) {
                                                            print(
                                                                "Error deleting account: $error");
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    "Failed to delete account. Please try again."),
                                                              ),
                                                            );
                                                          });
                                                        },
                                                        child:
                                                            const Text("Done"),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      } catch (e) {
                                        print(
                                            "we have a problem with deleting : $e");
                                      }
                                    } else {
                                      print("Account Dosent found");
                                    }
                                  },
                                  child: const Text(
                                    "Yes",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "No",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          InkWell(
            child: const ListTile(
              title: Text("User Manual"),
              leading: Icon(
                Icons.supervised_user_circle,
                size: 25,
              ),
            ),
            onTap: () {
              launch(
                  'https://docs.google.com/document/d/1y1-r_CMtYs2Y_5Q7UXEwrJ9D9XFe0gup/edit?usp=sharing&ouid=117308765157380655887&rtpof=true&sd=true');
            },
          ),
          InkWell(
            child: const ListTile(
              title: Text("Need Help"),
              leading: Icon(
                Icons.help,
                size: 25,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpPage(),
                  ));
            },
          ),
          InkWell(
            child: const ListTile(
              title: Text("Logout"),
              leading: Icon(
                Icons.logout,
                size: 25,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut().then((value) =>
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false));
            },
          )
        ],
      ),
    );
  }
}
