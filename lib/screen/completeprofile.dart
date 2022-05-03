import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:my_first_app/firebase_login/auth.dart';
import 'package:my_first_app/modul/UserModel.dart';

import 'package:my_first_app/screen/homes_main.dart';
import 'package:my_first_app/source/constats.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final Baseauth auth;

  const CompleteProfile({Key? key, required this.userModel, required this.auth})
      : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile>
    with TickerProviderStateMixin {
  final TextEditingController userNamecontroller = TextEditingController();

  late AnimationController animationController1;
  late Animation<double> fadeAnimation;
  @override
  void initState() {
    super.initState();
    animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController1, curve: Curves.easeOut));

    animationController1.forward();
  }

  @override
  void dispose() {
    animationController1.dispose();
    super.dispose();
  }

  void updatedata() async {
    String? fullname = userNamecontroller.text.trim();
    widget.userModel.fullname = fullname;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap());

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HomeMain(
                  auth: widget.auth,
                  userModel: widget.userModel,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        "ENTER USERNAME",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: kprimaryColor.withAlpha(50)),
                      child: TextFormField(
                        controller: userNamecontroller,
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Username Not empty")
                        ]),
                        decoration: const InputDecoration(
                          prefixIcon:
                              Icon(Icons.account_circle, color: kprimaryColor),
                          border: InputBorder.none,
                          hintText: "Username",
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoButton(
                      color: kprimaryColor,
                      child: const Text("Submit"),
                      onPressed: updatedata,
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
