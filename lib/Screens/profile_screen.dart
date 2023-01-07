

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/profile_stats.dart';
class ProfileScreen extends StatefulWidget {
  String uid;
  ProfileScreen({Key? key,required this.uid}) : super(key: key);

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
      followers=usernamesnap['followers'].length;
      following=usernamesnap['following'].length;
      _isfollowing=usernamesnap['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      followersDetails=usernamesnap['followers'];
      var posts=await FirebaseFirestore.instance.collection('posts').where('uid',isEqualTo:widget.uid).get();
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
  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      return Center(
      child: CircularIndicator,
    );
    } else {
      return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: ()async{
            await AuthMethods().signOutUser();
            Navigator.pushNamed(context, RoutesNames.loginScreen);
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ProfileStats(value: postlength, name: 'POSTS'),
                              ProfileStats(value: followers, name: 'FOLLOWERS'),
                              ProfileStats(value: following, name: 'FOLLOWING'),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                          Row(
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
                                  }): _isfollowing?
                              FollowButton(title: 'Unfollow',
                                  backgroundColors: Colors.white70,
                                  borderColor: Colors.blueAccent,
                                  textColor: Colors.black,
                                  onpress: (){
                                FireStoreMethods().unFollowUser(uid: FirebaseAuth.instance.currentUser!.uid,followeruid: widget.uid);
                                setState(() {
                                  followers--;
                                  _isfollowing=false;
                                });
                                  })
                              :FollowButton(title: 'Follow',
                                  backgroundColors: Colors.blueAccent,
                                  borderColor: Colors.blueAccent,
                                  textColor: Colors.white,
                                  onpress: ()async{
                                    await  FireStoreMethods().followUser(uid: FirebaseAuth.instance.currentUser!.uid,followeruid: widget.uid);
                                    setState(() {
                                      followers++;
                                      _isfollowing=true;
                                    });
                                  })
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 15),
                child: Text(username,textDirection: TextDirection.ltr,style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),)
                ),
                Container(alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 15),
                    child: Text(bio,textDirection: TextDirection.ltr,style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400
                    ),)
                ),
              ],
            ),
          ),
          Divider(),
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context,index){
                        return Container(
                          constraints: BoxConstraints(
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
    );
    }
  }
}

