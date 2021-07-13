import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:microsoft_clone/screens/profile_screen.dart';
import 'package:microsoft_clone/screens/search_screen.dart';
import 'package:microsoft_clone/services/database.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:microsoft_clone/utils/utils.dart';
import 'package:microsoft_clone/variables.dart';
import '../main.dart';
import 'chat_room.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currentUserId="";
  String initials="";
  String currentUsername="";
  final GoogleSignIn googleSignIn = GoogleSignIn();
  DatabaseMethods databaseMethods = DatabaseMethods();
  late QuerySnapshot searchSnapshot;
  late QuerySnapshot chatSnapshot;

  TextEditingController searchTextEditingController = TextEditingController();
  late Future<QuerySnapshot> futureSearchResults;

  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Fluttertoast.showToast(msg:"Logout Successful !");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (
        Route<dynamic> route) => false);
  }

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await FirebaseAuth.instance.currentUser!;
    return currentUser;
  }

  Widget chatRoomsList() {
    return chatSnapshot.docs.length!=0 ? ListView.builder(
      itemCount: chatSnapshot.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
      return ChatTile(
        photourl: chatSnapshot.docs[index]['senderPhotoUrl'],
        userName: chatSnapshot.docs[index]['senderName'],
        userId: chatSnapshot.docs[index]['senderId'],
        userEmail: chatSnapshot.docs[index]['receiverEmail'],
        chatId: chatSnapshot.docs[index]["chatId"],
        lastMsg: chatSnapshot.docs[index]["lastMessage"],
      );
    }):Container(
      child: Center(child: Text(" No Conversations!",style: appStyle(25,Colors.white),)),
    );
  }

  initiateSearch() {
    databaseMethods.queryData(searchTextEditingController.text).then((value){
      setState(() {
        searchSnapshot = value;
      });
    });
  }
  @override
  void initState(){
    getCurrentUser().then((user){
      setState(() {
        currentUserId = user.uid;
        currentUsername = user.displayName!;
        initials = Utils.getInitials(user.displayName!);
        print(initials);
      });
      databaseMethods.queryConversation(currentUserId).then((value){
        print("Printing chatSnapshot value");
        print(value);
        setState(() {
          chatSnapshot = value;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorVariables.homePageTheme,
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.black),
        title: Text(" Chats",style: appStyle(20,Colors.black)) ,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              tooltip: "Search Users",
              onPressed: (){
                initiateSearch();
                Navigator.push(context,MaterialPageRoute(
                  builder: (context)=>SearchScreen()
                ));
              },
              icon: FaIcon(FontAwesomeIcons.search,color: Colors.black,size: 20,)
          ),
          InkWell(
            // on clicking this, user will be directed to the profile section
            child: UserCircle(initials),
            onTap: (){
              Navigator.push(context, MaterialPageRoute(
                          builder: (context) => Profile()));
            },
          ),
          IconButton(
              onPressed: logoutUser,
            tooltip: "Logout",
            icon: FaIcon(FontAwesomeIcons.signOutAlt, color: Colors.black,),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white54,
        onPressed: () {
          print("pressed");
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => SearchScreen()));
        },
        tooltip: "Start New Chat",
        child:FaIcon(FontAwesomeIcons.userPlus,color: Colors.yellowAccent,size: 25,),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(3, 30, 10, 3),
        child: chatRoomsList(),
      ),
    );
  }

}

class ChatTile extends StatelessWidget {
  final String userName;
  final String chatId;
  final String userEmail;
  final String photourl;
  final String userId;
  final String lastMsg;
  ChatTile({required this.userName,required this.chatId, required this.userEmail, required this.photourl, required this.userId,required this.lastMsg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height/40,vertical: 3),
      child: Container(
        child: Column(
          children:<Widget> [
            GestureDetector(
              onTap: (){
                  // pushes the user to the chatRoom Screen and finally pushReplacement is done
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>Chat(
                        receiverId:userId,
                        receiverEmail: userEmail,
                        receiverName:userName,
                        receiverAvatar: photourl,
                      )
                  ));
              },
              child: ListTile(
                hoverColor: Colors.white54,
                selectedTileColor: Colors.white54,
                tileColor: Colors.white10,
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(photourl),
                ),
                title:Text(userName,style: appStyle(17,Colors.black,FontWeight.w500)),
                subtitle: Text(lastMsg,style: appStyle(14,Colors.black54,FontWeight.w500,FontStyle.italic)),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 2,
                    color:Colors.black12))),
      ),
    );
  }
}

class UserCircle extends StatelessWidget {
  final String text;

  UserCircle(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: colorVariables.blackColor, width: 1),
        color: colorVariables.separatorColor,
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
          // color: Colors.white30,
          borderRadius: BorderRadius.circular(50)),
      child: FaIcon(FontAwesomeIcons.userPlus,color: Colors.yellowAccent,size: 32,),
      padding: EdgeInsets.all(10),
    );
  }
}



