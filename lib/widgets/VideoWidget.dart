import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/circular_progress_indicator.dart';
import 'package:video_player/video_player.dart';
class VideoWidget extends StatefulWidget {
  String videoLink;
  VideoWidget({Key? key,required this.videoLink}) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController controller;
  @override
  void initState() {
    controller=VideoPlayerController.network(widget.videoLink)..initialize().then((value){
      setState(() {
        controller.play();
        controller.setVolume(1);
        controller.setLooping(true);
      });
    });
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ?Scaffold(
        body: Center(
            child: AspectRatio(
                aspectRatio:controller.value.aspectRatio,
                child: VideoPlayer(controller))))
        :CircularIndicator;
  }
}
