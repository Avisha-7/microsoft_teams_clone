import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:microsoft_clone/screens/chat_screen.dart';
import 'package:microsoft_clone/services/constants.dart';
import 'package:microsoft_clone/services/database.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:microsoft_clone/variables.dart';
import 'chat_room.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController  = new TextEditingController();
  late String currentUserId;
  late QuerySnapshot searchSnapshot;

  Widget searchList(){
    return searchSnapshot.docs.length!=0 ? SingleChildScrollView(
      child: ListView.builder(
        itemCount: searchSnapshot.docs.length,
          shrinkWrap: true,
          itemBuilder: (context, index){
          return SearchTile(
            userEmail: searchSnapshot.docs[index]['email'],
            userName: searchSnapshot.docs[index]['username'],
            photourl: searchSnapshot.docs[index]['photoUrl'],
            userId: searchSnapshot.docs[index]['id'],
            currentUserId: currentUserId,
          );
          }),
    )
        : Container();
  }


  initiateSearch() {
    databaseMethods.queryData(searchTextEditingController.text).then((value){
      setState(() {
        searchSnapshot = value;
      });
    });
  }

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await FirebaseAuth.instance.currentUser!;
    return currentUser;
  }

  @override
  void initState(){
    // currentUserId = FirebaseAuth.instance.currentUser!.uid;
    getCurrentUser().then((user){
      setState(() {
        currentUserId = user.uid;
      });
    });
    initiateSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF886CE4),
      child:SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              // SizedBox(height: 20,),
              Container(
                color: Colors.white54,
                padding: EdgeInsets.fromLTRB(10,50, 35, 16),
                child:
                Row(
                  children: [
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.chevronLeft,color: Colors.black54,),
                      onPressed: (){
                        Navigator.pop(context,true);
                        },
                    ),
                    Expanded(
                        child: TextFormField(
                          controller: searchTextEditingController,
                          style: appStyle(18,Colors.black,FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: "Search Username",
                            hintStyle: appStyle(18,Colors.black54,FontWeight.w500),
                            suffixIcon: IconButton(
                              icon: FaIcon(FontAwesomeIcons.times,color: Colors.black54,),
                              onPressed: () {
                                searchTextEditingController.clear();
                                },
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color:Colors.grey),),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: colorVariables.backgroundTheme),),
                          ),
                          onFieldSubmitted: initiateSearch(),
                        ),
                    ),
                  ],
                ),
              ),
              searchList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String photourl;
  final String userId;
  final String currentUserId;
  SearchTile({required this.userName,required this.userEmail, required this.photourl, required this.userId,required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height/40,vertical: 8),
      child: Container(
        child: Column(
          children:<Widget> [
            GestureDetector(
              onTap: (){
                if(userId!=currentUserId){
                  // pushes the user to the chatRoom Screen and finally pushReplacement is done
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context)=>Chat(
                        receiverId:userId,
                        receiverEmail: userEmail,
                        receiverName:userName,
                        receiverAvatar: photourl,
                      )
                  ));
                }else{
                  Fluttertoast.showToast(msg:"You cannot chat with yourself!");
                }
              },
              child: ListTile(
                hoverColor: Colors.white54,
                selectedTileColor: Colors.white54,
                tileColor: Colors.white10,
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(photourl),
                ),
                title:Text(userName,style: appStyle(16,Colors.black,FontWeight.w500)),
                subtitle: Text(userEmail,style: appStyle(16,Colors.black54,FontWeight.w500)),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1,
                    color:Colors.black12))),
      ),
    );
  }
}

