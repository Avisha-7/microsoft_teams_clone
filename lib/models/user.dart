import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  UserModel({
    required this.id,
    required this.nickname,
    required this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      photoUrl: doc['photoUrl'],
      nickname: doc['nickname'],
      createdAt: doc['createdAt'],
    );
  }
}