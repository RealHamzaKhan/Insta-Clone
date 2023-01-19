import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
class FriendList extends StatefulWidget {
  String uid;
  bool isFollowers;
 FriendList({Key? key,required this.uid,required this.isFollowers}) : super(key: key);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  bool _isLoading=true;
  List usersList=[];
  @override
  void initState() {
    usersList.clear();
    getUserList();
    super.initState();
  }
  Future<void> getUserList()async{
    DocumentSnapshot snap=await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    await widget.isFollowers?usersList.addAll(snap['followers']):usersList.addAll(snap['following']);
    print(usersList);
    setState(() {
      _isLoading=false;
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isFollowers?Text('Followers'):Text('Following'),
        centerTitle: false,
        automaticallyImplyLeading: true,
        backgroundColor: mobileBackgroundColor,
      ),
      body: _isLoading?Center(child: CircularIndicator,):
      FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').where('uid',isEqualTo:usersList[usersList.length-1]).get(),
          builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
            if(snapshot.hasData && snapshot.data!=null){
              var index = snapshot.data!.docs.length-1;
              var user = snapshot.data!.docs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['photourl']),
                ),
                title: Text(user['username']),
              );
            } else if (snapshot.hasError) {
              // Handle the error here
              return Text(snapshot.error.toString());
            }
            return Center(child: CircularIndicator);
          }
      )
    );
  }
}
