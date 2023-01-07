import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier{
  final AuthMethods _auth=AuthMethods();
  UserModel? _user;
  UserModel get getUser=>_user!;
  Future<void> refreshUser()async{
    UserModel currentUser=await _auth.getUserDetails();
    _user=currentUser;
    notifyListeners();
  }
}