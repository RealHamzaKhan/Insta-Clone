import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel{
  final String username;
  final String uid;
  final String postUrl;
  final String description;
  final String postid;
  final profImage;
  final dateTime;
  final  likes;
  final savers;
  PostModel({
    required this.username,
    required this.description,
    required this.uid,
    required this.postUrl,
    required this.postid,
    required this.profImage,
    required this.dateTime,
    required this.likes,
    required this.savers
  });
  Map<String,dynamic> toJson()=>{
    "username":username,
    "uid":uid,
    "description":description,
    "photourl":postUrl,
    "postid":postid,
    "dateTime":dateTime,
    "likes":likes,
    "profImage":profImage,
    "savers":savers
  };
  static PostModel fromSnap(DocumentSnapshot snap){
    var snapshot=snap.data() as Map<String,dynamic>;
    return PostModel(
        username: snapshot['username'],
        description: snapshot['description'],
        uid: snapshot['uid'],
        postUrl: snapshot['photourl'],
        postid: snapshot['postid'],
        likes: snapshot['likes'],
        profImage: snapshot['profImage'],
        dateTime: snapshot['dateTime'],
        savers: snapshot['savers']
    );
  }

}