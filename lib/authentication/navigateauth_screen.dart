import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:microsoft_clone/screens/home_screen.dart';
import 'package:microsoft_clone/widget/progress_widget';
import 'package:microsoft_clone/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';


class NavigateAuthScreen extends StatefulWidget {
  @override
  _NavigateAuthScreenState createState() => _NavigateAuthScreenState();
}

class _NavigateAuthScreenState extends State<NavigateAuthScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late SharedPreferences preferences;

  bool isLoggedIn = false;
  bool isLoading = false;
  late User currentUser;

  @override
  void initState(){
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async
  {
    this.setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();

    if(isLoggedIn){
      String newId;
      String? id = preferences.getString("id");
      if(id!=null)
        newId = id;
      else newId="";

      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: newId )));
    }

    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF886CE4),
      // we are using Stack because the elements will be on top of each other
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.deepPurpleAccent,Color(0xFF886CE4)],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          children:<Widget> [
          Container(
            width:MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/1.9,
            child:ClipPath(
              clipper:OvalBottomBorderClipper(),
              child:Image.asset('images/connect.jpg',
                height:MediaQuery.of(context).size.height/1,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
            //space between two containers is required
            SizedBox(height:40,),
            Text("Spyra",
            style: GoogleFonts.merienda(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 57
            ),),
            // appStyle(50,Colors.white),),
            SizedBox(height:65,),
            TextButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(MediaQuery.of(context).size.width/1.5,MediaQuery.of(context).size.height/13),),
              icon: FaIcon(FontAwesomeIcons.google,color: Colors.blueAccent),
              label: Text('  Sign In with Google',style: appStyle(19,Colors.black),),
              onPressed: (){
                controlSignIn();},
            ),
            Padding(padding: EdgeInsets.all(3.0),
            child: isLoading? circularProgress():Container(),
            ),
          ],
        ),
      ),
    );
  }

  Future<Null> controlSignIn() async
  {
    preferences = await SharedPreferences.getInstance();
    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if(googleUser == null)
      return;

    GoogleSignInAuthentication googleAuthentication = await googleUser.authentication;

    // getting the credentials
    final AuthCredential credential = GoogleAuthProvider
        .credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken);

    // using the user credentials to sign in firebase auth
    User? firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    //Sign In Success
    if(firebaseUser != null)
    {
      //Check if already Signup
      final QuerySnapshot resultQuery = await FirebaseFirestore.instance
          .collection("users").where("id", isEqualTo: firebaseUser.uid).get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;

      //Save Data to firestore - if new user
      if(documentSnapshots.length == 0)
      {
        FirebaseFirestore.instance.collection("users").doc(firebaseUser.uid).set({
          "username" : firebaseUser.displayName,
          "photoUrl" : firebaseUser.photoURL,
          "id" : firebaseUser.uid,
          "aboutMe" : "Let's connect!",
          "lastSeen" : DateTime.now().toUtc(),
          "contacts" : null,
          "email": firebaseUser.email,
        });

        //Write data to Local
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString("username",documentSnapshots[0]["username"]);
        await preferences.setString("photoUrl", documentSnapshots[0]["photoUrl"]);
        await preferences.setString("email", documentSnapshots[0]["email"]);
      }
      else
      {
        //Write data to Local
        currentUser = firebaseUser;
        await preferences.setString("id", documentSnapshots[0]["id"]);
        await preferences.setString("username", documentSnapshots[0]["username"]);
        await preferences.setString("photoUrl", documentSnapshots[0]["photoUrl"]);
        await preferences.setString("aboutMe", documentSnapshots[0]["aboutMe"]);
        await preferences.setString("email", documentSnapshots[0]["email"]);
      }


      Fluttertoast.showToast(msg: "Sign in Successful!");
      this.setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid)));
    }
    //Sign In Not Success - Sign In Failed
    else
    {
      Fluttertoast.showToast(msg: "Try Again, Sign in Failed.");
      this.setState(() {
        isLoading = false;
      });
    }
  }

}


