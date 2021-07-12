import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:microsoft_clone/authentication/navigateauth_screen.dart';
import 'package:microsoft_clone/authentication/register_screen.dart';
import 'package:microsoft_clone/variables.dart';

class IntroAuthScreen extends StatefulWidget {
  @override
  _IntroAuthScreenState createState() => _IntroAuthScreenState();
}

class _IntroAuthScreenState extends State<IntroAuthScreen> {

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Color(0xFF886CE4),
      pages:[
        PageViewModel(
          title:"Spyra",
          body:"",
          image:
          ClipPath(
            clipper:OvalBottomBorderClipper(),
            child:Image.asset('images/homepage.PNG',
              height:MediaQuery.of(context).size.height/2,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
            // Container(
            //   width: double.infinity,
            //   height: MediaQuery.of(context).size.height/2.5,
            //   decoration:BoxDecoration(
            //       gradient: LinearGradient(colors: GradientColors.facebookMessenger)
            //   ),
            // ),
          decoration: PageDecoration(
            bodyTextStyle: appStyle(30,Colors.black),
            titleTextStyle: appStyle(40,Colors.white,FontWeight.bold)
          )
        ),
        PageViewModel(
            title:"Join or Start Meeting",
            body:"Easy to use interface, join or start meetings",
            image:
            ClipPath(
              clipper:OvalBottomBorderClipper(),
              child:Image.asset('images/connect.jpg',
                height:MediaQuery.of(context).size.height/2,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // image:Center(
            //   child:Image.asset('images/conference.jpg',height:175),
            // ),
            decoration: PageDecoration(
                bodyTextStyle: appStyle(20,Colors.black),
                titleTextStyle: appStyle(20,Colors.black)
            )
        ),
        PageViewModel(
            title:"Security",
            body:"Your security is our priority",
            image:
            ClipPath(
              clipper:OvalBottomBorderClipper(),
              child:Image.asset('images/security.jpg',
                height:MediaQuery.of(context).size.height/2,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // image:Center(
            //   child:Image.asset('images/security.jpg',height:175),
            // ),
            decoration: PageDecoration(
                bodyTextStyle: appStyle(20,Colors.black),
                titleTextStyle: appStyle(20,Colors.black)
            )
        )
      ],
      onDone: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>NavigateAuthScreen()));
      },
      onSkip: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>NavigateAuthScreen()));
      },
        showSkipButton:true,
        skip:const Icon(Icons.skip_next,size:45,color: Colors.black,),
        next: const Icon(Icons.arrow_forward_ios,color: Colors.black,),
        done:Text("End Tour",style:appStyle(18,Colors.white),
        ),
    );
  }
}
