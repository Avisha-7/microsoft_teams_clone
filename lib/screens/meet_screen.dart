import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:microsoft_clone/meeting/create_meeting.dart';
import 'package:microsoft_clone/meeting/join_meeting.dart';
import 'package:microsoft_clone/screens/profile_screen.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:microsoft_clone/utils/utils.dart';
import 'package:microsoft_clone/variables.dart';
import '../main.dart';

class MeetScreen extends StatefulWidget {
  final googleSignIn = GoogleSignIn();

  @override
  _MeetScreenState createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen>
    with SingleTickerProviderStateMixin {
  String initials = "";
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late TabController tabController;

  buildTab(String name) {
    return Container(
      width: 150,
      height: 50,
      child: Card(
        color: colorVariables.homePageTheme,
        child: Center(
          child: Text(
            name,
            style: appStyle(15, Colors.white, FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await FirebaseAuth.instance.currentUser!;
    return currentUser;
  }

  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Fluttertoast.showToast(msg: "Logout Successful!");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((user) {
      setState(() {
        initials = Utils.getInitials(user.displayName!);
        print(initials);
      });
    });
    tabController = TabController(length: 2, vsync: this);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF886CE4),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 7),
        child: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            "  Meet",
            style: appStyle(20, Colors.black, FontWeight.w700),
          ),
          actions: <Widget>[
            InkWell(
              // on clicking this, user will be directed to the profile section
              child: UserCircle(initials),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profile()));
              },
            ),
            TextButton.icon(
                onPressed: logoutUser,
                icon: FaIcon(
                  FontAwesomeIcons.signOutAlt,
                  color: Colors.black,
                ),
                label: Text(''))
          ],
          bottom: TabBar(
            indicatorColor: colorVariables.separatorColor,
            labelColor: colorVariables.separatorColor,
            controller: tabController,
            tabs: [buildTab("Join Meeting"), buildTab("Create Meeting")],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          JoinMeeting(),
          CreateMeeting(),
        ],
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
        border: Border.all(color: colorVariables.blackColor, width: 1),
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
