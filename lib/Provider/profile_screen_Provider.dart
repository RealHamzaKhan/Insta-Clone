import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreenProvider with ChangeNotifier{
  int? _followers;
  int? _following;
  bool? _isFollowing;
  int get followers=>_followers!;
  int get following=>_following!;
  bool get isFollowing=>_isFollowing!;
 Future <void> getDetails(String uid)async{
    DocumentSnapshot usernamesnap= await FirebaseFirestore.instance.collection('users').doc(uid).get();
    _followers=usernamesnap['followers'].length;
    _following=usernamesnap['following'].length;
    _isFollowing=usernamesnap['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
    notifyListeners();
  }
  void incrementfollowers(){
   _followers=followers+1;
   notifyListeners();
  }
  void decrementfollowers(){
   _followers=followers-1;
   notifyListeners();
  }
  void setIsFollowing(bool value){
   _isFollowing=value;
   notifyListeners();
  }
}