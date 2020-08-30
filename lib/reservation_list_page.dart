import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:ssdam_demo/customClass/size_constant.dart';

ReservationListPageState pageState;

class ReservationListPage extends StatefulWidget {
  @override
  ReservationListPageState createState() {
    pageState = ReservationListPageState();
    return pageState;
  }
}

class ReservationListPageState extends State<ReservationListPage> {
  FirebaseProvider fp;
  final _date_format = new DateFormat('yyyy-MM-dd hh:mm');

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('예약 목록', style: TextStyle(color: Colors.black)),
        iconTheme: new IconThemeData(color: Colors.black),
        backgroundColor: Colors.white.withOpacity(0.0),
        elevation: 0,
        toolbarOpacity: 1.0,
      ),
      drawer: sideDrawer(context, fp),
      body: GridView.count(
          crossAxisCount: 1,
          padding: EdgeInsets.all(16.0),
          childAspectRatio: 5.0 / 10.0,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance
                    .collection('reservationList')
                    .document(fp.getUser().email)
                    .collection('reservationInfo')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return widgetLoading();
                  } else {
                    if (snapshot.data.documents.length > 0) {
                      return new ListView(
                          children: getReservationList(snapshot));
                    } else {
                      return new Center(child: Text("예약건이 없습니다."));
                    }
                  }
                }),
          ]),
    );
  }

  getReservationList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents.map((doc) {
      var type;
      var state;
      var reservationID = doc['applicationTime'].toString();
      if(doc["type"].toString() == 'deliver'){
        type = "쓰레기통 배송";
      }else{
        type = "쓰레기통 수거";
      }
      return new Card(
          child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(doc["name"]),
            new IconButton(
                icon: new Icon(Icons.delete),
                onPressed:() async {
                await Firestore.instance.collection('reservationList')
                    .document(fp.getUser().email).collection('reservationInfo')
                    .document(reservationID).delete();
                print('예약 삭제 성공');
                }
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('예약 시간 : ${_date_format.format(doc["reservationTime"].toDate())}'),
            new Text(
                '예약 주소 : ${doc["address"].toString()} ${doc["detailedAddress"].toString()}'),
            new Text('요청 사항 : ${doc["customerRequest"].toString()}'),
            new Text('예약 형식 : ${type}'),
          ],
        ),
      ));
    }).toList();
  }
}
