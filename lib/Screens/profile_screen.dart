

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/Screens/Login_Screen.dart';
import 'package:instagram_clone/Screens/friendlist.dart';
import 'package:instagram_clone/Screens/messages_screen.dart';
import 'package:instagram_clone/main.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/notification_methods.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/profile_stats.dart';
import 'package:provider/provider.dart';

import '../Provider/profile_screen_Provider.dart';
class ProfileScreen extends StatefulWidget {
  String uid;
  bool myProf;
  ProfileScreen({Key? key,required this.uid,this.myProf=false}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading=false;
  bool _isfollowing=false;
  String username='';
  int followers=0;
  int postlength=0;
  int following=0;
  String bio='';
  String profilepic='';
  var followersDetails;
  var details;
  @override
  void initState() {
    getProfileDetails();
    // TODO: implement initState
    super.initState();
  }
  void getProfileDetails()async{
    try{
      DocumentSnapshot usernamesnap= await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      username=usernamesnap['username'];
      bio=usernamesnap['bio'];
      profilepic=usernamesnap['photourl'];
      followersDetails=usernamesnap['followers'];
      var posts=await FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo:widget.uid).get();
      ProfileScreenProvider provider=Provider.of(context,listen: false);
      await provider.getDetails(widget.uid);
      details=posts;
      postlength=posts.docs.length;
      setState(() {
        _isLoading=true;
      });
    }
    catch(e){
      Utils().showSnackBar(context, 'Unable to show profile', Colors.red);
    }

}
  deleteImage(BuildContext parentContext,String postId)async{
    return showDialog(context: parentContext, builder: (BuildContext context){
      return SimpleDialog(
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.delete),
                SizedBox(width: 10,),
                Text('Delete')
              ],
            ),
            onPressed: ()async{
              Navigator.of(context).pop();
              await FireStoreMethods().deletePost(postId);

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
  unsaveImage(BuildContext parentContext,String postId)async{
    return showDialog(context: parentContext, builder: (BuildContext context){
      return SimpleDialog(
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.bookmark_rounded),
                SizedBox(width: 10,),
                Text('Unsave')
              ],
            ),
            onPressed: ()async{
              Navigator.of(context).pop();
              await FireStoreMethods().unsavePost(postId);
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
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider=Provider.of(context,listen: false);
    return !_isLoading?WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Center(
        child: CircularIndicator,
      ),
    ):WillPopScope(
      onWillPop: ()async{
        if(FirebaseAuth.instance.currentUser!.uid==widget.uid&&widget.myProf==false){
          return false;
        }
        else{
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: ()async{
               await AuthMethods().signOutUser().then((value) {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              }).onError((error, stackTrace) {

              });

            }, icon: Icon(Icons.logout)),
          ],
          title: Text(username.toString()),
          backgroundColor: mobileBackgroundColor,
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 40,
                        backgroundImage: NetworkImage(profilepic),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Consumer<ProfileScreenProvider>(builder: (context,value,child){
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ProfileStats(value: postlength, name: 'POSTS'),
                                  InkWell(
                                    onTap: (){
                                      NotificationMethods.getFirebaseMessagingToken();
                                     // Navigator.push(context, MaterialPageRoute(builder: (context)=>FriendList(uid: widget.uid, isFollowers: true)));
                                    },
                                      child: ProfileStats(value: value.followers, name: 'FOLLOWERS')),
                                  InkWell(
                                    // onTap: (){
                                    //   Navigator.push(context, MaterialPageRoute(builder: (context)=>FriendList(uid: widget.uid, isFollowers: false)));
                                    // },
                                      child: ProfileStats(value: value.following, name: 'FOLLOWING')),
                                ],
                              );
                            }),

                            SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                            Consumer<ProfileScreenProvider>(builder: (context,value,child){
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FirebaseAuth.instance.currentUser!.uid==widget.uid
                                      ?
                                  FollowButton(title: 'Edit Profile',
                                      backgroundColors: mobileBackgroundColor,
                                      borderColor: Colors.grey,
                                      textColor: Colors.white,
                                      onpress: (){
                                        Navigator.pushNamed(context,RoutesNames.editprofile);
                                      }): value.isFollowing?
                                  Column(
                                    children: [
                                      FollowButton(title: 'Message',
                                          backgroundColors: Colors.white70,
                                          borderColor: Colors.blueAccent,
                                          textColor: Colors.black,
                                          onpress: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>MessagesScreen(recieveruid: widget.uid)));
                                          }),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                      FollowButton(title: 'Unfollow',
                                          backgroundColors: Colors.white70,
                                          borderColor: Colors.blueAccent,
                                          textColor: Colors.black,
                                          onpress: (){
                                            FireStoreMethods().unFollowUser(uid: FirebaseAuth.instance.currentUser!.uid,followeruid: widget.uid);
                                            value.decrementfollowers();
                                            value.setIsFollowing(false);
                                          }),
                                    ],
                                  )
                                      :Column(
                                    children: [
                                      FollowButton(title: 'Message',
                                          backgroundColors: Colors.blueAccent,
                                          borderColor: Colors.blueAccent,
                                          textColor: Colors.white,
                                          onpress: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>MessagesScreen(recieveruid: widget.uid)));
                                          }),
                                      SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                                      FollowButton(title: 'Follow',
                                          backgroundColors: Colors.blueAccent,
                                          borderColor: Colors.blueAccent,
                                          textColor: Colors.white,
                                          onpress: ()async{
                                            FireStoreMethods().followUser(uid: FirebaseAuth.instance.currentUser!.uid,followeruid: widget.uid);
                                            value.incrementfollowers();
                                            value.setIsFollowing(true);
                                           await FireStoreMethods().generateNotication(
                                               reciveruid: widget.uid,
                                               notication: 'Followed you',
                                               photourl: userProvider.getUser.photourl,
                                               username: userProvider.getUser.username);
                                          }),
                                    ],
                                  )
                                ],
                              );
                            })

                          ],
                        ),
                      )
                    ],
                  ),
                  Container(alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 15),
                  child: Text(username,textDirection: TextDirection.ltr,style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),)
                  ),
                  Container(alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(top: 15),
                      child: Text(bio,textDirection: TextDirection.ltr,style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400
                      ),)
                  ),
                ],
              ),
            ),
            Divider(),
            widget.uid==FirebaseAuth.instance.currentUser!.uid?Container(
              height: MediaQuery.of(context).size.height*0.5,
                width: double.infinity,
                child :DefaultTabController(
                  length: 2,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ButtonsTabBar(
                          contentPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.2),
                          labelSpacing: MediaQuery.of(context).size.width*0.6,
                          backgroundColor: Colors.red,
                          tabs: const [
                            Tab(icon:Icon(Icons.grid_view_rounded)),
                            Tab(icon:Icon(Icons.bookmark)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            FutureBuilder(
                                future: FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo:widget.uid).get(),
                                builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
                                  if(!snapshot.hasData){
                                    return Center(child: CircularIndicator,);
                                  }
                                  return Container(
                                    height: MediaQuery.of(context).size.height*0.5,
                                    width: double.infinity,
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 1.5,
                                          childAspectRatio: 1,
                                        ),
                                        itemBuilder: (context,index){
                                          return Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: double.infinity,
                                              maxHeight: double.infinity,
                                            ),
                                            child: InkWell(
                                                onLongPress: (){
                                                    //delete the post
                                                  deleteImage(context,snapshot.data!.docs[index]['postid']);
                                                },
                                                child: Image(image: NetworkImage(snapshot.data!.docs[index]['photourl']),fit: BoxFit.fill,)),
                                          );
                                        }),
                                  );
                                }),
                            FutureBuilder(
                                future: FirebaseFirestore.instance.collection('posts').where('savers',arrayContains: FirebaseAuth.instance.currentUser!.uid).get(),
                                builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
                                  if(!snapshot.hasData){
                                    return Center(child: CircularIndicator,);
                                  }
                                  return Container(
                                    height: MediaQuery.of(context).size.height*0.5,
                                    width: double.infinity,
                                    child: GridView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 1.5,
                                          childAspectRatio: 1,
                                        ),
                                        itemBuilder: (context,index){
                                          return Container(
                                            constraints: const BoxConstraints(
                                              maxWidth: double.infinity,
                                              maxHeight: double.infinity,
                                            ),
                                            child: InkWell(
                                                onLongPress: (){
                                                  unsaveImage(context,snapshot.data!.docs[index]['postid']);
                                                },
                                                child: Image(image: NetworkImage(snapshot.data!.docs[index]['photourl']),fit: BoxFit.fill,)),
                                          );
                                        }),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                )

            )
                :FutureBuilder(
                future: FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo:widget.uid).get(),
                builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
                  if(!snapshot.hasData){
                    return Center(child: CircularIndicator,);
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height*0.5,
                    width: double.infinity,
                    child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context,index){
                          return Container(
                            constraints: const BoxConstraints(
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                            ),
                            child: Image(image: NetworkImage(snapshot.data!.docs[index]['photourl']),fit: BoxFit.fill,),
                          );
                        }),
                  );
                }),

          ],
        )
      ),
    );
    }
  }


