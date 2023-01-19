import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String username;
  final String uid;
  final String photourl;
  final String email;
  final String bio;
  final List followers;
  final List following;
  String pushtoken;
  UserModel({
    required this.username,
    required this.email,
    required this.uid,
    required this.photourl,
    required this.bio,
    required this.following,
    required this.followers,
    required this.pushtoken
});
  Map<String,dynamic> toJson()=>{
    "username":username,
    "uid":uid,
    "email":email,
    "photourl":photourl,
    "bio":bio,
    "followers":followers,
    "following":following,
    "pushtoken":pushtoken
  };
  static UserModel fromSnap(DocumentSnapshot snap){
    var snapshot=snap.data() as Map<String,dynamic>;
    return UserModel(
        username: snapshot['username'],
        email: snapshot['email'],
        uid: snapshot['uid'],
        photourl: snapshot['photourl'],
        bio: snapshot['bio'],
        following: snapshot['following'],
        followers: snapshot['followers'],
      pushtoken: snapshot['pushtoken']
    );
  }

}