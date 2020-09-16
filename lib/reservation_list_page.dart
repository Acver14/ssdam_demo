import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
import 'package:popup_box/popup_box.dart';
import 'package:ssdam_demo/signedin_page.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:logger/logger.dart';
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
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
    await fp.setUserInfo();
    return reservation_infos = await Firestore.instance
        .collection('reservationList')
        .document(fp.getUser().uid)
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
      body: FutureBuilder(
          future: Loading(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return widgetLoading();
            } else {
              if (snapshot.data.documents.length > 0) {
                getReservationList(snapshot);
                print('length:${snapshot.data.documents.length}');
                return new Scrollbar(
                    isAlwaysShown: true,
                    controller: _infiniteController,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: _infiniteController,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return getReservationInfo(
                            index, snapshot.data.documents.length);
                      },
                    )
                );
                    } else {
                      return new Center(child: Text("예약건이 없습니다."));
                    }
                  }
                }),
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
        type = "쓰레기 수거";
      }
      if (doc["state"].toString() == 'register') {
        state = '접수';
      }
      else if (doc["state"].toString() == 'cancel') {
        state = '취소';
      }
      else if (doc["state"].toString() == 'complete') {
        state = '완료';
      }
      return new Card(
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(type),
                doc['state'] != 'cancel' ? new IconButton(
                    icon: new Icon(Icons.delete),
                    onPressed: () async {
                      //print(Timestamp.now().toDate().difference((doc["reservationTime"]).toDate()).inHours);
                      PopupBox.showPopupBox(
                        context: context,
                        button: Row(
                          children: [
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                            ),
                            color: COLOR_SSDAM,
                            child: Text(
                              '취소',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(width: 10),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: COLOR_SSDAM,
                            child: Text(
                              '확인',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () async {
                              await Firestore.instance
                                  .collection('reservationList')
                                  .document(fp
                                  .getUser()
                                  .uid)
                                  .collection('reservationInfo')
                                  .document(reservationID)
                                  .setData({'state': 'cancel'}, merge: true);
                              if ((doc["reservationTime"])
                                  .toDate()
                                  .difference(Timestamp.now().toDate())
                                  .inHours > 3) {
                                await Firestore.instance
                                    .collection('userInfo')
                                    .document(fp
                                    .getUser()
                                    .uid)
                                    .updateData({
                                  "tickets": fp.getUserInfo()['tickets'] + 1
                                });
                                setState(() {});
                              }
                              print('예약 삭제 성공');
                              setState(() {
                                Loading();
                                cancelNotification(doc['applicationTime']
                                    .millisecondsSinceEpoch
                                    - DateTime(
                                        DateTime
                                            .now()
                                            .year,
                                        DateTime
                                            .now()
                                            .month,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0).millisecondsSinceEpoch);
                              });
                              Navigator.of(context).pop();
                              return await PopupBox.showPopupBox(
                                context: context,
                                button: MaterialButton(
                                  onPressed: () {
                                    (context as Element).reassemble();
                                    Navigator.pop(context);
                                  },
                                ),
                                willDisplayWidget: Center(
                                    child: Text(
                                      '${fp.getUserInfo()['name']}님\n'
                                          '${doc["reservationTime"].toDate()}\n'
                                      //'${reservationInfo.getAddress()} ${reservationInfo.getDetailedAddress()}\n'
                                          '예약 취소 완료되었습니다.',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    )),
                              );
                            },
                          ),
                        ],
                        ),
                        willDisplayWidget: Center(
                            child: Text(
                              '${fp.getUserInfo()['name']}님\n'
                          '${doc["reservationTime"].toDate()}\n'
                          '예약 취소하시겠습니까?\n'
                          '(3시간 전 예약 취소는 이용권 반환이 불가합니다.)',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        )),
                      );
                    }) : new IconButton(icon: new Icon(Icons.delete),
                  onPressed: () {},
                  color: Colors.white.withOpacity(1.0),)
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
                        : '요청 사항이 없습니다.'}'),
                new Row(
                  children: [
                    Text('에약 상태 : '
                    ),
                    Text('${state}',
                      style: TextStyle(
                          color: state == '취소' ? Colors.red : Colors.black),)
                  ],
                )
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
