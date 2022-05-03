import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_first_app/firebase_login/auth.dart';
import 'package:my_first_app/source/application_bloc.dart';

import 'package:my_first_app/screen/splashScreen.dart';
import 'package:my_first_app/source/constats.dart';
import 'package:provider/provider.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const Myapp());
}

class Myapp extends StatelessWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (BuildContext context) => Auth(),
      child: ChangeNotifierProvider(
        create: (context) => Applicationbloc(),
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Site Data",
            theme: ThemeData(
                primaryColor: kprimaryColor,
                textTheme:
                    GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)),
            home: SplashScreen(
              auth: Auth(),
            )),
      ),
    );
  }
}
