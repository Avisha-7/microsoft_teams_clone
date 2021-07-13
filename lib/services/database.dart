import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseMethods{
  
  Future getUserData(String collection) async {
    final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firebaseFirestore.collection(collection).get();
    return snapshot.docs;
  }

  Future queryData(String queryString) async{
    return await FirebaseFirestore.instance
        .collection('users')
        .orderBy('username')
        .where('username',isGreaterThanOrEqualTo: queryString.toUpperCase())
        .where('username',isLessThanOrEqualTo: queryString.toLowerCase()+"\uf8ff")
        .get();
  }

  Future createChatRoom(String chatRoomID, chatRoomMap) async {
    return await FirebaseFirestore.instance
        .collection("chatroom").doc(chatRoomID).set(chatRoomMap)
        .catchError((e) {
      print(e);
    });
  }
}
