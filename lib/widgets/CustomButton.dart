import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressAction;
  final bool isLoading;
   CustomButton({
  required this.title,
  required this.onPressAction,
  required this.isLoading
  ,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: onPressAction,
        child: Container(
          height: MediaQuery.of(context).size.height*0.07,
          width: double.infinity,
          decoration:  BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: isLoading?Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ):
           Center(child: Text(title,style: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),),),
        ),
      ),
    );
  }
}
