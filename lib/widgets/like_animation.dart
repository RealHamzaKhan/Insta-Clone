import 'package:flutter/material.dart';
class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool isSmallLike;
  const LikeAnimation({Key? key,
  required this.child,
    required this.isAnimating,
    this.duration=const Duration(microseconds: 150),
    this.onEnd,
    this.isSmallLike=false,
  }) : super(key: key);

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation> with SingleTickerProviderStateMixin{
  late AnimationController controller;
  late Animation<double> scale;
  @override
  void initState() {
    // TODO: implement initState
    controller=AnimationController(vsync: this,duration: Duration(microseconds: widget.duration.inMilliseconds~/2));
    scale=Tween<double>(begin: 1,end: 1.2).animate(controller);
    super.initState();
  }
  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.isAnimating!=oldWidget.isAnimating){
      startAnimation();
    }
  }
  startAnimation()async{
    if(widget.isAnimating || widget.isSmallLike){
      await controller.forward();
      await controller.reverse();
      await Future.delayed(Duration(milliseconds: 200));
      if(widget.onEnd!=null){
        widget.onEnd!();
      }
    }
  }
  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale,child: widget.child,);
  }
}
