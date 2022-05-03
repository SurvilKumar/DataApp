import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_first_app/modul/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Baseauth {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password);
  Future<String?> currentUser();

  Future<void> signOut();

  Future<UserModel?> signInWithFacebook();
  Future<UserModel?> loginWithGoogle();
}

class Auth implements Baseauth {
  final fireAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithCreadiantial(AuthCredential credential) =>
      fireAuth.signInWithCredential(credential);

  @override
  signInWithEmailAndPassword(String email, String password) async {
    UserCredential user = await fireAuth.signInWithEmailAndPassword(
        email: email, password: password);
    String uid = user.user!.uid;

    DocumentSnapshot<Map<String, dynamic>> data =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    Map<String, dynamic>? userMap = data.data();
    UserModel userModel = UserModel.fromMap(userMap!);

    return userModel;
  }

  @override
  createUserWithEmailAndPassword(String email, String password) async {
    UserCredential credential = await fireAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    String uid = credential.user!.uid;

    UserModel newUser = UserModel(
        email: email, fullname: "", uid: uid, profilepic: "", file: {});
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(newUser.toMap());

    return newUser;
  }

  @override
  Future<String?> currentUser() async {
    User? user = fireAuth.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await fireAuth.signOut();
  }

  @override
  Future<UserModel?> signInWithFacebook() async {
    UserModel? userModel;
    final fb = FacebookLogin(debug: true);

    try {
      final response = await fb.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);

      switch (response.status) {
        case FacebookLoginStatus.success:
          final FacebookAccessToken? fbtoken = response.accessToken;
          final AuthCredential credential =
              FacebookAuthProvider.credential(fbtoken!.token);

          UserCredential facebookCredential =
              await fireAuth.signInWithCredential(credential);

          String uid = facebookCredential.user!.uid;

          DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
              .instance
              .collection("users")
              .doc(uid)
              .get();

          if (data.exists) {
            Map<String, dynamic>? userMap = data.data();
            userModel = UserModel.fromMap(userMap!);
          } else {
            UserModel newUser = UserModel(
                email: facebookCredential.user!.email,
                fullname: facebookCredential.user!.displayName,
                uid: uid,
                profilepic: facebookCredential.user!.photoURL,
                file: {});
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .set(newUser.toMap());
          }

          return userModel;

        case FacebookLoginStatus.cancel:
          throw FirebaseAuthException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
        case FacebookLoginStatus.error:
          throw FirebaseAuthException(
            code: 'ERROR_FACEBOOK_LOGIN_FAILED',
            message: response.error!.developerMessage,
          );
        default:
          throw UnimplementedError();
      }
    } on Exception catch (e) {
      print(e);
    }
    return userModel;
  }

  @override
  Future<UserModel?> loginWithGoogle() async {
    UserModel? userModel;

    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ]);

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await fireAuth.signInWithCredential(credential);

          String uid = userCredential.user!.uid;

          DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
              .instance
              .collection("users")
              .doc(uid)
              .get();

          if (data.exists) {
            Map<String, dynamic>? userMap = data.data();
            userModel = UserModel.fromMap(userMap!);
          } else {
            userModel = UserModel(
                email: userCredential.user!.email,
                fullname: userCredential.user!.displayName,
                uid: uid,
                profilepic: userCredential.user!.photoURL,
                file: {});
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .set(userModel.toMap());
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            // handle the error here
          } else if (e.code == 'invalid-credential') {
            // handle the error here
          }
        } on Exception catch (e) {
          print(e);
          // handle the error here
        }
      }
    } catch (e) {
      print(e);
    }

    return userModel;
  }
}
