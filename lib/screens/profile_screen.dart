import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:microsoft_clone/variables.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:microsoft_clone/widget/progress_widget';

import '../main.dart';
import '../variables.dart';

class Profile extends StatelessWidget {
  final GoogleSignIn _signIn = GoogleSignIn();
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: colorVariables.backgroundTheme,
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.black),
        centerTitle: true,
        title: Text("Profile Settings",style: appStyle(20,Colors.black)) ,
        backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              onPressed:() async {
                await FirebaseAuth.instance.signOut();
                await _signIn.disconnect();
                await _signIn.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MyApp()), (
                    Route<dynamic> route) => false);
              },
              icon: FaIcon(FontAwesomeIcons.signOutAlt, color: Colors.black,),
            ),
          ],
      ),
      body: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController usernameTextEditingController = TextEditingController();
  TextEditingController aboutMeTextEditingController=TextEditingController();
  late SharedPreferences preferences;
  String id = "";
  String username = "";
  String aboutMe = "";
  String photoUrl = "";
  File? imageFileAvatar;
  PickedFile? _imageFile;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode aboutMeFocusNode = FocusNode();
  FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  Future<Null> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()), (
        Route<dynamic> route) => false);
  }

  void readDataFromLocal() async
  {
    preferences = await SharedPreferences.getInstance();

    id = preferences.getString("id")!;
    username = preferences.getString("username")!;
    aboutMe = preferences.getString("aboutMe")!;
    photoUrl = preferences.getString("photoUrl")!;
    print(id);
    print(username);
    print(aboutMe);
    print(photoUrl);
    usernameTextEditingController = TextEditingController(text: username);
    aboutMeTextEditingController = TextEditingController(text: aboutMe);

    setState(() {
    });
  }

  Future takeImage(ImageSource source) async
  {
    final pickedFile = await _picker.getImage(source: source,);
    if(pickedFile!=null){
      print("Taking Image");
      setState(() {
        _imageFile = pickedFile;
        isLoading = true;
      });
    }
    uploadImageToFirestoreAndStorage();
  }

  Future uploadImageToFirestoreAndStorage() async
  {
    // create unique file name for the profile image
    String mFileName = id;
    File tempFile = File(_imageFile!.path);
    print(_imageFile!.path);

    // Create Reference to path.
    Reference storageReference = _storage.ref().child(mFileName);
    await storageReference.putFile(tempFile).whenComplete(() async {
      await storageReference.getDownloadURL().then((value){
        try{
          print("Updating");
          photoUrl=value;
          FirebaseFirestore.instance.collection("users").doc(id).update({
            "photoUrl":photoUrl,
          }).then((data) async {
            await preferences.setString("photoUrl", photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully !");
          });
        }catch(e) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: "Error occurred. Try again!");
              print(e);
        }
      });
    });
  }

  void updateData()
  {
    userNameFocusNode.unfocus();
    aboutMeFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });

    FirebaseFirestore.instance.collection("users").doc(id).update({
      "aboutMe": aboutMe,
      "username" : username,
    }).then((data) async
    {
      await preferences.setString("aboutMe", aboutMe);
      await preferences.setString("username", username);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Updated Successfully.");
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //Profile Image - Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child:
                        (_imageFile == null)
                            ? (photoUrl != "")
                            ? Material(
                          //display already existing - old image file
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(colorVariables.backgroundTheme),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(20.0),
                            ),
                            imageUrl: photoUrl,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        )
                            : Icon(Icons.account_circle, size: 200.0, color: Colors.white30,)
                            : Material(
                          //display the new updated image here
                          child: Image.file(
                            File(_imageFile!.path),
                            // imageFileAvatar!,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                      ),
                      // SizedBox(height:40,),
                      Align(
                        alignment: Alignment.bottomRight,
                        child:Container(
                          child: IconButton(
                            onPressed: (){
                              showModalBottomSheet(context: context,
                                  builder: ((builder)=>bottomBar()));
                            },
                            // findImage,
                            icon: FaIcon(FontAwesomeIcons.pen,color: Colors.white,size: 35,),
                            padding: EdgeInsets.fromLTRB(0, 163, 70, 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(60.0),
              ),
              //Input Fields
              Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(1.0), child: isLoading ? circularProgress() : Container(),),

                  //username
                  Container(
                    child: Text(
                      "Username : ",
                      style: appStyle(18,Colors.white70,FontWeight.w600),
                    ),
                    margin: EdgeInsets.only(left: 15.0, bottom: 5.0, top: 40.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: username,
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.white30),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:Colors.grey),),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:Colors.white),),
                        ),
                        controller: usernameTextEditingController,
                        onChanged: (value){
                          username = value;
                        },
                        focusNode: userNameFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  //aboutMe - user Bio
                  Container(
                    child: Text(
                      "About Me : ",
                      style: appStyle(18,Colors.white70,FontWeight.w600),
                    ),
                    margin: EdgeInsets.only(left: 15.0, bottom: 5.0, top: 30.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: aboutMe,
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.white30),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color:Colors.grey),),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),),
                        ),
                        controller: aboutMeTextEditingController,
                        onChanged: (value){
                          aboutMe = value;
                        },
                        focusNode: aboutMeFocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              SizedBox(height: 20,),
              //Buttons
              Container(
                child: ElevatedButton(
                  onPressed: updateData,
                  child: Text(
                    "Update", style: appStyle(19),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.yellowAccent,
                    onPrimary: Color(0xFF7B83EB),
                    minimumSize: Size(MediaQuery.of(context).size.width/2,MediaQuery.of(context).size.height/15),
                  ),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 1.0),
              ),
              SizedBox(height: 35,),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),
      ],
    );
  }

  Widget bottomBar(){
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children:<Widget> [
          Text(
            "Choose Profile Image",
            style: appStyle(19),
          ),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget> [
              TextButton.icon(onPressed: (){
                takeImage(ImageSource.camera);
              },
                  icon: Icon(Icons.camera,color: colorVariables.backgroundTheme,),
                  label: Text("Camera",style: appStyle(17),)),
              SizedBox(width: 60,),
              TextButton.icon(onPressed: (){
                takeImage(ImageSource.gallery);
              },
                  icon: Icon(Icons.image,color: colorVariables.backgroundTheme,),
                  label: Text("Gallery",style: appStyle(17),)),
            ],
          ),
        ],
      ),
    );
  }
}
