import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';
class WebLayout extends StatelessWidget {
  const WebLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.pushNamed(context, RoutesNames.loginScreen);
          });

        }, icon: Icon(Icons.logout)),
      ),
      body: Container(
        child: Center(
          child: Text('This is web'),
        ),
      ),
    );
  }
}