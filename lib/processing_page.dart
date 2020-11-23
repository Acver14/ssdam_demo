import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'customWidget/loading_widget.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:ssdam_demo/customClass/size_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:async/async.dart';
import 'package:clipboard/clipboard.dart';
import 'package:share/share.dart';
import 'package:ntp/ntp.dart';
import 'package:popup_box/popup_box.dart';
import 'package:http/http.dart' as http;

ProcessingPageState pageState;

class ProcessingPage extends StatefulWidget {
  DocumentSnapshot reservation_info;

  ProcessingPage({Key key, @required this.reservation_info}) : super(key: key);

  @override
  ProcessingPageState createState() {
    pageState = ProcessingPageState();
    return pageState;
  }
}

class ProcessingPageState extends State<ProcessingPage> {
  FirebaseProvider fp;
  var grid_height, grid_width;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _now;
  bool _load = false;
  var rider_info;
  DocumentSnapshot reservation_info;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reservation_info = widget.reservation_info;
  }

  Future<DocumentSnapshot> Loading() async {
    if (fp.getUserInfo() == null) await fp.setUserInfo();
    var processing_infos;
    logger.d(reservation_info['rider_id']);
    await Firestore.instance
        .collection('riderInfo')
        .document(reservation_info['rider_id'])
        .collection('processingReservationInfo')
        .document(reservation_info['_id'])
        .get()
        .then((value) => processing_infos = value);
    logger.d(processing_infos);
    await Firestore.instance
        .collection('riderInfo')
        .document(reservation_info['rider_id'])
        .get()
        .then((value) => rider_info = value);
    logger.d(rider_info);

    return processing_infos;
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        //extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: new IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarOpacity: 1.0,
          title: Text(
              '${DateFormat('yyyy년 MM월 dd일').format(reservation_info['reservationTime'].toDate())}, ${reservation_info["reservationTime"].toDate().hour < 12 ? '오전' : '오후'}',
              style: TextStyle(color: Colors.black)),
        ),
        drawer: sideDrawer(context, fp),
        body: FutureBuilder(
            future: Loading(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return widgetReservationInfo(snapshot);
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 15),
                  ),
                );
              } else {
                return widgetLoading();
              }
            }));
  }

  Widget widgetReservationInfo(AsyncSnapshot proccessing_reservatio_info) {
    grid_height = getDisplayHeight(context) / 10;
    grid_width = getDisplayWidth(context) / 10;

    return ListView(
      children: <Widget>[
        Container(
          height: grid_height * 5,
          child: Card(
              child: Column(
            children: [
              ListTile(
                title: Text('수거 중인 라이더 정보'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          child: Image.network(rider_info.data['profile'],
                              fit: BoxFit.cover,
                              width: getDisplayWidth(context) / 7),
                          width: grid_height,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('이름 : ${rider_info.data['name']}'),
                            InkWell(
                              child: Text('010-6214-3444'),
                              onTap: () => launchBrowser("tel://01062143444"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('예약 상세 정보'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '주소 : ${proccessing_reservatio_info.data['address']}, ${proccessing_reservatio_info.data['detailedAddress']}'),
                            Text(
                                '요청 사항 : ${proccessing_reservatio_info.data['customerRequest']}'),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )),
        )
      ],
    );
  }
}
