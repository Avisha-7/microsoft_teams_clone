import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

late String _localUserName;

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController  = new TextEditingController();
  late Future<QuerySnapshot> searchResults;
  late String currentUserId;

  getChatRoomId(String a, String b){
    if(a.substring(0,1).codeUnitAt(0)>b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }
    else return "$a\_$b";
  }

  createChatRoomAndStartConversation(String rUsername, String rUserID){
    String chatRoomID = getChatRoomId(rUsername,Constants.localUserName);

    List<String> usersList = [rUsername,rUserID,Constants.localUserName,Constants.localUserId];
    Map<String,dynamic>chatRoomMap = {
      "users" : usersList,
      "chatroomID": chatRoomID
    };
    databaseMethods.createChatRoom(chatRoomID, chatRoomMap);
    Navigator.push(context, MaterialPageRoute(
        builder: (context)=>ChatScreen()));
  }

  Widget searchList(){
    return searchSnapshot !=null ? ListView.builder(
      itemCount: searchSnapshot.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
        return SearchTile(
          userEmail: searchSnapshot.docs[index]['email'],
          userName: searchSnapshot.docs[index]['username'],
          photourl: searchSnapshot.docs[index]['photoUrl'],
          userId: searchSnapshot.docs[index]['id'],
          // userName: searchSnapshot.docs[index].data()!['username'],
          // userEmail:searchSnapshot.docs[index].data()!['email'],
        );
        })
        : Container();
  }

  late QuerySnapshot searchSnapshot;
  initiateSearch() {
    databaseMethods.queryData(searchTextEditingController.text).then((value){
      setState(() {
        searchSnapshot = value;
      });
    });
  }

  @override
  void initState(){
    initiateSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Color(0xFF886CE4),

        // appBar: AppBar(
        //   title:
        //   Container(
        //     margin: new EdgeInsets.only(bottom: 4.0),
        //       child:
        //       TextFormField(
        //         style: appStyle(20,Colors.black,FontWeight.w500),
        //         controller: searchTextEditingController,
        //         decoration: InputDecoration(
        //           hintText: "Search Username",
        //           hintStyle: appStyle(18,Colors.black54,FontWeight.w500),
        //           enabledBorder: UnderlineInputBorder(
        //             borderSide: BorderSide(color:Colors.grey),
        //           ),
        //           focusedBorder: UnderlineInputBorder(
        //             borderSide: BorderSide(color: Colors.white),
        //           ),
        //           // filled: true,
        //           prefixIcon: FaIcon(FontAwesomeIcons.userFriends,color: Colors.grey,size: 30,),
        //           suffixIcon: IconButton(
        //             icon: FaIcon(FontAwesomeIcons.times,color: Colors.grey,),
        //             onPressed: () {
        //                 searchTextEditingController.clear();
        //                 },
        //           ),
        //         ),
        //         onFieldSubmitted: initiateSearch(),
        //       ),
        //       // Text("Chats",style: appStyle(20,Colors.black)),
        //   ),
        //   backgroundColor: Colors.white70,
        //   iconTheme: IconThemeData(color: Colors.black),
        // ),
        child:Container(
          child: Column(
            children: [
              // SizedBox(height: 20,),
              Container(
                color: Colors.white54,
                padding: EdgeInsets.fromLTRB(10,50, 35, 16),
                // padding: EdgeInsets.all(4.0),
                // padding: EdgeInsets.symmetric(horizontal: 32,vertical: 16),
                child:
                Row(
                  children: [
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.chevronLeft,color: Colors.black54,),
                      onPressed: (){
                        Navigator.pop(context);
                        // Navigator.push(context, MaterialPageRoute(
                        //     builder: (context) => ChatScreen()));
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
                    // IconButton(
                    //     onPressed: (){
                    //       initiateSearch();
                    //     },
                    //     icon: FaIcon(FontAwesomeIcons.search,color: Colors.black,size: 20,)
                    // ),
                    // FaIcon(FontAwesomeIcons.search,),
                  ],
                ),
              ),
              searchList(),
            ],
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
  SearchTile({required this.userName,required this.userEmail, required this.photourl, required this.userId});

  // creates chatRoom, pushes the user to the chatRoom Screen and finally pushReplacement is done
  // initiateConv(BuildContext context){
  //   Navigator.push(context, MaterialPageRoute(
  //       builder: (context)=>Chat(
  //         receiverId:searchSnapshot.docs[index]['id'],
  //         receiverEmail: searchSnapshot.docs[index]['email'],
  //         receiverName: searchSnapshot.docs[index]['username'],
  //         receiverAvatar: searchSnapshot.docs[index]['photoUrl'],
  //       )
  //   ));
  // }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height/40,vertical: 8),
      child: Container(
        child: Column(
          children:<Widget> [
            GestureDetector(
              onTap: (){
                // creates chatRoom, pushes the user to the chatRoom Screen and finally pushReplacement is done
                Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>Chat(
                      receiverId:userId,
                      receiverEmail: userEmail,
                      receiverName:userName,
                      receiverAvatar: photourl,
                    )
                ));
              },
              // initiateConv(context),
              //     (){
              //   print("Tile pressed");
              // },
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
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            //   child: IconButton(
            //       onPressed:(){
            //
            //       },
            //       icon: FaIcon(FontAwesomeIcons.comment)),
            // ),
            // Column(
            //   crossAxisAlignment:CrossAxisAlignment.start,
            //   children: [
            //     Text(userName,style: appStyle(16,Colors.black,FontWeight.w500)),
            //     Text(userEmail,style: appStyle(16,Colors.black54,FontWeight.w500)),
            //   ],
            // ),
            // Spacer(),
            // Container(
            //   padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            //   child: IconButton(
            //       onPressed:(){
            //
            //       },
            //       icon: FaIcon(FontAwesomeIcons.comment)),
            // ),
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

