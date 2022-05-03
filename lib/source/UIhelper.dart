// ignore: file_names
import 'package:flutter/material.dart';

class UIHelper {
  static void showLoadingDialog(BuildContext context, String titel) {
    AlertDialog loadingdialog = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(
            height: 30,
          ),
          Text(titel)
        ],
      ),
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return loadingdialog;
        });
  }
}
