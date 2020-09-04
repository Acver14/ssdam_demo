import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
import 'package:popup_box/popup_box.dart';
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
  var length;
  final _date_format = new DateFormat('yyyy-MM-dd hh:mm');
  List<Card> reservationList;
  final ScrollController _infiniteController =
      ScrollController(initialScrollOffset: 0.0);
  QuerySnapshot reservation_infos;

  _scrollListener() {
    if (_infiniteController.offset >=
            _infiniteController.position.maxScrollExtent &&
        !_infiniteController.position.outOfRange) {
      print('top');
      setState(() {});
    }
    if (_infiniteController.offset <=
            _infiniteController.position.minScrollExtent &&
        !_infiniteController.position.outOfRange) {
      print('bottom');
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _infiniteController.addListener(_scrollListener);
    //_infiniteController.jumpTo(_infiniteController.position.maxScrollExtent)

    super.initState();
  }

  Future<QuerySnapshot> Loading() async {
    return reservation_infos = await Firestore.instance
        .collection('reservationList')
        .document(fp.getUser().email)
        .collection('reservationInfo')
        .getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      //extendBodyBehindAppBar: true,
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
            FutureBuilder(
                future: Loading(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return widgetLoading();
                  } else {
                    if (snapshot.data.documents.length > 0) {
                      getReservationList(snapshot);
                      print('length:${snapshot.data.documents.length}');
                      return new ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: _infiniteController,
                        itemCount: snapshot.data.documents.length + 1,
                        itemBuilder: (context, index) {
                          return getReservationInfo(
                              index, snapshot.data.documents.length);
                        },
                      );
                    } else {
                      return new Center(child: Text("예약건이 없습니다."));
                    }
                  }
                }),
          ]),
    );
  }

  getReservationList(AsyncSnapshot<QuerySnapshot> snapshot) {
    print(snapshot.data.toString());
    reservationList = snapshot.data.documents.map((doc) {
      var type;
      var state;
      var reservationID = doc['applicationTime'].toString();
      if (doc["type"].toString() == 'deliver') {
        type = "쓰레기통 배송";
      } else {
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
                onPressed: () async {
                  if ((doc["reservationTime"] - Timestamp.now()).hour > 3) {
                    PopupBox.showPopupBox(
                        context: context,
                        button: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.blue,
                          child: Text(
                            'Ok',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            await Firestore.instance
                                .collection('reservationList')
                                .document(fp.getUser().email)
                                .collection('reservationInfo')
                                .document(reservationID)
                                .delete();
                            setState(() {
                              Loading();
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        willDisplayWidget: Column(
                          children: <Widget>[
                            Text(
                              '예약을 취소합니다.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ));
                  }

                  print('예약 삭제 성공');
                })
          ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                    '예약 시간 : ${_date_format.format(
                        doc["reservationTime"].toDate())}'),
                new Text(
                    '예약 주소 : ${doc["address"]
                        .toString()} ${doc["detailedAddress"].toString()}'),
                new Text(
                    '요청 사항 : ${doc["customerRequest"].toString() != null
                        ? doc["customerRequest"].toString()
                        : ' '}'),
                new Text('예약 형식 : ${type}'),
              ],
            ),
          ));
    }).toList();
  }

  getReservationInfo(int index, int length) {
    print('index:${index}');
    try {
      return reservationList[length - index - 1];
    } catch (Exception, e) {
      print(e);
      //_infiniteController.jumpTo(0);
    }
  }
}
