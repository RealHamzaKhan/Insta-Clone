import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/notification_card.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: mobileBackgroundColor,
        ),
        body: FutureBuilder(
            future: FirebaseFirestore.instance.collection('notifications').orderBy('datetime',descending: true).where('reciveruid',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get(),
            builder: (context,AsyncSnapshot<QuerySnapshot<Map<String,dynamic>>>snapshot){
          if(!snapshot.hasData || snapshot.connectionState==ConnectionState.waiting || snapshot.hasError){
            return Center(child: CircularIndicator,);
          }
          else{
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context,index){
              return NotificationCard(snap: snapshot.data!.docs[index],);
            });
          }
        })
      ),
    );
  }
}
