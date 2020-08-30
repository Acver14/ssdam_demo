import 'package:flutter/material.dart';

class Constant {
  static List<int> twelveHourFormat = List.generate(12, (i) => i + 1);

  static List<String> meridiemFormat = ["AM", "PM"];

  static List<int> minuteAndSecondFormat = List.generate(60, (i) => i);

  static List<int> twentyFourHourFormat = new List();

  static void setTimeRange(int _start, int _end){
    if(twentyFourHourFormat != null) twentyFourHourFormat.clear();
    for(int i = _start; i < _end; i++){
      twentyFourHourFormat.add(i);
    }
  }
  static void setMinuteRange(int _start, int _end){
    if(minuteAndSecondFormat != null) minuteAndSecondFormat.clear();
    for(int i = _start; i < _end; i+=5){
      minuteAndSecondFormat.add(i);
    }
  }
}
