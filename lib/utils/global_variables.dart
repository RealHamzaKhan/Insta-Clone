import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Screens/add_post_screen.dart';
import 'package:instagram_clone/Screens/feed_scren.dart';
import 'package:instagram_clone/Screens/notification_screen.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/Screens/searchscreen.dart';
import 'package:provider/provider.dart';
const webScreenSize=600;
final feedScrollController=ScrollController();
var homeScreenItems=[
  FeedScreen(),
  SearchScreen(),
  AddPost(),
  NotificationScreen(),
  ProfileScreen(uid:FirebaseAuth.instance.currentUser!.uid)
];