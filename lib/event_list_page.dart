import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

EventListPageState pageState;

class EventListPage extends StatefulWidget {
  @override
  EventListPageState createState() {
    pageState = EventListPageState();
    return pageState;
  }
}

class EventListPageState extends State<EventListPage> {
  FirebaseProvider fp;
  final _date_format = new DateFormat('yyyy-MM-dd');
  List<Card> eventList;
  final ScrollController _infiniteController =
      ScrollController(initialScrollOffset: 0.0);
  QuerySnapshot event_infos;

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
    return event_infos =
        await Firestore.instance.collection('eventList').getDocuments();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('이벤트', style: TextStyle(color: Colors.black)),
        iconTheme: new IconThemeData(color: Colors.black),
        backgroundColor: Colors.white.withOpacity(0.0),
        elevation: 0,
        toolbarOpacity: 1.0,
      ),
      drawer: sideDrawer(context, fp),
      body: FutureBuilder(
          future: Loading(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return widgetLoading();
            } else {
              if (snapshot.data.documents.length > 0) {
                getChargeList(snapshot);
                print('length:${snapshot.data.documents.length}');
                return Column(
                  children: [
                    Expanded(
                        child: new ListView.builder(
                      //reverse: true,
                      scrollDirection: Axis.vertical,
                      controller: _infiniteController,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return getChargeInfo(
                            index, snapshot.data.documents.length);
                      },
                    ))
                  ],
                );
              } else {
                return new Center(child: Text("이벤트가 없습니다."));
              }
            }
          }),
    );
  }

  getChargeList(AsyncSnapshot<QuerySnapshot> snapshot) {
    eventList = snapshot.data.documents.map((doc) {
      return new Card(
          child: FlatButton(
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              new Text(
                doc['title'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              new Text(
                '${_date_format.format(doc["starting_date"].toDate())} ~ ${_date_format.format(doc['ending_date'].toDate())}',
                style: TextStyle(fontSize: 14),
              ),
              //SizedBox(height: 5,),
              new Row(
                children: [
                  doc['ongoing']
                      ? Text(
                          '진행 중',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        )
                      : Text('종료',
                          style: TextStyle(color: Colors.grey, fontSize: 14))
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
        onPressed: () => launchWebView('https://' + doc['url']),
      ));
    }).toList();
  }

  getChargeInfo(int index, int length) {
    print('index:${index}');
    try {
      return eventList[length - index - 1];
    } catch (Exception, e) {
      print(e);
      _infiniteController.jumpTo(0);
    }
  }

  launchBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'could not launch';
    }
  }

  launchWebView(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'could not launch';
    }
  }
}
