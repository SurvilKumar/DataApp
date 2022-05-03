import 'package:flutter/material.dart';
import 'package:my_first_app/firebase_login/Sociallogin.dart';

import 'package:my_first_app/firebase_login/auth.dart';

import 'package:my_first_app/modul/UserModel.dart';

import 'package:my_first_app/screen/resetpassword.dart';
import 'package:my_first_app/screen/completeprofile.dart';
import 'package:my_first_app/screen/homes_main.dart';
import 'package:my_first_app/source/constats.dart';
import 'package:sign_button/sign_button.dart';

import 'package:form_field_validator/form_field_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
    required this.auth,
  }) : super(key: key);

  final Baseauth auth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isLogin = true;
  late Animation containerSize;
  late AnimationController animationController;
  late AnimationController animationController1;
  late Animation<double> fadeAnimation;
  Duration animationDuration = const Duration(milliseconds: 500);
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordConroller = TextEditingController();
  final TextEditingController _conPassConroller = TextEditingController();

  String? _email;

  String? _password;
  String error = "";

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: animationDuration);
    animationController1 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController1, curve: Curves.easeOut));

    animationController1.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    animationController1.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();

      return true;
    } else {
      return false;
    }
  }

  void validationandsubmit() async {
    if (_validate()) {
      try {
        if (isLogin) {
          UserModel euser =
              await widget.auth.signInWithEmailAndPassword(_email!, _password!);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext conext) => HomeMain(
                        auth: widget.auth,
                        userModel: euser,
                      )));
        } else {
          UserModel? userModel = await widget.auth
              .createUserWithEmailAndPassword(_email!, _password!);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext conext) => CompleteProfile(
                        userModel: userModel!,
                        auth: widget.auth,
                      )));
        }
      } catch (e) {
        if (e.toString().contains("no user")) {
          setState(() {
            error = "No User Found Please Sign Up";
          });
        }
        if (e.toString().contains("The email address is badly formatted")) {
          setState(() {
            error = "Wrong Email Id";
          });
        }
        if (e.toString().contains("The password is invalid")) {
          setState(() {
            error = "Wrong Password";
          });
        }
        if (e.toString().contains(
            "The email address is already in use by another account")) {
          setState(() {
            error = "Account Exist ,Please Sign In or Reset Password";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double viewInset = MediaQuery.of(context).viewInsets.bottom;
    double defultRegisterSize = size.height - (size.height * 0.1);
    containerSize = Tween<double>(
            begin: size.height * 0.07, end: defultRegisterSize)
        .animate(
            CurvedAnimation(parent: animationController, curve: Curves.linear));

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Visibility(
              visible: isLogin,
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 70),
                          child: Text(
                            " Welcome Back ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 120,
                      ),
                      // const Image(
                      //   image: AssetImage("assets/images/execel2.jpg"),
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: Container(
                          width: size.width * 0.8,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kprimaryColor.withAlpha(50)),
                          child: TextFormField(
                            controller: _emailController,
                            validator: MultiValidator([
                              EmailValidator(errorText: "enter valid mail id"),
                              RequiredValidator(errorText: "Username empty")
                            ]),
                            onSaved: (value) {
                              _email = value;
                              _validate;
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              border: InputBorder.none,
                              hintText: "Username",
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: Container(
                          width: size.width * 0.8,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kprimaryColor.withAlpha(50)),
                          child: TextFormField(
                            validator:
                                RequiredValidator(errorText: "Password empty"),
                            controller: _passwordConroller,
                            obscureText: true,
                            onSaved: (value) {
                              _password = value;
                            },
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              border: InputBorder.none,
                              hintText: "Password",
                            ),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: InkWell(
                          onTap: validationandsubmit,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kprimaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            alignment: Alignment.center,
                            child: const Text(
                              "Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      (error != null)
                          ? Center(
                              child: Text(
                                error,
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.key_sharp,
                                color: Colors.black54,
                              ),
                              Text(
                                "Remember Me",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const ResetPassword()));
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 5,
                      ),
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: Center(
                          child: Text("-------------OR------------",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: fadeAnimation,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SignInButton.mini(
                                  buttonType: ButtonType.facebook,
                                  onPressed: () {
                                    LoginBased().fbsubmit(widget.auth, context);
                                  }),
                              SignInButton.mini(
                                  buttonType: ButtonType.google,
                                  onPressed: () {
                                    LoginBased().gsubmit(widget.auth, context);
                                  }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                if (viewInset == 0 && isLogin) {
                  return buildresterContainer();
                } else if (!isLogin) {
                  return buildresterContainer();
                }
                return Container();
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildresterContainer() {
    Size size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: containerSize.value,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          color: kprimaryColor.withAlpha(50),
        ),
        child: isLogin
            ? Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    animationController.forward();

                    setState(() {
                      isLogin = !isLogin;
                      _emailController.clear();
                      _passwordConroller.clear();
                      error = "";
                    });
                  },
                  child: const Text(
                    "Don't have account,Sign Up",
                    style: TextStyle(fontSize: 18, color: kprimaryColor),
                  ),
                ),
              )
            : Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          alignment: Alignment.topCenter,
                          onPressed: () {
                            animationController.reverse();
                            setState(() {
                              isLogin = !isLogin;
                              _passwordConroller.clear();
                              _emailController.clear();
                              _conPassConroller.clear();
                              error = "";
                            });
                          },
                          color: kprimaryColor,
                          icon: const Icon(Icons.cancel)),
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        " Welcome ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                      ),
                      // Image(
                      //   // width: 300,
                      //   // height: 300,
                      //   image: AssetImage(
                      //     "assets/images/execel2.jpg",
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 30,
                      // ),
                      Container(
                        width: size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: kprimaryColor.withAlpha(50)),
                        child: TextFormField(
                          controller: _emailController,
                          validator: MultiValidator([
                            EmailValidator(errorText: "enter valid mail id"),
                            RequiredValidator(
                                errorText: "Email Should not empty")
                          ]),
                          onSaved: (value) {
                            _email = value;
                            _validate;
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            border: InputBorder.none,
                            hintText: "Email",
                          ),
                        ),
                      ),
                      Container(
                        width: size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: kprimaryColor.withAlpha(50)),
                        child: TextFormField(
                          controller: _passwordConroller,
                          validator: MinLengthValidator(8,
                              errorText: "Min 8 Char Password required "),
                          obscureText: true,
                          onSaved: (value) {
                            _password = value;
                            _validate;
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            // fillColor: Colors.grey.shade100,

                            border: InputBorder.none,
                            hintText: "Password",
                          ),
                        ),
                      ),
                      Container(
                        width: size.width * 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: kprimaryColor.withAlpha(50)),
                        child: TextFormField(
                          obscureText: true,
                          controller: _conPassConroller,
                          validator: (val) => MatchValidator(
                                  errorText: 'passwords do not match')
                              .validateMatch(
                                  val.toString(), _passwordConroller.text),
                          onSaved: (value) {
                            _validate;
                          },
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            // fillColor: Colors.grey.shade100,
                            // filled: true,
                            border: InputBorder.none,
                            hintText: "Confirm Password",
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          validationandsubmit();
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: kprimaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          alignment: Alignment.center,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          child: error == null || isLogin
                              ? null
                              : Text(
                                  error,
                                  style: const TextStyle(color: kprimaryColor),
                                )),
                      Center(
                        child: Text("-------------OR------------",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SignInButton.mini(
                              buttonType: ButtonType.facebook,
                              onPressed: () {
                                try {
                                  LoginBased().fbsubmit(widget.auth, context);
                                } catch (e) {
                                  print(e);
                                  setState(() {
                                    error = e.toString();
                                  });
                                }
                              }),
                          SignInButton.mini(
                              buttonType: ButtonType.google,
                              onPressed: () {
                                try {
                                  LoginBased().gsubmit(widget.auth, context);
                                } catch (e) {
                                  setState(() {
                                    error = e.toString();
                                  });
                                }
                              }),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
