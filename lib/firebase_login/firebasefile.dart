import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_first_app/modul/UserModel.dart';

class FirebaseApi {
  static Future<UploadTask?> uploadFile(
    String fileName,
    File file,
    UserModel userModel,
  ) async {
    try {
      final UploadTask uploadTask =
          FirebaseStorage.instance.ref(fileName).putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;

      String fileurl = await taskSnapshot.ref.getDownloadURL();

      userModel.file!
          .addEntries({fileName.toString().split("/").last: fileurl}.entries);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userModel.uid)
          .set(userModel.toMap());

      // return uploadTask.pu
    } on Exception catch (e) {
      print(e);
      return null;
    }
    return null;
  }
}
