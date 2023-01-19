import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:provider/provider.dart';

import '../utils/circular_progress_indicator.dart';
class CommentScreen extends StatefulWidget {
  final snap;
  const CommentScreen({Key? key,required this.snap}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final commentController=TextEditingController();
  @override
  void dispose() {
    commentController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final UserModel user=Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text('Comments'),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts')
              .doc(widget.snap['postid'])
              .collection('comments')
              .orderBy('publisheddate',descending: true)
              .snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
            if(!snapshot.hasData){
              return Center(
                child: CircularIndicator,
              );
            }
            else{
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context,index){
                return CommentCard(snap: snapshot.data!.docs[index],);
              });
            }
    }),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              width: double.infinity,
              color: Colors.black,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(user.photourl),
                  ),
                  Expanded(
                    child: TextFormField(
                      maxLines: null,
                      controller: commentController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add a comment',
                        contentPadding: EdgeInsets.symmetric(horizontal: 7),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: ()async{
                      if(commentController.text.isNotEmpty){
                        await FireStoreMethods().addComment(user.uid, widget.snap['postid'], commentController.text, user.username, user.photourl);
                        commentController.clear();
                        await FireStoreMethods().generateNotication(reciveruid: widget.snap['uid'], notication: 'Commented on your post', photourl: user.photourl, username: user.username);
                      }

                    },
                    child: const Text('Post',style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
