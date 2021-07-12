import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:microsoft_clone/variables.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class JoinMeeting extends StatefulWidget {
  const JoinMeeting({Key? key}) : super(key: key);

  @override
  _JoinMeetingState createState() => _JoinMeetingState();
}

class _JoinMeetingState extends State<JoinMeeting> {
  TextEditingController nameController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  bool isVideoMuted = true;
  bool isAudioMuted = true;
  String username = "";

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = await FirebaseAuth.instance.currentUser!;
    return currentUser;
  }
  void initState() {
    super.initState();
    getCurrentUser().then((user){
      setState(() {
        username = user.displayName!;
      });
    });
  }

  joinMeet() async{
    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
      
      // FeatureFlag featureFlag = FeatureFlag();
      // featureFlag.welcomePageEnabled = false;
      // if(Platform.isAndroid)
      //   featureFlag.callIntegrationEnabled = false; // doesn't work well in Android
      // else if(Platform.isIOS)
      //   featureFlag.pipEnabled = false; // there exists some PIP problems in iOS

      var userOptions = JitsiMeetingOptions(room: roomController.text)
      ..userDisplayName = nameController.text == ''
          ? username
          : nameController.text
      ..userDisplayName = nameController.text
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags);

      // await JitsiMeet.joinMeeting(userOptions);
      await JitsiMeet.joinMeeting(
        userOptions,
        listener: JitsiMeetingListener(
            onConferenceWillJoin: (message) {
              debugPrint("${userOptions.room} will join with message: $message");
            },
            onConferenceJoined: (message) {
              debugPrint("${userOptions.room} joined with message: $message");
            },
            onConferenceTerminated: (message) {
              debugPrint("${userOptions.room} terminated with message: $message");
            },
            genericListeners: [
              JitsiGenericListener(
                  eventName: 'readyToClose',
                  callback: (dynamic message) {
                    debugPrint("readyToClose callback");
                  }),
            ]),
      );
      void _onConferenceWillJoin(message) {
        debugPrint("_onConferenceWillJoin broadcasted with message: $message");
      }

      void _onConferenceJoined(message) {
        debugPrint("_onConferenceJoined broadcasted with message: $message");
      }

      void _onConferenceTerminated(message) {
        debugPrint("_onConferenceTerminated broadcasted with message: $message");
      }

      _onError(error) {
        debugPrint("_onError broadcasted: $error");
      }
    }catch(e){
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF886CE4),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height:60),
              Text(
                "Meeting Code",
                style: appStyle(22, Colors.white),
              ),
              SizedBox(height: 10,),
              PinCodeTextField(
                controller: roomController,
                length: 7,
                autoDisposeControllers: false,
                animationType: AnimationType.fade,
                cursorColor: Colors.white54,
                pinTheme: PinTheme(
                  activeColor: Colors.yellowAccent,
                  inactiveColor: colorVariables.separatorColor,
                  selectedColor: Colors.yellowAccent,
                  shape:PinCodeFieldShape.underline
                ),
                animationDuration: Duration(milliseconds: 300),
                onChanged: (value){},
                appContext: context,
              ),
              SizedBox(height: 30,),
              TextField(
                controller: nameController,
                style: appStyle(16,colorVariables.userCircleBackground),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: username,
                  labelStyle: appStyle(16,Colors.black54),
                ),
              ),
              SizedBox(height: 15),
              CheckboxListTile(
                value: isVideoMuted,
                activeColor: colorVariables.separatorColor,
                checkColor: Colors.white,
                onChanged: (value){
                  setState(() {
                    isVideoMuted = value!;
                  });},
                title: Text(
                  "Video Muted",
                  style: appStyle(18, Colors.white,FontWeight.w500),
                ),
              ),
              SizedBox(height: 7),
              CheckboxListTile(
                value: isAudioMuted,
                activeColor: colorVariables.separatorColor,
                checkColor: Colors.white,
                // tileColor: Colors.white54,
                onChanged: (value){
                  setState(() {
                    isAudioMuted = value!;
                  });
                },
                title: Text(
                  "Audio Muted",
                  style: appStyle(18, Colors.white,FontWeight.w500),
                ),
              ),
              SizedBox(height: 20),
              Divider(
                height: 20,
                thickness: 2.0,
              ),
              SizedBox(height: 40),
              InkWell(
                onTap: () => joinMeet(),
                child: Container(
                  width: MediaQuery.of(context).size.width/1.3,
                  height: 64,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors:GradientColors.white)
                  ),
                  child: Center(
                    child: Text(
                      "Join Meeting",
                      style: appStyle(21,colorVariables.separatorColor),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
