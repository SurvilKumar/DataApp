import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:my_first_app/source/constats.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>
    with TickerProviderStateMixin {
  final TextEditingController resetpassword = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

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

  Future resetpasswoord(String email) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.sendPasswordResetEmail(email: email);

      const snackBar = SnackBar(
        content: Text("Password Reset Link Sent Please Chek Email"),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print(e.toString());

      final snackbar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.message.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "RESET PASSWORD",
            style: TextStyle(
              color: Color.fromARGB(255, 233, 231, 231),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: kprimaryColor,
        ),
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 300,
                      child: Image(
                        image: AssetImage("assets/images/SpalashScreen.jpg"),
                      ),
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
                      child: Form(
                        key: _form,
                        child: TextFormField(
                          controller: resetpassword,
                          validator: MultiValidator([
                            EmailValidator(errorText: "Wrong Email Address "),
                            RequiredValidator(
                                errorText: "Field Should Not Empty")
                          ]),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.account_circle,
                                color: kprimaryColor),
                            border: InputBorder.none,
                            hintText: "Email Address",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoButton(
                      color: kprimaryColor,
                      child: const Text("SENT LINK"),
                      onPressed: () {
                        if (_form.currentState!.validate()) {
                          resetpasswoord(resetpassword.text.trim());
                        }
                      },
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
