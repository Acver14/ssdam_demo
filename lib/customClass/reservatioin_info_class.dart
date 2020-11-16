import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ntp/ntp.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'server_host.dart';
import 'package:popup_box/popup_box.dart';

class ReservationInfoProvider with ChangeNotifier {
  String _name;
  String _uid;
  String _email;
  String _address = '';
  String _detailedAddress = '';
  String _customerRequests;
  DateTime _reservationTime;
  DateTime _applicationTime;
  bool _promotion;

  ReservationInfoProvider() {
    _detailedAddress = '';
    _address = '';
    _customerRequests = '';
  }

  // Setter
  void setInitialInfo(String uid, String email) {
    this._uid = uid;
    this._email = email;
  }

  void setName(String name) => this._name = name;

  void setAddress(String address) => this._address = address;

  void setDetailedAddress(String address)=>this._detailedAddress=address;

  void setReservationTime(DateTime dt)=>this._reservationTime=dt;

  void setApplicationTime(DateTime dt)=>this._applicationTime=dt;

  void setCustomerRequests(String rq) => this._customerRequests = rq;

  void setPromotion(bool pr) => this._promotion = pr;

  //Getter
  String getName(){return _name;}

  String getUid(){return _uid;}

  String getEmail(){return _email;}

  String getAddress(){return _address;}

  String getDetailedAddress(){return _detailedAddress;}

  String getCustomerRequests(){return _customerRequests;}

  DateTime getReservationTime() {
    return _reservationTime;
  }

  DateTime getApplicationTime() {
    return _applicationTime;
  }

  bool getPromotion() {
    return _promotion;
  }

  Future<bool> saveReservationInfo(String rType, BuildContext context) async {
    var _now = await NTP.now();
    var tomorrow = new DateTime(_now.year, _now.month, _now.day + 1, 9);
    logger.d('$tomorrow  $_reservationTime');
    logger.d(_reservationTime.isBefore(tomorrow));
    // try{
    //   if((_reservationTime.isAfter(_now) && _reservationTime.isBefore(tomorrow)) || _reservationTime.isAtSameMomentAs(tomorrow)){
    //     final response = await http.post(rider_batch_server_register,
    //         body: json.encode(<String, String>{
    //           "name": _name,
    //           "email": _email,
    //           "address": _address,
    //           "detailedAddress": _detailedAddress,
    //           "reservationTime": _reservationTime.toString(),
    //           "applicationTime": _applicationTime.toString(),
    //           "customerRequest": _customerRequests,
    //           "type": rType,
    //           "docId": '${_email}_${_applicationTime.millisecondsSinceEpoch}',
    //           "uid": _uid,
    //         }));
    //   }
    // }on SocketException catch (err){
    //   await PopupBox.showPopupBox(
    //       context: context,
    //       button: MaterialButton(
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //       ),
    //       willDisplayWidget: new Center(
    //           child: Text(
    //             '예약 신청이 실패하였습니다.\n같은 현상이 반복될 시 문의 부탁드립니다.',
    //             style: TextStyle(fontSize: 16, color: Colors.black),
    //           )));
    //   return false;
    // }

    await Firestore.instance
        .collection('reservationList')
        .document(_uid)
        .collection('reservationInfo')
        .document(Timestamp.fromMillisecondsSinceEpoch(
                _applicationTime.millisecondsSinceEpoch)
            .toString())
        .setData({
      "name": _name,
      "email": _email,
      "address": _address,
      "detailedAddress": _detailedAddress,
      "reservationTime": _reservationTime,
      "applicationTime": _applicationTime,
      "customerRequest": _customerRequests,
      "type": rType,
      "state": 'register',
      "promotion": _promotion,
      "_id": '${_email}_${_applicationTime.millisecondsSinceEpoch}'
    });

    await Firestore.instance
        .collection('registerReservationList')
        .document('${_email}_${_applicationTime.millisecondsSinceEpoch}')
        .setData({
      "name": _name,
      "email": _email,
      "address": _address,
      "detailedAddress": _detailedAddress,
      "reservationTime": _reservationTime,
      "applicationTime": _applicationTime,
      "customerRequest": _customerRequests,
      "type": rType,
      "uid": _uid,
    });
    return true;
  }
}