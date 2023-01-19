import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class NotificationCard extends StatelessWidget {
  final snap;
  const NotificationCard({Key? key,required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(snap['photourl']),
            radius: 20,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: RichText(
                text:  TextSpan(
                children:[
                  TextSpan(
                    text: '${snap['username']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    )
                  ),
                  TextSpan(
                    text: ' ${snap['notification']}',
                      style: TextStyle(
                          fontSize: 16
                      )
                  )
                ]
              ),
              ),
            ),
          ),
          Text(DateFormat.yMMMd().format(snap['datetime'].toDate()))
        ],
      ),
    );
  }
}
