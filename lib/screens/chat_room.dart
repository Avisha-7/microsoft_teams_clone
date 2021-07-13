import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:microsoft_clone/services/database.dart';
import 'package:microsoft_clone/utils/color_scheme.dart';
import 'package:microsoft_clone/variables.dart';
import 'package:microsoft_clone/widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:microsoft_clone/widget/progress_widget';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverAvatar;
  final String receiverName;
  final String receiverEmail;

  Chat({
    Key? key,
    required this.receiverId,
    required this.receiverAvatar,
    required this.receiverName,
    required this.receiverEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70) ,
        child: AppBar(
          backgroundColor: Color(0xFF7B83EB),
          // Colors.white38,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 15, 5),
              child: CircleAvatar(
                backgroundColor: Colors.black,
                backgroundImage: CachedNetworkImageProvider(receiverAvatar),
              ),
            ),
          ],
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:<Widget> [Text(
              receiverName,
              style: appStyle(18,Colors.black),
            ),]
          ),
          // titleSpacing: 10,
          // centerTitle: true,
        ),
      ),
      body: Container(
        color:Color(0xffC0C0C0),
          child: ChatRoom(receiverId: receiverId,receiverEmail: receiverEmail, receiverAvatar: receiverAvatar,receiverName:receiverName )),
    );
  }
}

class ChatRoom extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;
  final String receiverAvatar;
  final String receiverName;

  ChatRoom({
    Key? key,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverAvatar,
    required this.receiverName,
  }):super(key:key);

  @override
  _ChatRoomState createState() => _ChatRoomState(receiverName: receiverName,receiverEmail: receiverEmail, receiverAvatar:receiverAvatar, receiverId: receiverId);
}

class _ChatRoomState extends State<ChatRoom> {
  final String receiverId;
  final String receiverEmail;
  final String receiverAvatar;
  final String receiverName;


  _ChatRoomState({
    Key? key,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverAvatar,
    required this.receiverName,
  });

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  late bool isDisplaySticker;
  late bool isLoading;

  late PickedFile imageFile;
  late PickedFile _cameraImage;
  late File fileImage;
  late String imageUrl;

  late String chatId;
  late SharedPreferences preferences;
  late String id;
  late String username;
  late String photo;
  late var listMessage;
  DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    focusNode.addListener(onFocusChange);
    // isDisplaySticker = false;
    isLoading = false;
    chatId = "";
    readLocal();
  }

  readLocal() async
  {
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";
    username = preferences.getString("username")??"";
    photo = preferences.getString("photoUrl")??"";
    if(id.hashCode <= receiverId.hashCode)
      chatId = '$id-$receiverId';
    else
      chatId = '$receiverId-$id';

    FirebaseFirestore.instance.collection("users").doc(id).update({'chattingWith': receiverId});

    List<String> usersList = [receiverId,id];
      Map<String,dynamic>chatRoomMap = {
        "users" : usersList,
        "chatId": chatId,
        "receiverId":receiverId,
        "senderId":id,
        "receiverEmail":receiverEmail,
        "senderName":username,
        "receiverName":receiverName,
        "receiverPhotoUrl": receiverAvatar,
        "senderPhotoUrl":photo,
        "lastMessage":"",
        "lastTime":"",
      };
      databaseMethods.createChatRoom(chatId, chatRoomMap);

    setState(() {

    });
  }

  void onCreateRoom()
  {
    var chatRef = FirebaseFirestore.instance.collection("messages").doc(chatId);

    FirebaseFirestore.instance.runTransaction((transaction) async
    {
      await transaction.set(chatRef,
        {
          "idFrom": id,
          "senderName":username,
          "idTo": receiverId,
          "receiverName":receiverName,
          "users":[id, receiverId],
          "createdOn": DateTime.now().toUtc(),
        },);
    });
    listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
  }


  onFocusChange()
  {
    if(focusNode.hasFocus)
    {
      //hide stickers whenever keypad appears
      setState(() {
        isDisplaySticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              //create List of Messages
              createListMessages(),

              // //Show Stickers
              // (isDisplaySticker ? createStickers() : Container()),

              //Input Controllers
              createInput(),
            ],
          ),
          createLoading(),
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  createLoading()
  {
    return Positioned(
      child: isLoading ? circularProgress() : Container(),
    );
  }

  Future<bool> onBackPress()
  {
    if(isDisplaySticker)
    {
      setState(() {
        isDisplaySticker = false;
      });
    }
    else
      Navigator.pop(context);
    return Future.value(false);
  }

  createListMessages()
  {
    return Flexible
      (
      child: chatId == ""
          ? Center(
        child: Text(
          "No Conversations yet!",
          style: appStyle(20,colorVariables.backgroundTheme,FontWeight.w500),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("messages")
            .doc(chatId)
            .collection(chatId)
            .orderBy("timestamp", descending: true)
            .limit(20).snapshots(),

        builder: (context, snapshot){
          if(!snapshot.hasData)
          {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorVariables.backgroundTheme),
              ),
            );
          }
          else
          {
            listMessage = snapshot.data!.docs;
            return  ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => createItem(index, snapshot.data!.docs[index]),
              itemCount: snapshot.data!.docs.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),

    );
  }

  bool isLastMsgLeft(int index)
  {
    if((index>0 && listMessage!=null && listMessage[index-1]["idFrom"]==id)  ||  index==0)
      return true;
    else
      return false;
  }

  bool isLastMsgRight(int index)
  {
    if((index>0 && listMessage!=null && listMessage[index-1]["idFrom"]!=id)  ||  index==0)
      return true;
    else
      return false;
  }

  Widget createItem(int index, DocumentSnapshot document)
  {
    //My messages - Right Side
    if(document["idFrom"] == id)
    {
      return Row(
        children: <Widget>[
          document["type"] == 0

          //Text Msg
              ? Container(
            child: Text(
              document["content"],
              style: appStyle(16,Colors.white,FontWeight.w500),
              // TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            width: 200.0,
            decoration: BoxDecoration(color: colorVariables.senderColor, borderRadius: BorderRadius.circular(8.0)),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
          )

          //Image Msg
              : document["type"] == 1
              ? Container(
            child: TextButton(
              child: Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                    ),
                    width: 200.0,
                    height: 200.0,
                    padding: EdgeInsets.all(70.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  errorWidget: (context, url, error) => Material(
                    child: Image.asset("images/img_not_available.jpeg", width: 200.0, height: 200.0, fit: BoxFit.cover,),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: document["content"],
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                clipBehavior: Clip.hardEdge,
              ),
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => FullPhoto(url: document["content"])
                ));
              },
            ),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
          )

          //Sticker .gif Msg
              : Container(
            child: Image.asset(
              "images/${document['content']}.gif",
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
            margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    }
    //Receiver Messages - Left Side
    else
    {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMsgLeft(index)
                    ? Material(
                  //display receiver profile image
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorVariables.backgroundTheme),
                      ),
                      width: 35.0,
                      height: 35.0,
                      padding: EdgeInsets.all(10.0),
                    ),
                    imageUrl: receiverAvatar,
                    width: 35.0,
                    height: 35.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
                    : Container(width: 35.0,),
                //displayMessages
                document["type"] == 0

                //Text Msg
                    ? Container(
                  child: Text(
                    document["content"],
                    style: appStyle(16,Colors.white,FontWeight.w500),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(color: colorVariables.receiverColor, borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(left: 10.0),
                )

                //Image Msg
                    : document["type"] == 1
                    ? Container(
                  child: TextButton(
                    child: Material(
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset("images/img_not_available.jpeg", width: 200.0, height: 200.0, fit: BoxFit.cover,),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: document["content"],
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                    onPressed: ()
                    {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => FullPhoto(url: document["content"])
                      ));
                    },
                  ),
                  margin: EdgeInsets.only(left: 10.0),
                )

                //Sticker .gif Msg
                    : Container(
                  child: Image.asset(
                    "images/${document['content']}.gif",
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                  margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20.0 : 10.0, right: 10.0),
                ),

              ],
            ),

            //Msg time
            isLastMsgLeft(index)
                ? Container(
              child: Text(
                DateFormat("dd MMMM, yyyy - hh:mm:aa")
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"]))),
                style: TextStyle(color: Colors.grey, fontSize: 12.0, fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 10.0, bottom: 5.0),
            )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  createInput()
  {
    return Container(
      child:Expanded(
        child: Row(
          children: <Widget>[
            //pick image icon button
            Material(
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 10, 0, 10),
                child: IconButton(
                  icon: Icon(Icons.image),
                  color: colorVariables.backgroundTheme,
                  onPressed: getImage,
                  iconSize: 30,
                ),
              ),
              color: Colors.white,
            ),

            // Click Image from camera
            Material(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                child: IconButton(
                  icon: Icon(Icons.camera_alt_rounded),
                  color: colorVariables.backgroundTheme,
                  iconSize: 30,
                  // onPressed: getSticker,
                  onPressed: getImageFromCamera,
                ),
              ),
              color: Colors.white,
            ),
            Flexible(
              child: Container(
                child: TextField(
                  style: appStyle(16,Colors.black),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: "Type a message",
                    hintStyle: appStyle(16,Colors.grey),
                  ),
                  focusNode: focusNode,
                ),
              ),
            ),

            //Send Message Icon Button
            Material(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: IconButton(
                  icon: Icon(Icons.send),
                  color: colorVariables.backgroundTheme,
                  iconSize: 30,
                  onPressed: () => onSendMessage(textEditingController.text, 0),
                ),
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
      width: double.infinity,
      height: 70.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  void onSendMessage(String contentMsg, int type)
  {
    //type=0 its text msg
    //type=1 its imageFile
    if(contentMsg != "")
    {
      textEditingController.clear();

      var docRef = FirebaseFirestore.instance
          .collection("messages")
          .doc(chatId)
          .collection(chatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      FirebaseFirestore.instance.runTransaction((transaction) async
      {
        await transaction.set(docRef,
          {
            "idFrom": id,
            "senderName":username,
            "idTo": receiverId,
            "receiverName":receiverName,
            "users":[id, receiverId],
            "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
            "content": contentMsg,
            "type": type,
          },);
        FirebaseFirestore.instance.collection("messages").doc(chatId).update({'lastMessage': contentMsg});
        FirebaseFirestore.instance.collection("messages").doc(chatId).update({'lastTime': DateTime.now().toUtc()});
      });
      listScrollController.animateTo(0.0, duration: Duration(microseconds: 300), curve: Curves.easeOut);
    }
    else
      Fluttertoast.showToast(msg: "Empty Message. Can not be sent!");
  }

  Future getImageFromCamera()async{
    final cameraImg = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _cameraImage = cameraImg!;
    });
  }

  Future getImage() async
  {
    imageFile = (await ImagePicker().getImage(source: ImageSource.gallery))!;
    if(imageFile != null)
      isLoading = true;
    print("GetImage");
    setState(() {
      isLoading = false;
      fileImage = File(imageFile.path);
    });
    uploadImageFile();
  }

  Future uploadImageFile() async
  {
    // setting a unique name to store the image file
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    print("Printing!");
    print(fileName);
    Reference storageReference = FirebaseStorage.instance.ref().child("Chat Images").child(fileName);

    UploadTask storageUploadTask = storageReference.putFile(fileImage);
    TaskSnapshot storageTaskSnapshot = (await storageUploadTask.whenComplete) as TaskSnapshot;
      // when upload done, we will get download url
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl)
      {
        print("Here we go!");
        print(downloadUrl);
        imageUrl = downloadUrl;
        setState(() {
          isLoading = false;
          onSendMessage(imageUrl, 1);
        });
      }, onError: (error)
      {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Error: " + error);
      });
  }

}

