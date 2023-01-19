import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:uuid/uuid.dart';
class PostCardProvider with ChangeNotifier{
  bool? _isSaved;
  bool get isSaved=>_isSaved??false;

    Future<void> setSaved(String postId)async{
      try{
        DocumentSnapshot snap=await FirebaseFirestore.instance.collection('posts').doc(postId).get();
        if(snap['savers'].contains(FirebaseAuth.instance.currentUser!.uid)){
          await FireStoreMethods().unsavePost(postId);
          _isSaved=false;
          notifyListeners();
        }
        else{
          await FireStoreMethods().savePost(postId);
          _isSaved=true;
          notifyListeners();
        }

      }
      catch(e){
        debugPrint('Some error occured');
      }

    }


}