import 'package:chatting_application/pages/home.dart';
import 'package:chatting_application/services/database.dart';
import 'package:chatting_application/services/shared_pref.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    // await googleSignIn.signOut(); // khi nào có chức năng đăng xuất thì xóa
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userDetails = result.user;
    String username = userDetails!.email!.replaceAll("@gmail.com", "");
    String firstLetter = username.substring(0, 1).toUpperCase();
    await SharedPreferenceHelper()
        .saveUserDisplayName(userDetails.displayName!);
    await SharedPreferenceHelper().saveUserEmail(userDetails.email!);
    await SharedPreferenceHelper().saveUserImage(userDetails.photoURL!);
    await SharedPreferenceHelper().saveUserId(userDetails.uid);
    await SharedPreferenceHelper().saveUserUsername(username.toUpperCase());

    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "Name": userDetails.displayName,
        "Email": userDetails.email,
        "Image": userDetails.photoURL,
        "Id": userDetails.uid,
        "Username": username.toUpperCase(),
        "SearchKey": firstLetter,
      };

      await DatabaseMethods()
          .addUser(userInfoMap, userDetails.uid)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Login Successful!",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      print("Đăng nhập thất bại");
    }
  }

  Future<void> signOut(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Đăng xuất khỏi Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Đăng xuất khỏi Google Sign-In (nếu đang dùng)
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Xoá dữ liệu từ SharedPreferences
      await SharedPreferenceHelper().clear();

      // Optional: Hiện thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
              child: Text(
            "Sign Out Succesfully!! See You Later",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Lỗi khi đăng xuất: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi khi đăng xuất",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
