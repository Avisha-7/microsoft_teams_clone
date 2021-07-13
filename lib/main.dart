// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:microsoft_clone/authentication/google_sign_in.dart';
import 'package:microsoft_clone/authentication/login_screen.dart';
import 'package:microsoft_clone/authentication/navigateauth_screen.dart';
import 'package:microsoft_clone/screens/home_screen.dart';
import 'package:microsoft_clone/screens/introauth_screen.dart';
import 'package:microsoft_clone/screens/search_screen.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // root of the application
  @override
  Widget build(BuildContext context)=> ChangeNotifierProvider(
    create: (context)=> GoogleSignInProvider(),
    child: MaterialApp(
        home:NavigationPage(),
        debugShowCheckedModeBanner: false,
      initialRoute: '/', //marking this as the initial screen
      routes: {
          '/search_screen':(context) =>SearchScreen(),
      },
      ),
  );
}

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool isSignedIn = false; // by default the user is not signed in
  @override
  void initState(){
    super.initState();
    
    // gets triggered as it listens changes in the status of the user (logged in or not)
    FirebaseAuth.instance.authStateChanges().listen((user){
      if(user!=null){
        setState(() {
          isSignedIn = true;
        });
      }else {
        setState(() {
          isSignedIn = false;
        });
      }
    });
  }
  
  Widget build(BuildContext context) {
    return Scaffold(
      // if the user is not signed in, will go to IntroAuthScreen
      // otherwise would be directed to HomeScreen
      body:isSignedIn==false ? NavigateAuthScreen() : HomeScreen(),
    );
  }
}



