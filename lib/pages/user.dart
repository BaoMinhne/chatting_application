import 'package:chatting_application/pages/home.dart';
import 'package:chatting_application/pages/onboarding.dart';
import 'package:chatting_application/services/auth.dart';
import 'package:chatting_application/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  String? name, image, email, username, id;

  getthedatafromsharedpref() async {
    name = await SharedPreferenceHelper().getUserDisplayName();
    image = await SharedPreferenceHelper().getUserImage();
    email = await SharedPreferenceHelper().getUserEmail();
    username = await SharedPreferenceHelper().getUserUsername();

    setState(() {});
  }

  getontheload() async {
    await getthedatafromsharedpref();
  }

  late AnimationController _controller;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    getontheload();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.8), // 👈 từ trên xuống
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // chạy animation sau 300ms
    Future.delayed(Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2B9DD),
      body: Container(
        margin: EdgeInsets.only(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.75,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Center(
                    child: Material(
                      elevation: 9.0,
                      borderRadius: BorderRadius.circular(40.0),
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 30, right: 30),
                        decoration: BoxDecoration(
                          color: Color(0xFFEADAED),
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: Text("User's Profile",
                            style: TextStyle(
                              color: Color(0xFF0C1A58),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: GestureDetector(
                onTap: () async {
                  // final newImageUrl =
                  //     await CloudinaryService.selectAndUploadImage();
                  // if (newImageUrl != null) {
                  //   setState(() {
                  //     image = newImageUrl; // cập nhật ảnh mới
                  //   });
                  // }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.network(
                    image ?? 'https://via.placeholder.com/150',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            _slideAnimation == null
                ? SizedBox() // hoặc Container()
                : SlideTransition(
                    position: _slideAnimation!,
                    child: Center(
                      child: Text(
                        "Hello, " + name!,
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: 15),
            Center(
              child: Text(
                "\"Be yourself - that's the best thing!!\"",
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Thông tin người dùng
            userInfoTile(
              context: context,
              title: "Name",
              value: name!,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final nameController = TextEditingController(text: name);
                    return AlertDialog(
                      title: Text("Edit Name"),
                      content: TextField(
                        controller: nameController,
                        decoration: InputDecoration(hintText: "Enter new name"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final newName = nameController.text.trim();
                            if (newName.isNotEmpty && newName != name) {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                id = await SharedPreferenceHelper().getUserId();
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(id)
                                    .update({
                                  'Name': newName,
                                });
                                await SharedPreferenceHelper()
                                    .saveUserDisplayName(newName);
                                setState(() {
                                  name = newName;
                                });
                              }
                            }
                            Navigator.pop(context);
                          },
                          child: Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            userInfoTile(context: context, title: "Email", value: email!),
            userInfoTile(context: context, title: "Username", value: username!),

            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 40, right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFFB03A5B),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      AuthMethods().signOut(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Onboarding(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text("Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget userInfoTile({
  required BuildContext context,
  required String title,
  required String value,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 20, right: 15),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFEADAED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Color(0xFF0C1A58),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: Color(0xFF0C1A58),
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ],
          ),
          Icon(Icons.edit, color: Color(0xFF416CC2)),
        ],
      ),
    ),
  );
}
