import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
class CustomTextFormField extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  bool isPassword;
  int maxlines;
  CustomTextFormField({
    required this.controller,
    required this.hintText,
    required this.isPassword,
    this.maxlines=1,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;
    final inputborder=OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxlines,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: EdgeInsets.symmetric(horizontal: 15),
        border: inputborder,
        focusedBorder: inputborder,
        enabledBorder: inputborder,
        filled: true,

      ),
    );
  }
}
