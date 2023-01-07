import 'package:flutter/material.dart';
class FollowButton extends StatefulWidget {
  VoidCallback onpress;
  String title;
  Color backgroundColors;
  Color borderColor;
  Color textColor;
  FollowButton({Key? key,
    required this.title,
    required this.backgroundColors,
    required this.borderColor,
    required this.textColor,
    required this.onpress}) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onpress,
      child: Container(
        height: MediaQuery.of(context).size.height*0.04,
        width: MediaQuery.of(context).size.width*0.5,
        decoration: BoxDecoration(
            color: widget.backgroundColors,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.borderColor)
        ),
        child: Center(
          child: Text(widget.title,style: TextStyle(
            color: widget.textColor
          ),),
        ),
      ),
    );
  }
}
