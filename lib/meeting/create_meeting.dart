import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:microsoft_clone/variables.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

class CreateMeeting extends StatefulWidget {

  @override
  _CreateMeetingState createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  String meetCode ='';
  TextEditingController codeController = TextEditingController();

  generateCode(){
    // uses package uuid to generate random ids
    setState(() {
      // it generates a long string of code
      // which is cut short by using the substring function
      // reduced it to length 7
      meetCode = Uuid().v1().substring(0,7);
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF886CE4),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50,),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top:20),
                child: Text(
                  "Generate Meeting Code",
                  style: appStyle(22,Colors.white,FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 60,),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 20),
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 20,),
                  Expanded(
                    child: TextField(
                      enabled: false,
                      enableInteractiveSelection: false,
                      // controller: codeController,
                      style: appStyle(16,colorVariables.userCircleBackground),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: (meetCode=="")
                            ?"Meeting Code"
                            :meetCode,
                        labelStyle: appStyle(20,Colors.black54),
                      ),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    children: [
                      IconButton(onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: meetCode));
                        print("CodeController: ");
                        print(meetCode);
                        Fluttertoast.showToast(msg: "Copied to Clipboard!");
                      },
                          icon: FaIcon(FontAwesomeIcons.solidCopy,
                              size: 40,
                              color:Colors.white54)
                      ),
                      SizedBox(height: 20,),
                    ],
                  ),
                  SizedBox(width: 20,),
                ],
              ),
            ),
            SizedBox(height: 70,),
            InkWell(
              onTap: (){
                if(meetCode==""){
                  Fluttertoast.showToast(msg: "Generate a meeting code!");
                }
                else Share.share("https://meet.jit.si/"+meetCode);
              },
              child: Container(
                width: MediaQuery.of(context).size.width/1.5,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.yellowAccent
                ),
                child: Center(
                  child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.shareAlt),
                          SizedBox(width: 30,),
                          Text(
                            "Send Invite",
                            style: appStyle(20,colorVariables.separatorColor),
                          ),
                        ],
                      ),
                    // ],
                  // ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            InkWell(
              onTap: () => generateCode(),
              child: Container(
                width: MediaQuery.of(context).size.width/1.5,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors:GradientColors.white)
                ),
                child: Center(
                  child: Text(
                    "Generate Code",
                    style: appStyle(20,colorVariables.separatorColor),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
