class UserModel {
  String? fullname;
  String? uid;
  String? email;
  String? profilepic;
  Map<String, dynamic>? file;

  UserModel({this.uid, this.email, this.fullname, this.profilepic, this.file});

  UserModel.fromMap(Map<String, dynamic> map) {
    fullname = map["fullname"];
    uid = map["uid"];
    email = map["email"];
    profilepic = map["profilepic"];
    file = map["file"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "file": file,
    };
  }
}
