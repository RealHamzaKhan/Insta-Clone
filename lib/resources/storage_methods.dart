import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods{
  final _auth=FirebaseAuth.instance;
  final _storage=FirebaseStorage.instance;
  Future<String> uploadImageToStorage(String childname,Uint8List imagefile,bool isPost)async{
    Reference reference=_storage.ref(childname).child(_auth.currentUser!.uid);
    if(isPost){
      final postId=Uuid().v1();
      reference=reference.child(postId);
    }
    UploadTask uploadTask=reference.putData(imagefile);
    TaskSnapshot snapshot=await uploadTask;
    String downloadUrl=await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}