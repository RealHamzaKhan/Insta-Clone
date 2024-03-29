import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../utils/circular_progress_indicator.dart';
class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Uint8List? _file;
  String url='';
  var snapshot;
  bool _isDataFetched=false;
  bool isUpdate=false;
  @override
  void initState() {
    getSnapshot();
    // TODO: implement initState
    super.initState();
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
              children: const [
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
              children: const [
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
              children: const [
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
  void getSnapshot()async{
    snapshot=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    setState(() {
      _isDataFetched=true;
    });
  }
  void profileUpdate()async{
    try{
      if(_file!=null){
       url= await StorageMethods().uploadImageToStorage('Profile Pics', _file!, false);
      }
      DocumentSnapshot snap=await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
      String res= await FireStoreMethods().updateProfile(
          uid: FirebaseAuth.instance.currentUser!.uid,
          url: url.isNotEmpty?url:snap['photourl'],
          username: username.text.isNotEmpty?username.text:snap['username'],
          bio: bio.text.isNotEmpty?bio.text:snap['bio']);
      if(res=='success'){
        Utils().showSnackBar(context, 'Updated successfully', Colors.green);
        setState(() {
          isUpdate=false;
          bio.clear();
          username.clear();
        });
      }
      else{
        Utils().showSnackBar(context, 'Unknown error occurred', Colors.red);
        setState(() {
          isUpdate=false;
        });
      }
    }
    catch (e){
      Utils().showSnackBar(context, 'Unknown error occurred', Colors.red);
      setState(() {
        isUpdate=false;
      });
    }

  }
  @override
  void dispose() {
    bio.dispose();
    username.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  TextEditingController username=TextEditingController();
  TextEditingController bio=TextEditingController();
  @override
  Widget build(BuildContext context) {
    final height=MediaQuery.of(context).size.height*1;
    final width=MediaQuery.of(context).size.width*1;
    return !_isDataFetched?
        Center(child: CircularIndicator,)
        :Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _file!=null
                        ?CircleAvatar(
                      backgroundImage: MemoryImage(_file!),
                      radius: 60,
                    )
                    :CircleAvatar(
                      backgroundImage: NetworkImage(snapshot['photourl']),
                      radius: 60,
                    ),
                    Positioned(
                        bottom: -10,
                        right: 0,
                        child: IconButton(
                            onPressed: (){
                              selectImage(context);
                            },
                            icon: Icon(Icons.camera_alt,color: Colors.blue,size: 30,)))
                  ],
                ),
                SizedBox(height: height*0.04,),
                EditProfileTextField(controller: username, hintText: snapshot['username']),
                SizedBox(height: height*0.04,),
                EditProfileTextField(controller: bio, hintText: snapshot['bio']),
                SizedBox(height: height*0.1,),
                InkWell(
                  onTap: ()async{
                    setState(() {
                      isUpdate=true;
                    });
                    profileUpdate();
                    getSnapshot();
                    setState(() {

                    });
                  },
                  child: Container(
                    constraints: const BoxConstraints(
                      maxHeight: double.infinity,
                      maxWidth: double.infinity
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                      child: !isUpdate?const Text('Update',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),):Center(child: CircularProgressIndicator())
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
class EditProfileTextField extends StatelessWidget {
  TextEditingController controller;
  String hintText;
   EditProfileTextField({Key? key,required this.controller,required this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: double.infinity
      ),
      decoration: BoxDecoration(
        color: mobileBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueGrey),
      ),
      child: TextFormField(
        maxLines: null,
        controller: controller,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            hintText: hintText,
            border: InputBorder.none
        ),
      )
    );
  }
}

