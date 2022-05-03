// ignore_for_file: constant_identifier_names

import 'dart:core';
import 'dart:ffi';

import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';

import 'package:flutter/foundation.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:my_first_app/firebase_login/auth.dart';
import 'package:my_first_app/firebase_login/firebasefile.dart';
import 'package:my_first_app/modul/UserModel.dart';

import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:my_first_app/screen/dataload.dart';

import 'package:my_first_app/screen/login_page.dart';
import 'package:my_first_app/source/UIhelper.dart';
import 'package:my_first_app/source/constats.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({
    Key? key,
    required this.auth,
    required this.userModel,
  }) : super(key: key);

  final Baseauth auth;
  final UserModel userModel;

  @override
  State<HomeMain> createState() => _HomeMainState();
}

enum Filesatus { isempty, isAvalible, isNotavalible }

class _HomeMainState extends State<HomeMain> with TickerProviderStateMixin {
  late AnimationController animationController;
  final TextEditingController controllerpastelink = TextEditingController();
  late Animation<double> fadeAnimation;
  Filesatus _filesatus = Filesatus.isempty;
  User? user = FirebaseAuth.instance.currentUser;
  String? username;
  String? email;

  String? photo;

  final fb = FacebookLogin();
  File? newFile;
  String path = "";

  late Future<List<dynamic>?> futurfile;

  checkFile() async {
    if (user != null) {
      setState(() {
        email = user!.email;
        photo = user!.photoURL;

        username = widget.userModel.fullname;

        Map<String, dynamic>? file = widget.userModel.file;

        if (file!.isNotEmpty) {
          setState(() {
            futurfile = files(user!);

            _filesatus = Filesatus.isAvalible;
          });
        } else {
          _filesatus = Filesatus.isNotavalible;
        }
      });
    } else {
      _filesatus = Filesatus.isempty;
      _signout();
    }
  }

  Future<List> files(User user) async {
    String userID = user.uid;
    List file = [];

    DocumentSnapshot<Map<String, dynamic>> data =
        await FirebaseFirestore.instance.collection("users").doc(userID).get();
    Map<String, dynamic>? userMap = data.data();

    UserModel userModel = UserModel.fromMap(userMap!);
    Map<String, dynamic> filedata = userModel.file!;
    filedata.entries.map((e) => file.add({e.key: e.value})).toList();

    return file;
  }

  @override
  void initState() {
    super.initState();

    checkFile();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  void _openFileExplorer(PlatformFile file) {
    OpenFile.open(file.path!);
  }

  Future uploadFile(File? newFile, UserModel userModel) async {
    if (newFile != null) {
      final fileName = 'files/${newFile.path.split("/").last}';
      await FirebaseApi.uploadFile(
        fileName,
        newFile,
        widget.userModel,
      );
    }
  }

  Future<File> saveFilePermanetly(PlatformFile file) async {
    final appStorage = await getApplicationDocumentsDirectory();
    print("$appStorage +1");
    newFile = File('${appStorage.path}/${file.name}');

    return File(file.path!).copy(newFile!.path);
  }

  void _signout() async {
    try {
      await widget.auth.signOut();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => LoginPage(auth: widget.auth)));
    } catch (e) {
      print(e);
    }
  }

  Future<void> filepiker() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) {
      return;
    }

    final file = result.files.first;

    if (file.extension == "xlsx" || file.extension == "xls") {
      UIHelper.showLoadingDialog(context, "Loading...");

      _openFileExplorer(file);

      newFile = await saveFilePermanetly(file);
      path = newFile!.path;

      await uploadFile(newFile, widget.userModel).whenComplete(
          () => Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (BuildContext context) {
                  return super.widget;
                },
              )));
    } else {
      const snackbar = SnackBar(
        backgroundColor: Colors.red,
        content: Text("Wrong File selected"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kprimaryColor,
            title: const Text("Welcome",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            centerTitle: true,
          ),
          drawer: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20))),
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          (photo != null)
                              ? Container(
                                  margin: const EdgeInsets.only(
                                      top: 30, bottom: 10),
                                  height: 70,
                                  width: 70,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      photo!,
                                    ),
                                  ),
                                )
                              : Container(
                                  margin: const EdgeInsets.only(
                                      top: 30, bottom: 10),
                                  height: 70,
                                  width: 70,
                                  child: CircleAvatar(
                                    child: Icon(Icons.person, size: 70),
                                  ),
                                ),
                          Text(
                            "$username",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "$email",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.arrow_back),
                    title: const Text(
                      "Logout",
                      style: TextStyle(fontSize: 18),
                    ),
                    onTap: _signout,
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: (_filesatus == Filesatus.isempty)
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: (_filesatus == Filesatus.isNotavalible)
                        ? FadeTransition(
                            opacity: fadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15, top: 10),
                                  child: InkWell(
                                    onTap: filepiker,
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: kprimaryColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Add  Data",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 15, top: 10),
                                  child: InkWell(
                                    onTap: () async {
                                      final Future<ConfirmAction?> action =
                                          await _linkAdd(
                                        context,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: kprimaryColor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Add Data Link",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : FutureBuilder<List<dynamic>?>(
                            future: futurfile,
                            builder: (context, snapshot) {
                              final files = snapshot.data;
                              return files == null
                                  ? const CircularProgressIndicator()
                                  : FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                Map<String, dynamic> file =
                                                    files[index];
                                                return _animatedBox(file);
                                              },
                                              itemCount: files.length,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 15, top: 10),
                                              child: InkWell(
                                                onTap: filepiker,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: kprimaryColor,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 20),
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "Add More Data",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 15, top: 10),
                                              child: InkWell(
                                                onTap: () async {
                                                  final Future<ConfirmAction?>
                                                      action = await _linkAdd(
                                                    context,
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: kprimaryColor,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 20),
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "Add Data Link",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                            }),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _animatedBox(Map<String, dynamic> file) {
    return Bounceable(
      scaleFactor: 0.8,
      onTap: (() async {
        await Future.delayed(const Duration(milliseconds: 500), () {});
        UIHelper.showLoadingDialog(context, "Loading....");
        HttpClient httpClient = HttpClient();
        print(file.values.first);
        final request = await httpClient.getUrl(Uri.parse(file.values.first));

        var response = await request.close();
        var bytes = await consolidateHttpClientResponseBytes(response);

        String dir = (await getApplicationDocumentsDirectory()).path;
        File newFile1 = File('$dir/${file.keys.first}');
        await newFile1.writeAsBytes(bytes);
        try {
          var byte = File(newFile1.path).readAsBytesSync();
          var excel = Excel.decodeBytes(byte);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => DataLoadType(
                        data: newFile1,
                        auth: widget.auth,
                        user: user as User,
                      )));
        } on Exception catch (e) {
          print(e);
          const snackbar = SnackBar(
            backgroundColor: Colors.red,
            content: Text("Wrong  Formatted Sheet Need To Check"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
          Navigator.pop(context);
        }
      }),
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: 250,
        width: 400,
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/excel4.png"),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(
                  5.0,
                  5.0,
                ),
                blurRadius: 20.0,
                spreadRadius: 4.0,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(0.0, 0.0),
                blurRadius: 0.0,
                spreadRadius: 0.0,
              ),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () async {
                  final box = context.findRenderObject() as RenderBox?;
                  final String url = "${file.values.first}";
                  await Share.share("${file.keys.first}\n\n $url",
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size);
                },
                child: const Image(
                  color: Colors.white,
                  width: 30,
                  height: 40,
                  image: AssetImage("assets/images/Share-PNG-Photo.png"),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file.keys.first.toUpperCase(),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 94, 88, 88),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              email!,
                              softWrap: true,
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 138, 131, 131),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final Future<ConfirmAction?> action =
                            await _asyncConfirmDialog(
                          context,
                          file,
                        );
                      },
                      child: const Icon(
                        Icons.delete_sharp,
                        size: 30,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  Future<Future<ConfirmAction?>> _asyncConfirmDialog(
    BuildContext context,
    Map<String, dynamic> file,
  ) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete This File?'),
          content: const Text('This will delete the File from your Data.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.Cancel);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                UserModel usernew = widget.userModel;

                usernew.file!.remove(file.keys.first);

                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(usernew.uid!)
                    .update(usernew.toMap())
                    .whenComplete(() {
                  Navigator.of(context).pop(ConfirmAction.Accept);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                });
              },
            )
          ],
        );
      },
    );
  }

  Future<Future<ConfirmAction?>> _linkAdd(
    BuildContext context,
  ) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please Paste Link'),
          content: Form(
            key: _form,
            child: TextFormField(
              validator: RequiredValidator(errorText: "URL Empty "),
              controller: controllerpastelink,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                controllerpastelink.clear();
                Navigator.of(context).pop(ConfirmAction.Cancel);
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () async {
                if (_form.currentState!.validate()) {
                  UIHelper.showLoadingDialog(context, "Loading...");
                  String url = controllerpastelink.text.split("::").first;
                  String filename = controllerpastelink.text.split("::").last;
                  UserModel usernew = widget.userModel;

                  usernew.file!.addEntries({filename: url}.entries);

                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(usernew.uid!)
                      .update(usernew.toMap())
                      .whenComplete(() {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget));
                  });
                  controllerpastelink.clear();

                  Navigator.of(context).pop(ConfirmAction.Accept);
                }
              },
            )
          ],
        );
      },
    );
  }
}

enum ConfirmAction { Cancel, Accept }
