// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/firebase_login/auth.dart';
import 'package:my_first_app/modul/UserModel.dart';

import 'package:my_first_app/screen/completeprofile.dart';
import 'package:my_first_app/screen/homes_main.dart';
import 'package:my_first_app/screen/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.auth}) : super(key: key);
  final Baseauth auth;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _oversplash();
  }

  _oversplash() async {
    await Future.delayed(const Duration(milliseconds: 3500));

    widget.auth.currentUser().then((userId) async {
      if (userId != null) {
        DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
            .instance
            .collection("users")
            .doc(userId)
            .get();

        Map<String, dynamic>? userMap = data.data();

        UserModel userModel = UserModel.fromMap(userMap!);
        print(userModel.fullname!.length);

        if (userModel.fullname!.isNotEmpty) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: ((BuildContext context) => HomeMain(
                        auth: widget.auth,
                        userModel: userModel,
                      ))));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext conext) => CompleteProfile(
                        userModel: userModel,
                        auth: widget.auth,
                      )));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return LoginPage(
              auth: widget.auth,
            );
          },
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Image(image: AssetImage("assets/images/SpalashScreen.jpg")),
                SizedBox(
                  height: 10,
                ),
                Image(
                  image: AssetImage("assets/images/nameplat.png"),
                ),
              ],
            ),
          )),
    );
  }
}
