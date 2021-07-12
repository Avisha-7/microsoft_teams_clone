import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:microsoft_clone/screens/home_screen.dart';

import '../variables.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[250],
      // we are using Stack because the elements will be on top of each other
      body:Stack(
        children:[
          Container(
            // Instead of hardcoding the values, using MediaQuery to get the dimensions of the screen the app is being operated on
            // This will make the app responsive
            width:MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/2,
            decoration:BoxDecoration(
                gradient: LinearGradient(colors:GradientColors.blue)
            ),
            child: Center(
              child:Image.asset(
                'images/logo.png',
                height:100,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:Container(
              width:MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/1.6,
              margin:EdgeInsets.only(left:30,right:30),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color:Colors.grey.withOpacity(0.5),
                      spreadRadius:5,
                      blurRadius:5,
                      offset:const Offset(0,3),
                    )
                  ],
                  color:Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                  )
              ),
              child:Column(
                mainAxisAlignment:MainAxisAlignment.center ,
                children: [
                  SizedBox(height: 50,),
                  Container(
                    width: MediaQuery.of(context).size.width/1.7,
                    child: TextField(
                      style:appStyle(18,Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email),
                          hintStyle: appStyle(20,Colors.grey,FontWeight.w700)
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    width: MediaQuery.of(context).size.width/1.7,
                    child: TextField(
                      style:appStyle(18,Colors.black),
                      controller: passwordController,
                      decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          hintStyle: appStyle(20,Colors.grey,FontWeight.w700)
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  InkWell(
                    onTap:(){
                      // try{
                      //   int popTimes=0;
                      //   FirebaseAuth.instance.signInWithEmailAndPassword(
                      //       email: emailController.text,
                      //       password: passwordController.text);
                      //   // go to the home screen
                      //   // needs to pop out 2 times to return to the home screen
                      //   // onPressed: ()=>
                      //       Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context)=>HomeScreen()));
                      //   // Navigator.popUntil(context, (route){
                      //   //   return popTimes++ == 2;
                      //   // });
                      // }
                      // catch(e){
                      //   print(e);
                      //   var snackBar = SnackBar(content:
                      //   Text(
                      //     e.toString(),
                      //     style:appStyle(20),
                      //   ));
                      //   Scaffold.of(context).showSnackBar(snackBar);
                      // }

                    },
                    child: Container(
                      width:MediaQuery.of(context).size.width/2,
                      height: 45,
                      decoration:BoxDecoration(
                          gradient:LinearGradient(
                            colors:GradientColors.beautifulGreen,
                          ),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child:Center(
                        child:Text(
                          "Sign In",
                          style:appStyle(25,Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
