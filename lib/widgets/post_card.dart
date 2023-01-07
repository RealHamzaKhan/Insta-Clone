

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/Screens/comment_screen.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
class PostCard extends StatefulWidget {
  final snap;
   PostCard({Key? key,required this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentNum=0;
  bool isAnimating=false;
  var _connectivityResult;
  void checkConnectionStatus()async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _connectivityResult=connectivityResult;
    });
  }
  @override
  void initState() {
    getCommentsNumber();
    checkConnectionStatus();
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
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: widget.snap['uid'])));
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.snap['profImage']),
                ),
              ),
              InkWell(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(uid: widget.snap['uid'])));
                  },
                  child: Expanded(child: Text('  ${widget.snap['username']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),))),
              IconButton(onPressed: (){

              },
              icon: Icon(Icons.more_vert_outlined))
            ],
          ),
        ),
        GestureDetector(
          onDoubleTap: ()async{
            setState(() {
              isAnimating=true;
            });
            FireStoreMethods().likePost(widget.snap['likes'], user.uid, widget.snap['postid']);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: height*0.6,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: _connectivityResult==ConnectivityResult.mobile || _connectivityResult==ConnectivityResult.wifi ||widget.snap!=null
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
                child: IconButton(onPressed: ()async{
                  FireStoreMethods().likePost(widget.snap['likes'], user.uid, widget.snap['postid']);
                }, 
                    icon: widget.snap['likes'].contains(user.uid)?Icon(Icons.favorite_outlined,color: Colors.red,size: 35,)
                        : Icon(Icons.favorite_outline,size: 35,)
                )),
            IconButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CommentScreen(snap: widget.snap)));
            }, icon:Icon(Icons.comment_outlined,size: 32,)),
            IconButton(onPressed: (){}, icon:Icon(Icons.send,size: 32,)),
            Spacer(),
            IconButton(onPressed: (){}, icon:Icon(Icons.bookmark,size: 32,)),
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
            style: TextStyle(color:primaryColor ),
            children: [
              TextSpan(
                text: widget.snap['username'],
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
              TextSpan(
                  text: '  ${widget.snap['description']}',
                  style: TextStyle(fontWeight: FontWeight.normal)
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
                child: Text('View $commentNum comments',style: TextStyle(color: secondaryColor),)),
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
