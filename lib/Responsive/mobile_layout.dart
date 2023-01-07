import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:provider/provider.dart';

import '../utils/routes/routes_names.dart';
class MobileLayout extends StatefulWidget {
  const MobileLayout({Key? key}) : super(key: key);

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  late PageController pageController;
  int _page=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController=PageController();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }
  void navigationTapped(int page){
    pageController.jumpToPage(page);
  }
  void onPageChanged(int page){
    setState(() {
      _page=page;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: homeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home,
                  color: _page==0?primaryColor:secondaryColor,
                ),
                backgroundColor: primaryColor,
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded,
                  color: _page==1?primaryColor:secondaryColor,
                ),
                backgroundColor: primaryColor,
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.add,color: _page==2?primaryColor:secondaryColor,
                ),
                backgroundColor: primaryColor,
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite,
                  color: _page==3?primaryColor:secondaryColor,),
                backgroundColor: primaryColor,
                label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.person,
                  color: _page==4?primaryColor:secondaryColor,
                ),
                backgroundColor: primaryColor,
                label: ''),
          ],
      onTap: navigationTapped,
      ),
    );
  }
}
