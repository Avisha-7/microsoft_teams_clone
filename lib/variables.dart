import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// styling text appearing on the app
TextStyle appStyle(double size, [Color fColor=Colors.black, FontWeight fWeight = FontWeight.w700,FontStyle fStyle= FontStyle.normal]){
  return GoogleFonts.lato(
      fontSize: size,
      color: fColor,
      fontWeight: fWeight,
      fontStyle: fStyle
  );
}

// creating user collection in Firebase
CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

