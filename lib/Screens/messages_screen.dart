import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/message_bubbles.dart';
import 'package:provider/provider.dart';

import '../resources/Firestore_methods.dart';
class MessagesScreen extends StatefulWidget {
  String recieveruid;
  MessagesScreen({Key? key,required this.recieveruid}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String recieverName=' ';
  String reciverDp=' ';
  bool isFetched=false;
  TextEditingController messagecontoller=TextEditingController();
  void sendMessage()async{
    if(messagecontoller.text.isNotEmpty){
      String res=await FireStoreMethods().sendMessage(
          senderUid: FirebaseAuth.instance.currentUser!.uid,
          recieverUid: widget.recieveruid,
          message: messagecontoller.text);
      if(res!='success'){
        Utils().showSnackBar(context, 'Unable to send message kindly check your connection', Colors.red);
      }
    }

  }
  void getRecieverDetails()async{
   DocumentSnapshot ref= await FirebaseFirestore.instance.collection('users').doc(widget.recieveruid).get();
   recieverName=ref['username'];
   reciverDp=ref['photourl'];
   setState(() {
     isFetched=true;
   });
  }
  @override
  void initState() {
    getRecieverDetails();
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    messagecontoller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  bool _isReciever=true;
  @override
  Widget build(BuildContext context) {
    UserModel user=Provider.of<UserProvider>(context).getUser;
    return !isFetched?Center(child: CircularIndicator,):Scaffold(
      appBar: AppBar(
        title: Text(recieverName),
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.8,
            child: StreamBuilder(
               stream: FirebaseFirestore.instance
                   .collection('chats')
                   .where('senderuid',isEqualTo: FirebaseAuth.instance.currentUser!.uid )
                   .where('recieveruid',isEqualTo: widget.recieveruid)
                   .snapshots(),
                  builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
                 if(!snapshot.hasData || snapshot.connectionState==ConnectionState.waiting){
                   return Center(child: CircularIndicator);
                 }
                 else{
                   return ListView.builder(
                       itemCount: snapshot.data!.docs.length,
                       itemBuilder: (context,index){
                     if(snapshot.data!.docs[index]['senderuid']==FirebaseAuth.instance.currentUser!.uid){
                       return MessageBubbles(profilePic: user.photourl,
                           message: snapshot.data!.docs[index]['message'],
                           date: snapshot.data!.docs[index]['datetime'],
                           isReciever: false);
                     }
                     else{
                       return MessageBubbles(
                           profilePic: reciverDp,
                           message: snapshot.data!.docs[index]['message'],
                           date:snapshot.data!.docs[index]['datetime'],
                           isReciever: true);
                     }
                   });
                 }
            }
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,child: Container(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messagecontoller,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: 'Message...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: InputBorder.none
                    ),
                  ),
                ),
                TextButton(onPressed: ()async{
                  sendMessage();
                  messagecontoller.clear();
                }, child: Text('Send',style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
                ),))
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(color: secondaryColor),
              borderRadius: BorderRadius.circular(20),
              color: mobileBackgroundColor,
            ),
          ),),
        ],
      ),
    );
  }
}
