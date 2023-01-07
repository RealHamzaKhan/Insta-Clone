import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Utils{
  pickImage(ImageSource source)async{
    final ImagePicker imagePicker=ImagePicker();
    XFile? file=await imagePicker.pickImage(source: source);
    if(file!=null){
      return file.readAsBytes();
    }
    else{
      print('No Image selected');
    }
  }
  showSnackBar(BuildContext context, String text,Color color) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,

      ),
    );
  }
}