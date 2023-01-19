import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';
class MessageBubbles extends StatefulWidget {
  String profilePic;
  String message;
  final date;
  bool isReciever;
  MessageBubbles({Key? key,
  required this.profilePic,
    required this.message,
    required this.date,
    required this.isReciever
  }) : super(key: key);

  @override
  State<MessageBubbles> createState() => _MessageBubblesState();
}

class _MessageBubblesState extends State<MessageBubbles> {
  @override
  void initState() {
    checkMessage();
    // TODO: implement initState
    super.initState();
  }
  bool? isImage;
  void checkMessage(){
    var input = widget.message;
    Uri? url;
    try{
      url = Uri.tryParse(input);
    }catch(e){
      url = null;
    }

    if(url != null && url.isAbsolute) {
      //input is url
      isImage=true;
    } else {
    //input is text
    isImage=false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return widget.isReciever?Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.profilePic),
              ),
              FittedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.6,
                  constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only
                      (topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: isImage!?Image(image: NetworkImage(widget.message)):Text(widget.message),
                  ),
                ),
              ),
              Text(DateFormat.yMMMd().format(widget.date.toDate()),style: const TextStyle(
                  color: secondaryColor,
                  fontSize: 12
              ),),
            ],
          ),

        ],
      ),
    ):
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(DateFormat.yMMMd().format(widget.date.toDate()).toString(),style: const TextStyle(
                  color: secondaryColor,
                  fontSize: 12
              ),),
              FittedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.6,
                  constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only
                      (topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    color: Colors.blueAccent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: isImage!?Image(image: NetworkImage(widget.message)):Text(widget.message),
                  ),
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(widget.profilePic),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
