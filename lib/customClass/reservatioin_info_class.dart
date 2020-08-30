import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationInfoProvider with ChangeNotifier{
  String _name;
  String _uid;
  String _email;
  String _address='';
  String _detailedAddress='';
  String _customerRequests;
  DateTime _reservationTime;
  DateTime _applicationTime;

  ReservationInfoProvider(){
    _detailedAddress='';
    _address='';
    _customerRequests='';
  }

  // Setter
  void setInitialInfo(String name, String uid, String email){
    this._name = name;
    this._uid = uid;
    this._email = email;
  }
  void setAddress(String address)=>this._address=address;
  void setDetailedAddress(String address)=>this._detailedAddress=address;
  void setReservationTime(DateTime dt)=>this._reservationTime=dt;
  void setApplicationTime(DateTime dt)=>this._applicationTime=dt;
  void setCustomerRequests(String rq)=>this._customerRequests=rq;

  //Getter
  String getName(){return _name;}
  String getUid(){return _uid;}
  String getEmail(){return _email;}
  String getAddress(){return _address;}
  String getDetailedAddress(){return _detailedAddress;}
  String getCustomerRequests(){return _customerRequests;}
  DateTime getReservationTime(){return _reservationTime;}
  DateTime getApplicationTime(){return _applicationTime;}

  Future<void> saveReservationInfo(String rType) async {
    Firestore.instance.collection('reservationList')
        .document(_email).collection('reservationInfo')
        .document(Timestamp.fromMillisecondsSinceEpoch(_applicationTime.millisecondsSinceEpoch).toString())
        .setData({
      "name": _name,
      "email": _email,
      "address": _address,
      "detailedAddress": _detailedAddress,
      "reservationTime": _reservationTime,
      "applicationTime": _applicationTime,
      "customerRequest": _customerRequests,
      "type": rType,
      "state": 'register'
    }
    );
  }

}