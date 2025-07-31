import 'package:chatting_application/pages/chat_page.dart';
import 'package:chatting_application/pages/user.dart';
import 'package:chatting_application/services/database.dart';
import 'package:chatting_application/services/shared_pref.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? myUsername, myName, myEmail, myPicture;
  TextEditingController messageController = new TextEditingController();
  Stream? chatRoomStream;
  bool isLoading = true;

  getDataFromSharePref() async {
    myName = await SharedPreferenceHelper().getUserDisplayName();
    myUsername = await SharedPreferenceHelper().getUserUsername();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myPicture = await SharedPreferenceHelper().getUserImage();
  }

  getChatRoomIdByUsername(String a, String b) {
    if (a.compareTo(b) > 0) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  onTheLoad() async {
    await getDataFromSharePref();
    chatRoomStream = await DatabaseMethods().getChatRooms();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    onTheLoad();
    super.initState();
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds["lastMessage"],
                        myUsername: myUsername!,
                        time: ds["lastMessageSendTs"]);
                  })
              : Container();
        });
  }

  TextEditingController searchController = new TextEditingController();
  Stream<QuerySnapshot>? searchResult;

  void onSearchResult(String text) async {
    if (text.isNotEmpty) {
      final stream = await DatabaseMethods().onSearch(text);
      setState(() {
        searchResult = stream;
      });
    } else {
      setState(() {
        searchResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(0xff703eff),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xff703eff),
      body: Container(
        margin: EdgeInsets.only(
          top: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/wave.png",
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('Hello, ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(myName ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Color(0xff703eff),
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('Welcome To',
                  style: TextStyle(
                    color: const Color.fromARGB(194, 255, 255, 255),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('Chat Box',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 30, right: 20),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFececf8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchResult,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search for contact...",
                          hintStyle: TextStyle(fontSize: 16),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: searchResult != null
                          ? SearchResultCard()
                          : chatRoomList(),
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

  Widget SearchResultCard() {
    return StreamBuilder(
      stream: searchResult,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs.where((doc) {
          return doc["Username"] !=
              myUsername?.toUpperCase(); // ⚠️ Lọc chính mình
        }).toList();

        if (docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("No Users Found...",
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var user = docs[index];
            return GestureDetector(
              onTap: () async {
                var chatRoomId =
                    getChatRoomIdByUsername(myUsername!, user["Username"]);
                Map<String, dynamic> chatInfoMap = {
                  "Users": [myUsername, user["Username"]],
                };
                await DatabaseMethods().createChatRoom(chatRoomId, chatInfoMap);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                          name: user["Name"],
                          profileUrl: user["Image"],
                          username: user["Username"]),
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Material(
                  elevation: 6.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            user["Image"],
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            Text(user["Name"],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                )),
                            Text(user["Email"],
                                style: TextStyle(
                                  color: const Color.fromARGB(151, 0, 0, 0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  String lastMessage, chatRoomId, myUsername, time;
  ChatRoomListTile({
    required this.chatRoomId,
    required this.lastMessage,
    required this.myUsername,
    required this.time,
  });

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profileImageUrl = "", name = "", username = "", id = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.split("_").firstWhere((u) => u != widget.myUsername);
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    if (querySnapshot.docs.isNotEmpty) {
      name = querySnapshot.docs[0]["Name"];
      profileImageUrl = querySnapshot.docs[0]["Image"];
      id = querySnapshot.docs[0]["Id"];
      if (mounted) {
        setState(() {});
      }
    } else {
      print("Không lấy được dữu liệu");
    }
  }

  @override
  void initState() {
    super.initState();
    getThisUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                    name: name,
                    profileUrl: profileImageUrl,
                    username: username)));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Material(
          elevation: 6.0,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: profileImageUrl.isEmpty
                      ? Image.asset(
                          "assets/images/boy.jpg",
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          profileImageUrl,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 15),

                // Nội dung chính: tên và tin nhắn
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.lastMessage,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color.fromARGB(151, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Thời gian ở góc phải
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    widget.time,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
