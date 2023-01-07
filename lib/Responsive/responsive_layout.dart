import 'package:flutter/material.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../utils/global_variables.dart';
class ResponsiveLayout extends StatefulWidget {
  final Widget mobileLayout;
  final Widget webLayout;
  const ResponsiveLayout({required this.mobileLayout,required this.webLayout,Key? key}) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    addData();
  }
  addData()async{
    UserProvider userProvider=Provider.of(context,listen: false);
   await userProvider.refreshUser();
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context,constraints){
      if(constraints.maxWidth>webScreenSize){
        return widget.webLayout;
      }
      else{
        return widget.mobileLayout;
      }
    });
  }
}
