import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
class ProfileStats extends StatelessWidget {
  int value;
  String name;
   ProfileStats({Key? key,required this.value,required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value.toString(),style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(name,style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13
            ),),
          )
        ],
      ),
    );
  }
}
