import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationInfoProvider with ChangeNotifier{
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
  DateTime getReservationTime(){return _reservationTime;}

  DateTime getApplicationTime() {
    return _applicationTime;
  }

  bool getPromotion() {
    return _promotion;
  }

  Future<void> saveReservationInfo(String rType) async {
    Firestore.instance
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

    Firestore.instance
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
      "_id": _uid
    });
  }

}