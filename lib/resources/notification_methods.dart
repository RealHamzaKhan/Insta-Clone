import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../Models/user_model.dart';
class NotificationMethods{
  static FirebaseMessaging firebaseMessaging=FirebaseMessaging.instance;
   static UserModel? userModel;
  static Future<String> getFirebaseMessagingToken()async{
    String res='';
    try{
      await firebaseMessaging.requestPermission();
      await firebaseMessaging.getToken().then((value) {
        if(value!=null){
          res=value;
        }
      });
    }
    catch(e){
      res=e.toString();
    }
    return res;
  }
  static Future<void> sendPushNotification(String person,dynamic message,String username)async{
    try{
      var url =Uri.parse('https://fcm.googleapis.com/fcm/send');

      final body={
        "to":person,
        "notification": {
          "title": username,
          "body": message,
          "android_channel_id": "chats",
          "sound": "default",
        }
      };
      var response = await http.post(
          url,
          headers: {
            HttpHeaders.contentTypeHeader:'application/json',
            HttpHeaders.authorizationHeader:'key=AAAAqIiOT-g:APA91bEMpK7T40uv_7cZgCMNAR4m3q-99rvLWglekI4HddpeEYf0-JZiyq8QB9kpk5ujmTmD-5-YcF-OnoBOY18-JERn_Z16WSARMFrCqF_uEVJR7WyZrIQCNHdRHMQPAHSDZkW3_s94'
          },
          body:jsonEncode(body)
      );
    }
    catch(e){
      log(e.toString());
    }

  }
}