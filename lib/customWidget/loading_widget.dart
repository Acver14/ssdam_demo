import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:ssdam_demo/style/customColor.dart';

Widget widgetLoading() {
  return Center(
    child: LoadingBouncingGrid.square(
      size: 50,
      backgroundColor: COLOR_SSDAM,
    ),
  );
}