import 'package:flutter/material.dart';

import 'package:my_first_app/firebase_login/auth.dart';
import 'package:my_first_app/modul/UserModel.dart';
import 'package:my_first_app/screen/homes_main.dart';
import 'package:my_first_app/source/UIhelper.dart';

abstract class Login {
  Future<void> gsubmit(Baseauth auth, BuildContext context);
  Future<void> fbsubmit(Baseauth auth, BuildContext context);
}

class LoginBased implements Login {
  @override
  Future<void> gsubmit(
    Baseauth auth,
    BuildContext context,
  ) async {
    UIHelper.showLoadingDialog(context, "Loading....");
    UserModel? gmodel = await auth.loginWithGoogle();

    if (gmodel != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomeMain(
                    auth: auth,
                    userModel: gmodel,
                  )));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Future<void> fbsubmit(
    Baseauth auth,
    BuildContext context,
  ) async {
    // UIHelper.showLoadingDialog(context, "Loading....");
    UserModel? fmodel = await auth.signInWithFacebook();
    // print(fmodel);

    if (fmodel != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext conext) => HomeMain(
                    auth: auth,
                    userModel: fmodel,
                  )));
    } else {
      Navigator.pop(context);
    }
  }
}
