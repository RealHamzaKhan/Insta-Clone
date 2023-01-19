
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/Models/post_model.dart';
import 'package:instagram_clone/resources/notification_methods.dart';
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
          likes: [],
        savers: []
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
    required String url,
    required String username,
    required String bio
  })async{
    String res="some error occured";
    try{
      await firestore.collection('users').doc(uid).update({
        'photourl':url,
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
  Future<String> sendMessage({
  required String senderUid,required String recieverUid,required String message
})async{
    String res='some error occured';
    try{
      String chatId=Uuid().v1();
      await firestore.collection('chats').doc(chatId).set({
        'senderuid':senderUid,
        'recieveruid':recieverUid,
        'chatuid':chatId,
        'message':message,
        'datetime':DateTime.now(),
        'isread':false,
        'conversationid':senderUid+recieverUid
      });
      DocumentSnapshot recieversnap=await firestore.collection('users').doc(recieverUid).get();
      DocumentSnapshot sendersnap=await firestore.collection('users').doc(senderUid).get();
      String token=recieversnap['pushtoken'];
      String username=sendersnap['username'];
      var checkedMessage=Uri.tryParse(message);
      NotificationMethods.sendPushNotification(token,checkedMessage!.isAbsolute?'Image':message, username);
      res='success';
    }
    catch(e){
      res=e.toString();
    }
    return res;
  }
  Future<void> messageReadCheck(String senderuid,String recieveruid)async{
    await FirebaseFirestore.instance.collection('chats').where('conversationid',whereIn: [senderuid+recieveruid,recieveruid+senderuid])
        .get().then((value) {
       value.docs.forEach((element) {
         element.reference.update({
           'isread':true
         });
       });
    });
  }
  Future<void> savePost(String postId)async{
    try{
      await firestore.collection('posts').doc(postId).update({
        'savers':FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    }
    catch(e){
      debugPrint('Error occured in save post');
    }

  }
  Future<void> unsavePost(String postId)async{
    try{
      await firestore.collection('posts').doc(postId).update({
        'savers':FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    }
    catch(e){
      debugPrint('Error occured at unsave post');
    }

  }


  Future<String> postVideo(
      String uid,
      String description,
      String username,
      Uint8List file,
      )async{
    String res='some error occured';
    try{
      String reelUrl=await StorageMethods().uploadVideoToStorage('reels', file, true);
      final postid=Uuid().v1();
      await firestore.collection('reels').doc(postid).set({
        'reelid':postid,
        'uid':FirebaseAuth.instance.currentUser!.uid,
        'description':description,
        'username':username,
        'reelurl': reelUrl,
        'likes':[],
        'datetime':DateTime.now()
      });
      res='success';
    }
    catch(e){
      res=e.toString();
    }
    return res;
  }
  Future<void> likeReel(List likes,String uid,String postId)async{
    try{
      if(likes.contains(uid)){
        await firestore.collection('reels').doc(postId).update({
          'likes':FieldValue.arrayRemove([uid])
        });
      }
      else{
        await firestore.collection('reels').doc(postId).update({
          'likes':FieldValue.arrayUnion([uid])
        });
      }
    }
    catch (e){
      debugPrint(e.toString());
    }

  }
  Future<void> generateNotication({required String reciveruid,
    required String notication,
  required String photourl,
  required String username
  })async{
    String notificationId=const Uuid().v1();
    await firestore.collection('notifications').doc(notificationId).set({
      'notificationid':notificationId,
      'reciveruid':reciveruid,
      'generatoruid':FirebaseAuth.instance.currentUser!.uid,
      'datetime':DateTime.now(),
      'notification': notication,
      'photourl':photourl,
      'username':username
    });
  }
  Future<void> deletePost(String postId)async{
    await firestore.collection('posts').doc(postId).delete();
  }
  Future<void> unsave(String postId)async{
    await firestore.collection('posts').doc(postId).update({
      'savers':FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
  }
}