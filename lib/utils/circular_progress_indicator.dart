import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

var CircularIndicator=Container(
  height: 70,
  width: 70,
  child:   LoadingIndicator(
      indicatorType: Indicator.ballRotateChase, /// Required, The loading type of the widget
      colors: const [Colors.white],       /// Optional, The color collections
      strokeWidth: 4,                     /// Optional, The stroke of the line, only applicable to widget which contains line
      backgroundColor: Colors.black,      /// Optional, Background of the widget
      pathBackgroundColor: Colors.black   /// Optional, the stroke backgroundColor
  ),
);