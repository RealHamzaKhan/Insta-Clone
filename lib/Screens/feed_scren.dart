import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../utils/colors.dart';
class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset('assets/ic_instagram.svg',height: 40,color: primaryColor,),
        centerTitle: false,
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Image.asset('assets/messenger.png',color:primaryColor,height: height*0.009,width: width*0.07,)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>> snapshot){
          if(snapshot.connectionState==ConnectionState.waiting || !snapshot.hasData || snapshot.hasError){
            return Center(
              child: Container(
                height: height*0.1,
                width: width*0.2,
                child: CircularIndicator
              ),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context,index){
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            );
          });
          }),

    );
  }
}
