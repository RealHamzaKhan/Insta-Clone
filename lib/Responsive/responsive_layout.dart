import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
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
  bool _isLoading=true;
  @override
  void initState() {
    addData();
    // TODO: implement initState
    super.initState();

  }
  void addData()async{
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async{
      UserProvider userProvider=Provider.of(context,listen: false);
      await userProvider.refreshUser();
      setState(() {
        _isLoading=false;
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return _isLoading?Center(child: CircularIndicator):LayoutBuilder(builder: (BuildContext context,constraints){
      if(constraints.maxWidth>webScreenSize){
        return widget.webLayout;
      }
      else{
        return widget.mobileLayout;
      }
    });
  }
}
