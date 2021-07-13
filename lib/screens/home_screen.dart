import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:microsoft_clone/main.dart';
import 'package:microsoft_clone/screens/chat_screen.dart';
import 'package:microsoft_clone/screens/profile_screen.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
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
      body: pageOptions[_currentIndex],
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
      ),
    );
  }
}


