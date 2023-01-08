import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Screens/messages_screen.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List following=[];
  List followers=[];
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
     DocumentSnapshot result=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
     following=result['following'];
     followers=result['followers'];
     Set set1=following.toSet();
     Set set2=followers.toSet();
     Set set3=set1.intersection(set2);
     resultant=set3.toList();
     setState(() {
       _isloading=false;
     });
  }
  @override
  Widget build(BuildContext context) {
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
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MessagesScreen(recieveruid: snapshot.data!['uid'],)));
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(snapshot.data!['photourl']),),
                              title: Text(snapshot.data!['username']),
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
