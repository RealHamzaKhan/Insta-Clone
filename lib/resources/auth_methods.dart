import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods{
  final _auth=FirebaseAuth.instance;
  final FirebaseFirestore firestore=FirebaseFirestore.instance;

  Future<UserModel> getUserDetails() async{
    User currentUser=_auth.currentUser!;
    DocumentSnapshot snap=await firestore.collection('users').doc(currentUser.uid).get();
    return UserModel.fromSnap(snap);
  }

  Future<String> signUp({
    required String username,
  required String email,
    required String password,
    required String bio,
    required Uint8List file,
})async{
    String res='Some error occured';
    try{
      if(email.isNotEmpty&&password.isNotEmpty&&bio.isNotEmpty&&username.isNotEmpty&&file!=null){
        UserCredential credential=await _auth.createUserWithEmailAndPassword(email: email, password: password);
        String photoUrl=await StorageMethods().uploadImageToStorage('Profile Pics', file, false);
        UserModel _user=UserModel(username: username,
            email: email,
            uid: credential.user!.uid,
            photourl: photoUrl,
            bio: bio,
            following: [],
            followers: []);
        await firestore.collection('users').doc(credential.user!.uid).set(_user.toJson());
        res='success';
      }
      else{
        return res='Kindly fill all the fields';
      }
    } on FirebaseAuthException catch (e){
      if(e.code=='email-already-in-use'){
        res='Email is already taken';
      }
      else if(e.code=='invalid-email'){
        res='Invalid email';
      }
      else if(e.code=='weak-password'){
        res='Password is weak';
      }
      else{
        res='Unknown error occured';
      }
    }
    return res;
  }


  Future<String> loginUser({
  required String email,
    required String password,
})async{
    String res='Some error occurred';
    try{
      if(email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res='success';
      }
      else{
        res='Fill all the fields';
      }
    } on FirebaseAuthException catch(e){
      if(e.code=='invalid-email'){
        res='Invalid email';
      }
      else if(e.code=='user-not-found'){
        res='No user is associated with this email';
      }
      else if(e.code=='wrong-password'){
        res='Wrong password';
      }
      else{
        res='Unknown error occured';
      }
    }
    return res;
  }
  Future<void> signOutUser()async{
    await _auth.signOut();
  }
}