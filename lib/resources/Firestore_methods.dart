
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/Models/post_model.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods{
  final FirebaseFirestore firestore=FirebaseFirestore.instance;

  Future<String> postImage(
      String uid,
      String description,
      String username,
      Uint8List file,
      profImage
      )async{
    String res='some error occured';
    try{
      String postUrl=await StorageMethods().uploadImageToStorage('posts', file, true);
      final postid=Uuid().v1();
      PostModel postModel=PostModel(
          username: username,
          description: description,
          uid: uid,
          postUrl: postUrl,
          postid: postid,
          profImage: profImage,
          dateTime: DateTime.now(),
          likes: []
      );
      await firestore.collection('posts').doc(postid).set(postModel.toJson());
      res='success';
    }
    catch(e){
      res=e.toString();
    }
    return res;
  }
  Future<void> likePost(List likes,String uid,String postId)async{
    try{
      if(likes.contains(uid)){
        await firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayRemove([uid])
        });
      }
      else{
        await firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayUnion([uid])
        });
      }
    }
    catch (e){
      debugPrint(e.toString());
    }

  }
  Future<void> likeComment(String uid,String commentId,List likes,String postid)async{
    try{
      if(likes.contains(uid)){
        await firestore.collection('posts').doc(postid).collection('comments').doc(commentId).update({
          'commentlikes':FieldValue.arrayRemove([uid])
        });
      }
      else{
        await firestore.collection('posts').doc(postid).collection('comments').doc(commentId).update({
          'commentlikes':FieldValue.arrayUnion([uid])
        });
      }
    }
    catch(e){
      debugPrint(e.toString());
    }
  }
  Future<void> addComment(String uid,
      String postId,
      String text,
      String name,
      String profilepic,
      )async{
    String commentId=Uuid().v1();
    final date=DateTime.now();
    try{
      await firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
        'postid':postId,
        'comment':text,
        'username':name,
        'uid':uid,
        'profilepic':profilepic,
        'commentid':commentId,
        'publisheddate':date,
        'commentlikes':[]
      });
    }
    catch(e){
      debugPrint('error occured while storing');
    }
  }
  Future<void> followUser({
  required String uid,
    required String followeruid
})async{
    try{
      await firestore.collection('users').doc(followeruid).update({
        'followers':FieldValue.arrayUnion([uid])
      });
      await firestore.collection('users').doc(uid).update({
        'following':FieldValue.arrayUnion([followeruid])
      });
    }
    catch(e){
      debugPrint(e.toString());
    }

  }
  Future<void> unFollowUser({
    required String uid,
    required String followeruid
  })async{
    try{
      await firestore.collection('users').doc(followeruid).update({
        'followers':FieldValue.arrayRemove([uid])
      });
      await firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([followeruid])
      });
    }
    catch(e){
      debugPrint(e.toString());
    }

  }
  Future<String> updateProfile({
    required String uid,
    required String email,
    required String username,
    required String bio
  })async{
    String res="some error occured";
    try{
      await firestore.collection('users').doc(uid).update({
        'email':email,
        'username':username,
        'bio':bio
      });
      await firestore.collection('posts').where('uid',isEqualTo: uid).get().then((value) {
        value.docs.forEach((element) {
          element.reference.update({
            'username':username
          });
        });
      });
      await firestore.collection('posts').where('uid',isEqualTo: uid).get().then((value) {
        value.docs.forEach((element) {
          element.reference.collection('comments').where('uid',isEqualTo: uid).get().then((subvalue){
            subvalue.docs.forEach((subelement) {
              subelement.reference.update({
                'username':username
              });
            });
          });
        });
      });
      res='success';
    }
    catch(e){
      res=e.toString();
    }
    return res;
  }
}