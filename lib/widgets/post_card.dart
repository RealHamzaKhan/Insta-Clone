import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Provider/post_card_provider.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/Screens/comment_screen.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Screens/sendpostscreen.dart';
class PostCard extends StatefulWidget {
  final snap;
   PostCard({Key? key,required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentNum=0;
  bool isAnimating=false;
  // var _connectivityResult;
  // void checkConnectionStatus()async{
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   setState(() {
  //     _connectivityResult=connectivityResult;
  //   });
  // }
  @override
  void initState() {
    getCommentsNumber();
    super.initState();
  }
  void getCommentsNumber()async{
    try{
      QuerySnapshot commentssnap=await FirebaseFirestore
          .instance
          .collection('posts')
          .doc(widget.snap['postid'])
          .collection('comments').get();
      commentNum=commentssnap.docs.length;
      setState(() {

      });
    }
    catch(e){

    }

  }
  @override
  Widget build(BuildContext context) {
    final user=Provider.of<UserProvider>(context).getUser;
    PostCardProvider postCardProvider=Provider.of(context,listen: false);
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              InkWell(
                enableFeedback: false,
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: widget.snap['uid'],myProf: true,)));
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.snap['profImage']),
                ),
              ),
              InkWell(
                  enableFeedback: false,
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: widget.snap['uid'],myProf: true,)));
                  },

                  child: Text('  ${widget.snap['username']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)),
              // Spacer(),
              // IconButton(
              //     enableFeedback: false,
              //     onPressed: ()async{
              // },
              // icon: Icon(Icons.more_vert_outlined))
            ],
          ),
        ),
       InkWell(
          enableFeedback: false,
          onDoubleTap: ()async{
            setState(() {
              isAnimating=true;
            });
            FireStoreMethods().likePost(widget.snap['likes'], user.uid, widget.snap['postid']);
            await FireStoreMethods().generateNotication(
                reciveruid: widget.snap['uid'],
                notication: 'Liked your post',
                photourl: user.photourl,
                username: user.username);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: height*0.6,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: widget.snap!=null
                    ?Image.network(widget.snap['photourl'],fit: BoxFit.fill,)
                    :
                    Container(
                      height: height*0.6,
                      width: double.infinity,
                      color: Colors.white,
                    )
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 100),
                opacity: isAnimating?1:0,
                child: LikeAnimation(
                  child: Icon(Icons.favorite,size: 100,),
                  isAnimating: isAnimating,
                  duration: Duration(milliseconds: 400),
                  onEnd: (){
                    setState(() {
                      isAnimating=false;
                    });
                  },
                ),
              )
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LikeAnimation(
                isAnimating: widget.snap['likes'].contains(user.uid),
                isSmallLike: true,
                child: IconButton(
                    enableFeedback: false,
                    onPressed: ()async{
                  FireStoreMethods().likePost(widget.snap['likes'], user.uid, widget.snap['postid']);
                  await FireStoreMethods().generateNotication(
                      reciveruid: widget.snap['uid'],
                      notication: 'Liked your post',
                      photourl: user.photourl,
                      username: user.username);
                },
                    icon: widget.snap['likes'].contains(user.uid)?const Icon(Icons.favorite_outlined,color: Colors.red,size: 35,)
                        : const Icon(Icons.favorite_outline,size: 35,)
                )),
            IconButton(
                enableFeedback: false,
                onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CommentScreen(snap: widget.snap)));
            }, icon:const Icon(Icons.comment_outlined,size: 32,)),
            IconButton(
                enableFeedback: false,
                onPressed: (){
                  sendPost(context,widget.snap['photourl']);
                }, icon:Icon(Icons.send,size: 32,)),
            const Spacer(),
            Consumer<PostCardProvider>(builder: (context,value,child){
             return IconButton(
                  enableFeedback: false,
                  onPressed: (){
                    value.setSaved(widget.snap['postid']);
                    widget.snap['savers'].contains(FirebaseAuth.instance.currentUser!.uid)?Utils().showSnackBar(context,'Post Unsaved', Colors.green)
                        :Utils().showSnackBar(context,'Post Saved', Colors.green);
                  }, icon:Icon(Icons.bookmark,size: 32,
             color: widget.snap['savers'].contains(FirebaseAuth.instance.currentUser!.uid)?Colors.blueAccent:Colors.white,
             ));
            })

          ],
        ),
        SizedBox(height: height*0.01,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("${widget.snap['likes'].length} Likes",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
        ),
        SizedBox(height: height*0.01,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: RichText(text: TextSpan(
            style: const TextStyle(color:primaryColor ),
            children: [
              TextSpan(
                text: widget.snap['username'],
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              TextSpan(
                  text: '  ${widget.snap['description']}',
                  style: const TextStyle(fontWeight: FontWeight.normal)
              ),
            ]
          )),
        ),
        SizedBox(height: height*0.01,),
        Visibility(
          visible: commentNum>0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CommentScreen(snap: widget.snap)));
                },
                child: Text('View $commentNum comments',style: const TextStyle(color: secondaryColor),)),
          ),
        ),
        SizedBox(height: height*0.01,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(DateFormat.yMMMd().format(widget.snap['dateTime'].toDate()),style: TextStyle(color: secondaryColor),),
        )
      ],
    );
  }
}
