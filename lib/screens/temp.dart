// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:intl/intl.dart';
// import 'package:microsoft_clone/authentication/google_sign_in.dart';
// import 'package:microsoft_clone/models/user.dart';
// import 'package:microsoft_clone/screens/contact_screen.dart';
// import 'package:microsoft_clone/screens/profile_screen.dart';
// import 'package:microsoft_clone/screens/search_screen.dart';
// import 'package:microsoft_clone/utils/color_scheme.dart';
// import 'package:microsoft_clone/utils/utils.dart';
// import 'package:microsoft_clone/variables.dart';
// import 'package:microsoft_clone/widget/custom_tile.dart';
// import 'package:provider/provider.dart';
// import 'package:microsoft_clone/widget/progress_widget';
//
// import '../main.dart';
// import 'chat_room.dart';
//
// class ChatScreen extends StatefulWidget {
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   late String currentUserId="";
//   late String initials="";
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//
//   TextEditingController searchTextEditingController = TextEditingController();
//   late Future<QuerySnapshot> futureSearchResults;
//
//   Future<Null> logoutUser() async {
//     await FirebaseAuth.instance.signOut();
//     await googleSignIn.disconnect();
//     await googleSignIn.signOut();
//     Fluttertoast.showToast(msg:"Logout Successful !");
//     Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => MyApp()), (
//         Route<dynamic> route) => false);
//   }
//
//   Future<User> _fetchCurrentUser() async{
//     final firebaseUser = await FirebaseAuth.instance.currentUser!;
//     await FirebaseFirestore.instance
//         .collection('users').doc(firebaseUser.uid).get()
//         .then((value){
//       currentUserId = value['uid'];
//       print(currentUserId);
//     });
//     return firebaseUser;
//   }
//
//   Future<User> getCurrentUser() async {
//     User currentUser;
//     currentUser = await FirebaseAuth.instance.currentUser!;
//     return currentUser;
//   }
//
//   // controlSearching(String userName)
//   // {
//   //   Future<QuerySnapshot> foundUsers = FirebaseFirestore.instance.collection("users")
//   //       .where("username", isGreaterThanOrEqualTo: userName).get();
//   //   setState(() {
//   //     futureSearchResults = foundUsers;
//   //   });
//   // }
//
//   @override
//   void initState(){
//     super.initState();
//     getCurrentUser().then((user){
//       setState(() {
//         currentUserId = user.uid;
//         initials = Utils.getInitials(user.displayName!);
//         print(initials);
//       });
//     });
//   }
//
//   // displayUserFoundScreen()
//   // {
//   //   return FutureBuilder(
//   //     future: futureSearchResults,
//   //     builder: (context, dataSnapshot)
//   //     {
//   //       if(!dataSnapshot.hasData)
//   //         return circularProgress();
//   //
//   //       List<UserResult> searchUserResult = [];
//   //       dataSnapshot.data!.document.forEach((document)
//   //       {
//   //         UserModel eachUser = UserModel.fromDocument(document);
//   //         UserResult userResult = UserResult(eachUser);
//   //
//   //         if(currentUserId  != document["id"])
//   //         {
//   //           searchUserResult.add(userResult);
//   //         }
//   //       });
//   //       return ListView(children: searchUserResult);
//   //     },
//   //   );
//   // }
//   //
//   // displayNoSearchResultScreen()
//   // {
//   //   final Orientation orientation = MediaQuery.of(context).orientation;
//   //
//   //   return Container(
//   //     child: Center(
//   //       child: ListView(
//   //         shrinkWrap: true,
//   //         children: <Widget>[
//   //           Icon(Icons.group, color: Colors.lightBlueAccent, size: 200.0,),
//   //           Text(
//   //             "Search Users",
//   //             textAlign: TextAlign.center,
//   //             style: TextStyle(color: Colors.lightBlueAccent, fontSize: 50.0, fontWeight: FontWeight.w500,),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: colorVariables.homePageTheme,
//       appBar: AppBar(
//         iconTheme: IconThemeData(color:Colors.black),
//         // centerTitle: true,
//         title: Text(" Chats",style: appStyle(20,Colors.black)) ,
//         backgroundColor: Colors.white,
//         actions: <Widget>[
//           IconButton(
//               tooltip: "Search Users",
//               onPressed: (){
//                 // Navigator.pushNamed(context,"/search_screen");
//                 Navigator.push(context,MaterialPageRoute(
//                     builder: (context)=>SearchScreen()
//                 ));
//               },
//               icon: FaIcon(FontAwesomeIcons.search,color: Colors.black,size: 20,)
//           ),
//           // GestureDetector(
//           //   onTap:(){
//           //     Navigator.push(context, MaterialPageRoute(
//           //         builder: (context) => Profile()));
//           //     },
//           //   child:Center(
//           //     child: Container(
//           //
//           //     ),
//           //   ),
//           //
//           // ),
//           // InkWell(
//           //   onTap: () => generateCode(),
//           //   child: Container(
//           //     width: MediaQuery.of(context).size.width/2,
//           //     height: 50,
//           //     decoration: BoxDecoration(
//           //         gradient: LinearGradient(colors:GradientColors.cherry)
//           //     ),
//           //     child: Center(
//           //       child: Text(
//           //         "Generate Code",
//           //         style: appStyle(18,Colors.white),
//           //       ),
//           //     ),
//           //   ),
//           // ),
//           InkWell(
//             // on clicking this, user will be directed to the profile section
//             child: UserCircle(initials),
//             onTap: (){
//               Navigator.push(context, MaterialPageRoute(
//                   builder: (context) => Profile()));
//             },
//           ),
//           // UserCircle(initials),
//           IconButton(
//             onPressed: logoutUser,
//             //     () {
//             //   final provider =
//             //   Provider.of<GoogleSignInProvider>(context, listen: false);
//             //   provider.signOut();
//             //   // FirebaseAuth.instance.signOut();
//             // },
//             tooltip: "Logout",
//             icon: FaIcon(FontAwesomeIcons.signOutAlt, color: Colors.black,),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white54,
//         onPressed: () {
//           print("pressed");
//           Navigator.push(context, MaterialPageRoute(
//               builder: (context) => SearchScreen()));
//         },
//         tooltip: "Start New Chat",
//         child:FaIcon(FontAwesomeIcons.userPlus,color: Colors.yellowAccent,size: 25,),
//         // NewChatButton(),
//       ),
//       body: ChatListContainer(currentUserId),
//       // Container(
//       //   color: Colors.white54,
//       //   padding: EdgeInsets.symmetric(horizontal: 24,vertical: 10),
//       //   margin: new EdgeInsets.only(bottom: 4.0),
//       //   child:TextFormField(
//       //     style: appStyle(20,Colors.black,FontWeight.w500),
//       //     controller: searchTextEditingController,
//       //     decoration: InputDecoration(
//       //       hintText: "Search Username",
//       //       hintStyle: appStyle(18,Colors.black54,FontWeight.w500),
//       //       enabledBorder: UnderlineInputBorder(
//       //         borderSide: BorderSide(color:Colors.grey),
//       //       ),
//       //       focusedBorder: UnderlineInputBorder(
//       //         borderSide: BorderSide(color: Colors.white),
//       //       ),
//       //       // filled: true,
//       //       // prefixIcon: FaIcon(FontAwesomeIcons.userFriends,color: Colors.grey,size: 30,),
//       //       suffixIcon: IconButton(
//       //         icon: FaIcon(FontAwesomeIcons.times,color: Colors.grey,),
//       //         onPressed: () {
//       //           searchTextEditingController.clear();
//       //         },
//       //       ),
//       //     ),
//       //     // onFieldSubmitted: initiateSearch(),
//       //   ),
//       //   // Text("Chats",style: appStyle(20,Colors.black)),
//       // ),
//       // ChatListContainer(currentUserId),
//     );
//   }
//
// }
//
// class ChatListContainer extends StatefulWidget {
//   final String currentUserId;
//   ChatListContainer(this.currentUserId);
//
//   @override
//   _ChatListContainerState createState() => _ChatListContainerState();
// }
//
// class _ChatListContainerState extends State<ChatListContainer> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: ListView.builder(
//         padding: EdgeInsets.all(10),
//         itemCount: 2,
//         itemBuilder: (context, index) {
//           return CustomTile(
//             // icon: FaIcon(FontAwesomeIcons.search),
//             mini: false,
//             onTap: () {},
//             title: Text(
//               "The CS Guy",
//               style: TextStyle(
//                   color: Colors.white, fontFamily: "Arial", fontSize: 19),
//             ),
//             subtitle: Text(
//               "Hello",
//               style: TextStyle(
//                 color: colorVariables.greyColor,
//                 fontSize: 14,
//               ),
//             ),
//             leading: Container(
//               constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
//               child: Stack(
//                 children: <Widget>[
//                   CircleAvatar(
//                     maxRadius: 30,
//                     backgroundColor: Colors.grey,
//                     backgroundImage: NetworkImage("https://yt3.ggpht.com/a/AGF-l7_zT8BuWwHTymaQaBptCy7WrsOD72gYGp-puw=s900-c-k-c0xffffffff-no-rj-mo"),
//                   ),
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: Container(
//                       height: 13,
//                       width: 13,
//                       decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: colorVariables.onlineDotColor,
//                           border: Border.all(
//                               color: colorVariables.blackColor,
//                               width: 2
//                           )
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ), onLongPress: () {},
//           );
//         },
//       ),
//     );
//   }
// }
//
// class UserCircle extends StatelessWidget {
//   final String text;
//
//   UserCircle(this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(10.0),
//       height: 40,
//       width: 40,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         border: Border.all(
//             color: colorVariables.blackColor, width: 1),
//         color: colorVariables.separatorColor,
//       ),
//       child: Stack(
//         children: <Widget>[
//           Align(
//             alignment: Alignment.center,
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white70,
//                 fontSize: 15,
//               ),
//             ),
//           ),
//           // Align(
//           //   alignment: Alignment.bottomRight,
//           //   child: Container(
//           //     margin: EdgeInsets.,
//           //     height: 15,
//           //     width: 12,
//           //     decoration: BoxDecoration(
//           //         shape: BoxShape.circle,
//           //         border: Border.all(
//           //             color: colorVariables.blackColor, width: 2),
//           //         color: colorVariables.onlineDotColor),
//           //   ),
//           // )
//         ],
//       ),
//     );
//   }
// }
//
// class NewChatButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(1),
//       decoration: BoxDecoration(
//         // color: Colors.white30,
//           borderRadius: BorderRadius.circular(50)),
//       child: FaIcon(FontAwesomeIcons.userPlus,color: Colors.yellowAccent,size: 32,),
//       // Icon(
//       //   Icons.edit,
//       //   color: Colors.white,
//       //   size: 25,
//       // ),
//       padding: EdgeInsets.all(10),
//     );
//   }
// }
//
//
//
