import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:microsoft_clone/main.dart';
import 'package:microsoft_clone/screens/call_screen.dart';
import 'package:microsoft_clone/screens/chat_screen.dart';
import 'package:microsoft_clone/screens/profile_screen.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';

import '../variables.dart';
import 'contact_screen.dart';
import 'meet_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  HomeScreen({Key? key, required this.currentUserId}) : super(key: key);


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
   Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (
        Route<dynamic> route) => false);
  }
  // late PageController pageController;
  // int _page=0;
  //
  // @override
  // void initState(){
  //   super.initState();
  //   pageController=PageController();
  // }

  // void onPageChanged(int page){
  //   setState(() {
  //     // set the current page value to the page value that we receive from the callback
  //     _page = page;
  //   });
  // }

  // void navigationTapped(int page){
  //   pageController.jumpToPage(page);
  // }

  List<String> _options=[
    "CHAT",
    "MEET",
    "CONTACTS"
    "PROFILE"
  ];

  List pageOptions = [
    ChatScreen(),
    MeetScreen(),
    ContactScreen(),
    Profile()
  ];

  int _currentIndex=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:colorVariables.homePageTheme,

      // BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   selectedItemColor: Colors.blue,
      //   selectedLabelStyle:appStyle(17,Colors.black),
      //   unselectedItemColor: Colors.black,
      //   unselectedLabelStyle: appStyle(17,Colors.black),
      //   currentIndex:page,
      //   onTap:(index){
      //     setState(() {
      //       page=index;
      //     });
      //   },
      //   items:[
      //     BottomNavigationBarItem(
      //         label:'Meet',
      //         icon: Icon(Icons.video_call, size:32)
      //     ),
      //     BottomNavigationBarItem(
      //         label:'Profile',
      //         icon: Icon(Icons.person, size:32)
      //     ),
      //   ],
      //
      // ),
      body: pageOptions[_currentIndex],
      // Container(
      //   color:colorVariables.backgroundTheme,
      //   child:Center(
      //     child:Text(_options[_currentIndex],
      //     )
      //   ),
      // ),
        // PageView(
        //   children:<Widget> [
        //     Center(child:Text("Chat List Screen")),
        //     Center(child:Text("Call Logs Screen")),
        //     Center(child:Text("Meet Screen")),
        //     Center(child:Text("Contacts List Screen")),
        //   ],
        //   controller: pageController,
        //   onPageChanged: onPageChanged,
        // ),
      // pageOptions[_page],
      bottomNavigationBar: CurvedNavigationBar(
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color(0xFF886CE4),
        animationDuration: Duration(seconds: 1),
        animationCurve: Curves.easeInOutQuad,
        items:<Widget> [
          FaIcon(FontAwesomeIcons.comments,color:Color(0xFF886CE4)),
          FaIcon(FontAwesomeIcons.video,color:Color(0xFF886CE4)),
          FaIcon(FontAwesomeIcons.addressBook,color:Color(0xFF886CE4)),
          FaIcon(FontAwesomeIcons.solidUser,color:Color(0xFF886CE4)),
        ],
        onTap: (index){
          setState(() {
            // set the current page value to the page value that we receive from the callback
            _currentIndex=index;
          });
        },
        // onTap: navigationTapped,
        // currentIndex: _page,
      ),
    );
  }
}


