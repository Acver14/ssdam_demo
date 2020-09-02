import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';

ChargeListPageState pageState;

class ChargeListPage extends StatefulWidget {
  @override
  ChargeListPageState createState() {
    pageState = ChargeListPageState();
    return pageState;
  }
}

class ChargeListPageState extends State<ChargeListPage> {
  FirebaseProvider fp;
  final _date_format = new DateFormat('yyyy-MM-dd hh:mm');
  List<Card> chargeList;
  final ScrollController _infiniteController =
      ScrollController(initialScrollOffset: 0.0);
  QuerySnapshot charge_infos;

  _scrollListener() {
    if (_infiniteController.offset >=
            _infiniteController.position.maxScrollExtent &&
        !_infiniteController.position.outOfRange) {
      setState(() {
        print(_infiniteController.position.maxScrollExtent);
      });
    }
    if (_infiniteController.offset <=
            _infiniteController.position.minScrollExtent &&
        !_infiniteController.position.outOfRange) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _infiniteController.addListener(_scrollListener);
    //_infiniteController.jumpTo(_infiniteController.position.maxScrollExtent - 1);
    super.initState();
  }

  Future<QuerySnapshot> Loading() async {
    return charge_infos = await Firestore.instance
        .collection('chargeLog')
        .document(fp.getUser().email)
        .collection('chargeInfo')
        .getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('결제 목록', style: TextStyle(color: Colors.black)),
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
                      getChargeList(snapshot);
                      print('length:${snapshot.data.documents.length}');
                      return Expanded(
                          child: new ListView.builder(
                            //reverse: true,
                            scrollDirection: Axis.vertical,
                            controller: _infiniteController,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              return getChargeInfo(index, snapshot.data
                                  .documents.length);
                            },
                          )
                      );
                    } else {
                      return new Center(child: Text("결제건이 없습니다."));
                    }
                  }
                }),
          ]),
    );
  }

  getChargeList(AsyncSnapshot<QuerySnapshot> snapshot) {
    chargeList = snapshot.data.documents.map((doc) {
      String status;
      if (doc["status"] == "paid") {
        status = "결제";
      }
      else if (doc["status"] == "cancelled") {
        status = "환불";
      }
      return new Card(
          child: ListTile(
            title: new Text('결제 시간 : ${_date_format.format(
                DateTime.fromMillisecondsSinceEpoch(doc['charge_time']))}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                    '결제 금액 : ${doc['payment_amount']}'),
                new Text('구매 품목 : 이용권 ${doc["ticket"].toString()}'),
                new Text('리워드 : ${doc["reward"].toString()}'),
                new Text('결제 상태 : ${status}')
              ],
            ),
          ));
    }).toList();
  }

  getChargeInfo(int index, int length) {
    print('index:${index}');
    try {
      return chargeList[length - index - 1];
    } catch (Exception, e) {
      print(e);
      _infiniteController.jumpTo(0);
    }
  }

}
