import 'package:flutter/material.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Models/user_model.dart';
import '../Provider/user_provider.dart';
class CommentCard extends StatelessWidget {
  final snap;
  const CommentCard({Key? key,required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel user=Provider.of<UserProvider>(context).getUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 10),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: snap['uid'])));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(snap['profilepic']),
                      radius: 14,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: RichText(text: TextSpan(
                    children: [
                      TextSpan(
                        text: snap['username'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15)
                      ),
                      TextSpan(
                        text: ' ${snap['comment']}'
                      ),
                    ]
                  )),
                ),
                Column(
                  children: [
                    IconButton(
                        enableFeedback: false,
                        onPressed:(){
                      FireStoreMethods().likeComment(user.uid, snap['commentid'], snap['commentlikes'], snap['postid']);
                    },icon:snap['commentlikes'].contains(user.uid)? Icon(Icons.favorite,size: 15,color: Colors.red,)
                        :Icon(Icons.favorite_outline,size: 15,)),
                    Visibility(
                        visible: snap['commentlikes'].length>0,
                        child: Text(snap['commentlikes'].length.toString())),
                  ],
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.topLeft,
              child: Text(DateFormat.yMMMd().format(snap['publisheddate'].toDate()),style: TextStyle(
                color: secondaryColor,
                fontSize: 12,
              ),)),
        ],
      ),
    );
  }
}
