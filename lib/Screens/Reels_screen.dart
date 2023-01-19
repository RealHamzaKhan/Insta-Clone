import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Provider/user_provider.dart';
import 'package:instagram_clone/Screens/profile_screen.dart';
import 'package:instagram_clone/resources/Firestore_methods.dart';
import 'package:instagram_clone/widgets/VideoWidget.dart';
import 'package:provider/provider.dart';

import '../utils/circular_progress_indicator.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/like_animation.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  TextEditingController? videoDescriptionController;
   bool _isUpload=true;
  @override
  void initState() {
    videoDescriptionController = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    videoDescriptionController!.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  Uint8List? _file;
  selectVideo(BuildContext parentContext) async {
    return showDialog(
        context: parentContext,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Add a post'),
            children: [
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Choose from Camera')
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await Utils().pickVideo(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.browse_gallery),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Choose from Gallery')
                  ],
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await Utils().pickVideo(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.cancel),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Cancel')
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return _file == null
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              actions: [
                InkWell(
                    onTap: () {
                      selectVideo(context);
                    },
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Icon(
                          Icons.add_box,
                          size: 35,
                        ))),
              ],
            ),
            body: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('reels').snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError ||
                      snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData) {
                    return Center(
                      child: CircularIndicator,
                    );
                  }
                  return PageView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            InkWell(
                                onDoubleTap: () async {
                                  FireStoreMethods().likeReel(
                                      snapshot.data!.docs[index]['likes'],
                                      FirebaseAuth.instance.currentUser!.uid,
                                      snapshot.data!.docs[index]['reelid']);
                                },
                                child: Center(
                                    child: VideoWidget(
                                        videoLink: snapshot.data!.docs[index]
                                            ['reelurl']))),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height / 2.5,
                                  horizontal: size.width * 0.03),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            FireStoreMethods().likeReel(
                                                snapshot.data!.docs[index]
                                                    ['likes'],
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                snapshot.data!.docs[index]
                                                    ['reelid']);
                                          },
                                          child: Icon(
                                            Icons.favorite,
                                            color: snapshot
                                                    .data!.docs[index]['likes']
                                                    .contains(FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid)
                                                ? Colors.red
                                                : Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                        Text(snapshot
                                            .data!.docs[index]['likes'].length
                                            .toString()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: size.height * 0.1,
                                left: size.width * 0.1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                        uid: snapshot.data!
                                                                .docs[index]
                                                            ['uid'],myProf: true,)));
                                      },
                                      child: Text(
                                        snapshot.data!.docs[index]['username'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 0.01,
                                    ),
                                    Text(
                                        snapshot.data!.docs[index]
                                            ['description'],
                                        maxLines: null),
                                  ],
                                )),
                          ],
                        );
                      });
                }),
          )
        :!_isUpload?Scaffold(body: Center(child: CircularIndicator,),): Scaffold(
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: mobileBackgroundColor,
              leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _file!.clear();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: primaryColor,
                    size: 28,
                  )),
              title: const Text(
                'Post to',
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isUpload=false;
                      });
                      await FireStoreMethods()
                          .postVideo(
                              FirebaseAuth.instance.currentUser!.uid,
                              videoDescriptionController!.text.isNotEmpty
                                  ? videoDescriptionController!.text
                                  : '',
                              userProvider.getUser.username,
                              _file!)
                          .then((value) {
                        Navigator.of(context).pop();
                        Utils().showSnackBar(context, 'Reel Uploaded', Colors.greenAccent);
                        setState(() {
                          _isUpload=true;
                        });
                      });
                    },
                    child: const Text(
                      'Post',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                )
              ],
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(userProvider.getUser.photourl),
                    ),
                    Container(
                      width: size.width * 0.4,
                      child: TextFormField(
                        maxLines: 8,
                        controller: videoDescriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Description.....',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
