import 'package:flutter/material.dart';
import 'package:instagram_clone/Responsive/mobile_layout.dart';
import 'package:instagram_clone/Responsive/responsive_layout.dart';
import 'package:instagram_clone/Responsive/web_layout.dart';
import 'package:instagram_clone/Screens/chats_screen.dart';
import 'package:instagram_clone/Screens/edit_profile.dart';
import 'package:instagram_clone/Screens/signup_screen.dart';
import 'package:instagram_clone/utils/routes/routes_names.dart';

import '../../Screens/Login_Screen.dart';

class Routes{
  static MaterialPageRoute generateRoute(RouteSettings routeSettings){
    switch(routeSettings.name){
      case RoutesNames.loginScreen:
        return MaterialPageRoute(builder: (BuildContext context)=>LoginScreen());
      case RoutesNames.signupScreen:
        return MaterialPageRoute(builder: (BuildContext context)=>SignupScreen());
      case RoutesNames.responsivelayout:
        return MaterialPageRoute(builder: (BuildContext context)=>ResponsiveLayout(mobileLayout: MobileLayout(), webLayout:WebLayout()));
      case RoutesNames.mobilelayout:
        return MaterialPageRoute(builder: (BuildContext context)=>MobileLayout());
      case RoutesNames.weblayout:
        return MaterialPageRoute(builder: (BuildContext context)=>WebLayout());
      case RoutesNames.editprofile:
        return MaterialPageRoute(builder: (BuildContext context)=>EditProfile());
      case RoutesNames.chatsscreen:
        return MaterialPageRoute(builder: (BuildContext context)=>ChatsScreen());
    // case RoutesNames.verifyCode:
    //   return MaterialPageRoute(builder: (BuildContext context)=>VerifyCodeScreen());
      default:
        return MaterialPageRoute(builder: (_){
          return Scaffold(
            body: Center(
              child: Text('No route defined'),
            ),
          );
        });
    }
  }
}