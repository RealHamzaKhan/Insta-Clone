import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Models/user_model.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final descriptionController=TextEditingController();
  bool _isLoading=false;
  Uint8List? _file;
  void clearFile(){
    setState(() {
      _file=null;
    });
  }
  selectImage(BuildContext parentContext)async{
    return showDialog(context: parentContext, builder: (BuildContext context){
      return SimpleDialog(
        title: Text('Add a post'),
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 10,),
                Text('Choose from Camera')
              ],
            ),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file=await Utils().pickImage(ImageSource.camera);
              setState(() {
                _file=file;
              });

            },
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.browse_gallery),
                SizedBox(width: 10,),
                Text('Choose from Gallery')
              ],

            ),
            onPressed: ()async{
              Navigator.of(context).pop();
              Uint8List file=await Utils().pickImage(ImageSource.gallery);
              setState(() {
                _file=file;
              });
            },
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.cancel),
                SizedBox(width: 10,),
                Text('Cancel')
              ],
            ),
            onPressed: (){
              Navigator.of(context).pop();

            },
          ),
        ],
      );
    });
  }
  void postImage(String uid,String username,String profImage)async{
    setState(() {
      _isLoading=true;
    });
    try {
      String res=await FireStoreMethods().postImage(uid,
          descriptionController.text,
          username,
          _file!,
          profImage);
      if(res=='success'){
        Utils().showSnackBar(context,'Posted', Colors.greenAccent);
        setState(() {
          _isLoading=false;
        });
        clearFile();
      }
      else{
        Utils().showSnackBar(context, res, Colors.red);
        setState(() {
          _isLoading=false;
        });
      }
    } catch (e) {
      Utils().showSnackBar(context, e.toString(), Colors.red);
      setState(() {
        _isLoading=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;
    final UserProvider userProvider=Provider.of<UserProvider>(context);
    return _file==null?Center(
      child: IconButton(onPressed: (){
        selectImage(context);
      }, icon: Icon(Icons.upload)),
    )
    : Scaffold(
      appBar: _isLoading==true?AppBar(backgroundColor: mobileBackgroundColor,):AppBar(
        centerTitle: false,
        backgroundColor: mobileBackgroundColor,
        leading: GestureDetector(
            onTap: (){
              clearFile();
            },
            child: Icon(Icons.arrow_back,color: primaryColor,size: 28,)),
        title:
          const Text('Post to',style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24
          ),),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
            child: GestureDetector(
              onTap: (){
                postImage(userProvider.getUser.uid, userProvider.getUser.username, userProvider.getUser.photourl);
              },
              child: Text('Post',style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),),
            ),
          )
        ],
      ),
      body: _isLoading==true?
      Center(
        child: Container(
          height: height*0.1,
          width: width*0.2,
          child: LoadingIndicator(
              indicatorType: Indicator.ballRotateChase, /// Required, The loading type of the widget
              colors: const [Colors.white],       /// Optional, The color collections
              strokeWidth: 1,                     /// Optional, The stroke of the line, only applicable to widget which contains line
              backgroundColor: Colors.black,      /// Optional, Background of the widget
              pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
          ),
        ),
      ):
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userProvider.getUser.photourl),
              ),
              Container(
                width: width*0.4,
                child: TextFormField(
                  maxLines: 8,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description.....',
                    contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: height*0.13,
                width: width*0.2,
                child: AspectRatio(aspectRatio: 487/451,

                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: MemoryImage(_file!),
                    fit: BoxFit.fill,
                      alignment: FractionalOffset.topCenter
                    )
                  ),
                ),),
              )
            ],
          ),
        ],
      ),
    );
  }
}