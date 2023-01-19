
import 'package:flutter/material.dart';
import 'package:instagram_clone/Screens/chats_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
sendPost(BuildContext context,String postUrl) async{
  return showCupertinoModalBottomSheet(
      topRadius: Radius.circular(30),
      barrierColor: Colors.black.withOpacity(0.5),
      context: context, builder: (context){
    return Container(
        height: MediaQuery.of(context).size.height*0.6,
        child: ChatsScreen(url: postUrl,));
  });
}
