import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/Screens/Login_Screen.dart';
import 'package:instagram_clone/Screens/Reels_screen.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../utils/colors.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          automaticallyImplyLeading: false,
          title: SvgPicture.asset(
            'assets/ic_instagram.svg',
            height: 40,
            color: primaryColor,
          ),
          centerTitle: false,
          actions: [
            Align(alignment:Alignment.topLeft,child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ReelsScreen()));
                },
                child: Icon(Icons.ondemand_video_sharp,size: 30,))),
            SizedBox( width: 20,),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('recieveruid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .where('isread', isEqualTo: false)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.hasError) {
                    return Container();
                  } else {
                   return Stack(
                      children: [
                        Container(
                          height: height * 0.04,
                          width: width * 0.09,
                          child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, RoutesNames.chatsscreen);
                              },
                              child: Image.asset(
                                'assets/messenger.png',
                                color: primaryColor,
                                fit: BoxFit.fill,
                              )),
                        ),
                        Align(
                          child: Badge(
                            showBadge: snapshot.data!.docs.isNotEmpty?true:false,
                            badgeContent: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(snapshot.data!.docs.length.toString()),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }),

          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('dateTime', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  snapshot.hasError) {
                return Center(
                  child: Container(
                      height: height * 0.1,
                      width: width * 0.2,
                      child: CircularIndicator),
                );
              }

              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: PostCard(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
