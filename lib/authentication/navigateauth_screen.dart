import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:microsoft_clone/authentication/google_sign_in.dart';
import 'package:microsoft_clone/authentication/login_screen.dart';
import 'package:microsoft_clone/authentication/register_screen.dart';
import 'package:microsoft_clone/firebase/helper_functions.dart';
import 'package:microsoft_clone/screens/home_screen.dart';
import 'package:microsoft_clone/widget/progress_widget';
import 'package:microsoft_clone/variables.dart';
import 'package:provider/provider.dart';
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
            SizedBox(height:55,),
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
                controlSignIn();
                // final provider = Provider.of<GoogleSignInProvider>(context,listen:false);
                //                 provider.googleLogin();
                              },
            ),
            Padding(padding: EdgeInsets.all(3.0),
            child: isLoading? circularProgress():Container(),
            ),
          ],
        ),
      ),
      // StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     // accessing user information using snapshot
      //
      //     // handling few edge cases
      //     if(snapshot.connectionState==ConnectionState.waiting) // waiting to log in the server
      //       return Center(child: CircularProgressIndicator());
      //     else if(snapshot.hasData) // sign in is completed
      //        return HomeScreen();
      //     else if(snapshot.hasError) // has an error in getting data
      //       return Center(child: Text('Something Went Wrong!'));
      //     else {
      //     return Stack(
      //       children:[
      //         Container(
      //           width:MediaQuery.of(context).size.width,
      //           height: MediaQuery.of(context).size.height/1.9,
      //           // child: Center(
      //             child:ClipPath(
      //               clipper:OvalBottomBorderClipper(),
      //               child:Image.asset('images/homepage.PNG',
      //                 height:MediaQuery.of(context).size.height/1,
      //                 width: double.infinity,
      //                 fit: BoxFit.cover,
      //               ),
      //             ),
      //             // Image.asset(
      //             //   'images/auth.jpg',
      //             //   // Instead of hardcoding the values, using MediaQuery to get the dimensions of the screen the app is being operated on
      //             //   // This will make the app responsive
      //             //   height:MediaQuery.of(context).size.height/1.5,
      //             //   width:MediaQuery.of(context).size.width,
      //             // ),
      //           // ),
      //         ),
      //
      //         Align(
      //           alignment: Alignment.bottomCenter,
      //           child:Container(
      //             width:MediaQuery.of(context).size.width,
      //             height: MediaQuery.of(context).size.height/1.8,
      //             margin:EdgeInsets.only(left:30,right:30),
      //             child:Column(
      //               mainAxisAlignment:MainAxisAlignment.center ,
      //               children: [
      //                 ElevatedButton(
      //                   style: ElevatedButton.styleFrom(
      //                     primary: Color(0xFF7B83EB),
      //                     onPrimary: Colors.black,
      //                     minimumSize: Size(MediaQuery.of(context).size.width/1.5,MediaQuery.of(context).size.height/13),
      //                   ),
      //                   // icon: FaIcon(FontAwesomeIcons.google,color: Colors.blueAccent),
      //                   child: Text('Register',style: appStyle(23,Colors.white),),
      //                   onPressed: ()=>Navigator.push(
      //                       context,
      //                       MaterialPageRoute(builder: (context)=>RegisterScreen())
      //                   ),),
      //                 SizedBox(height:40,), //space between two containers is required
      //                 ElevatedButton(
      //                   style: ElevatedButton.styleFrom(
      //                     primary: Color(0xFF7B83EB),
      //                     onPrimary: Colors.black,
      //                     minimumSize: Size(MediaQuery.of(context).size.width/1.5,MediaQuery.of(context).size.height/13),
      //                   ),
      //                   // icon: FaIcon(FontAwesomeIcons.google,color: Colors.blueAccent),
      //                   child: Text('Sign In',style: appStyle(23,Colors.white),),
      //                   onPressed: ()=>Navigator.push(
      //                       context,
      //                       MaterialPageRoute(builder: (context)=>LoginScreen())
      //                   ),
      //                 ),
      //
      //                 //space between two containers is required
      //                 SizedBox(height:45,),
      //                 TextButton.icon(
      //                   style: ElevatedButton.styleFrom(
      //                     primary: Colors.white,
      //                     onPrimary: Colors.black,
      //                     minimumSize: Size(MediaQuery.of(context).size.width/1.5,MediaQuery.of(context).size.height/13),
      //                   ),
      //                   icon: FaIcon(FontAwesomeIcons.google,color: Colors.blueAccent),
      //                   label: Text('  Sign In with Google',style: appStyle(19,Colors.black),),
      //                   onPressed: (){
      //                     final provider = Provider.of<GoogleSignInProvider>(context,listen:false);
      //                     provider.googleLogin();
      //                   },
      //                   ),
      //               ],
      //             ),
      //           ),
      //         )
      //       ],
      //     );
      //     }
      //   }
      // ),
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

    GoogleSignInAuthentication googleAuthentication = await googleUser!.authentication;

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
          "createdAt" : DateTime.now().millisecondsSinceEpoch.toString(),
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
      HelperFunctions.saveUserEmailSharedPreference(documentSnapshots[0]["email"]);
      HelperFunctions.saveUserNameSharedPreference(documentSnapshots[0]["username"]);
      HelperFunctions.saveUserIdSharedPreference(documentSnapshots[0]["id"]);
      HelperFunctions.saveUserPhotoSharedPreference(documentSnapshots[0]["photoUrl"]);

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


