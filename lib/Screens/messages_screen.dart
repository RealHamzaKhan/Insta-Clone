import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/message_bubbles.dart';
import 'package:provider/provider.dart';

import '../resources/Firestore_methods.dart';
import '../resources/storage_methods.dart';
class MessagesScreen extends StatefulWidget {
  String recieveruid;
  MessagesScreen({Key? key,required this.recieveruid}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  ScrollController _scrollController=ScrollController();
  String photoUrl='';
  String recieverName=' ';
  String reciverDp=' ';
  bool isFetched=false;
  Uint8List? _file;
  TextEditingController messagecontoller=TextEditingController();
  selectImage(BuildContext parentContext)async{
    return showDialog(context: parentContext, builder: (BuildContext context){
      return SimpleDialog(
        title: Text('Add a post'),
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.camera_alt),
                SizedBox(width: 10,),
                Text('Choose from Camera')
              ],
            ),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file=await Utils().pickImage(ImageSource.camera);
              setState(() {
                _file=file;
              });
              photoUrl=await StorageMethods().uploadImageToStorage('chatsimages', file, false);

            },
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.browse_gallery),
                SizedBox(width: 10,),
                Text('Choose from Gallery')
              ],

            ),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file=await Utils().pickImage(ImageSource.gallery);
              setState(() {
                _file=file;
              });
              photoUrl=await StorageMethods().uploadImageToStorage('chatsimages', file, false);
            },
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.cancel),
                SizedBox(width: 10,),
                Text('Cancel')
              ],
            ),
            onPressed: (){
              Navigator.of(context).pop();

            },
          ),
        ],
      );
    });
  }
  void sendImage()async{
    String res=await FireStoreMethods().sendMessage(
        senderUid: FirebaseAuth.instance.currentUser!.uid,
        recieverUid: widget.recieveruid,
        //check whether file image or text
        message: photoUrl);
    setState(() {
      _file=null;
    });
    if(res!='success'){
      Utils().showSnackBar(context, 'Unable to send message kindly check your connection', Colors.red);
    }
  }
  void sendMessage()async{
    if(messagecontoller.text.isNotEmpty){
      String res=await FireStoreMethods().sendMessage(
          senderUid: FirebaseAuth.instance.currentUser!.uid,
          recieverUid: widget.recieveruid,
          //check whether file image or text
          message: _file!=null?'File':messagecontoller.text);
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
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.video_call)),
          IconButton(onPressed: (){}, icon: Icon(Icons.call)),
        ],
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: ClipRect(
              child: StreamBuilder(
                 stream: FirebaseFirestore.instance.collection('chats').orderBy('datetime',descending: false)
                     .where('conversationid',whereIn:[FirebaseAuth.instance.currentUser!.uid+widget.recieveruid,widget.recieveruid+FirebaseAuth.instance.currentUser!.uid])
                     .snapshots(),
                    builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
                   if(!snapshot.hasData || snapshot.connectionState==ConnectionState.waiting){
                     return Center(child: CircularIndicator);
                   }
                   else{
                     Future.delayed(Duration(milliseconds: 50),(){
                       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                     });
                     return ListView.builder(
                       controller: _scrollController,
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
          ),
          Align(
            alignment: Alignment.bottomCenter,child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: secondaryColor),
              borderRadius: BorderRadius.circular(20),
              color: mobileBackgroundColor,
            ),
            child: Row(
              children: [
                _file!=null?Expanded(child: Container(
                  child: Image(image: MemoryImage(_file!)),
                )):Expanded(
                  child: TextFormField(
                    controller: messagecontoller,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Message...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      border: InputBorder.none
                    ),
                  ),
                ),
                Container(
                  child: IconButton(onPressed:(){
                    selectImage(context);
                  },icon: Icon(Icons.image)),
                ),
                TextButton(onPressed: ()async{
                  _file!=null?sendImage(): sendMessage();
                  messagecontoller.clear();
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  setState(() {

                  });
                }, child: const Text('Send',style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
                ),))
              ],
            ),
          ),),
        ],
      ),
    );
  }
}
