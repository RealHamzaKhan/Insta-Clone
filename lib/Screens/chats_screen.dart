import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Screens/messages_screen.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';
class ChatsScreen extends StatefulWidget {
  String url;
  ChatsScreen({Key? key,this.url=''}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List chatusers=[];
  List resultant=[];
  bool _isloading=true;
  @override
  void initState() {
    getFollowings();
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void getFollowings()async{
     QuerySnapshot result=await FirebaseFirestore.instance.collection('chats').get();
     int docslength=await result.docs.length;
     for(int i=0;i<docslength;i++)
       {
         if(result.docs[i]['senderuid']==FirebaseAuth.instance.currentUser!.uid){
           chatusers.add(result.docs[i]['recieveruid']);
         }
         else if(result.docs[i]['recieveruid']==FirebaseAuth.instance.currentUser!.uid){
           chatusers.add(result.docs[i]['senderuid']);
         }

       }
       resultant.addAll(chatusers.toSet().toList());
       setState(() {
         _isloading = false;
       });
     }

  @override
  Widget build(BuildContext context) {
    print('Building');
    return _isloading?Center(child: CircularIndicator):Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        automaticallyImplyLeading: true,
        backgroundColor: mobileBackgroundColor,
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: resultant.length,
              itemBuilder:(context,index) {
                return StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(resultant[index]).snapshots(),
                    builder: (context,AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>snapshot) {
                      if (!snapshot.hasData || snapshot.connectionState==ConnectionState.waiting) {
                        return Center(child: CircularIndicator);
                      }
                      else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: InkWell(
                            onTap: ()async{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MessagesScreen(recieveruid: snapshot.data!['uid'],)));
                              FireStoreMethods().messageReadCheck(FirebaseAuth.instance.currentUser!.uid, snapshot.data!['uid']);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(snapshot.data!['photourl']),),
                              title: Text(snapshot.data!['username']),
                              trailing: widget.url.isNotEmpty?
                              InkWell(
                                onTap: (){
                                  Utils().showSnackBar(context, 'Post Sent',Colors.greenAccent);
                                  FireStoreMethods().sendMessage(
                                      senderUid: FirebaseAuth.instance.currentUser!.uid,
                                      recieverUid: snapshot.data!['uid'],
                                      message: widget.url);
                                },
                                child: Container(
                                  height: 40,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green,
                                  ),
                                  child: Center(child: Text('Send')),
                                ),
                              ):Container(height: 1,width: 1,),
                              // trailing: CircleAvatar(
                              //   radius: 16,
                              //   child: StreamBuilder(
                              //       stream: FirebaseFirestore.instance.collection('chats').where('conversationid',whereIn: [
                              //         FirebaseAuth.instance.currentUser!.uid+snapshot.data!['uid'],snapshot.data!['uid']+FirebaseAuth.instance.currentUser!.uid
                              //       ]).snapshots(),
                              //       builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot2){
                              //         if(snapshot2.hasData || snapshot2.data!=null){
                              //           if(snapshot2.data!.docs[index]['senderuid']==FirebaseAuth.instance.currentUser!.uid){
                              //             FireStoreMethods().messageReadCheck(FirebaseAuth.instance.currentUser!.uid, snapshot.data!['uid']);
                              //
                              //           }
                              //           else if(snapshot2.data!.docs[index]['recieveruid']!=FirebaseAuth.instance.currentUser!.uid){
                              //             return snapshot2.data!.docs[index]['isread']
                              //                 ?Text('Seen',style: Theme.of(context).textTheme.bodySmall,)
                              //                 :Text('Not seen',style: Theme.of(context).textTheme.bodySmall,);
                              //           }
                              //         }
                              //
                              //           return Container();
                              //
                              //       }),
                              // )
                            ),
                          ),
                        );
                      }
                    });
              }),
          ),
        ],
      ),
    );
  }
}
