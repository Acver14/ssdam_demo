
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
import 'customWidget/loading_widget.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:ssdam_demo/customClass/size_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:async/async.dart';

MyPageState pageState;

class MyPage extends StatefulWidget {
  @override
  MyPageState createState() {
    pageState = MyPageState();
    return pageState;
  }
}

class MyPageState extends State<MyPage> {
  FirebaseProvider fp;
  var grid_height, grid_width;
  QuerySnapshot reservation_infos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<Map<String, dynamic>> Loading() async {
    Map<String, dynamic> _user_info = null;
    await fp.setUserInfo();
    _user_info = fp.getUserInfo();

    reservation_infos = await Firestore.instance
        .collection('reservationList')
        .document(fp.getUser().uid)
        .collection('reservationInfo')
        .getDocuments();
    if (_user_info != null) {
      return _user_info;
    }
  }

  @override
  Widget build(BuildContext context){
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarOpacity: 1.0,
        title: Text('마이페이지',style: TextStyle(color: Colors.black)),
      ),
      drawer: sideDrawer(context, fp),
      body: FutureBuilder(
          future: Loading(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && !snapshot.data.isEmpty) {
              return widgetUserInfo();
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
          }),
    );
  }

  Widget widgetUserInfo(){
    grid_height = getDisplayHeight(context) / 10;
    grid_width = getDisplayWidth(context) / 10;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Card(
          child: Row(
            children: [
            SizedBox(
              width: 15,
            ),
            Container(
              child: Image.asset("assets/user_default_image.png"),
              width: grid_height / 2,
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('이름 : ${fp.getUserInfo()['name']}'),
                Text('이메일 : ${fp.getUserInfo()['email']}')
              ],
            )
          ],
          )
        ),
        Row(
          children: [
            Container(
              width: grid_width * 5,
              child: Card(
                  child:ListTile(
                    title: Text(
                        '이용권'
                    ),
                    subtitle: Text('${fp.getUserInfo()['tickets']}'),
                  )
              ),
            ),
            Container(
              width: grid_width * 5,
              child:Card(
                  child:ListTile(
                    title: Text(
                        '리워드'
                    ),
                    subtitle: Text('${fp.getUserInfo()['points']}'),
                  )
              )
            )
          ],
        ),
        serviceState(),
        reservationInfoChart()
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  Widget serviceState(){
    var service;

    if (fp.getUserInfo()['service'] == null ||
        fp.getUserInfo()['service'] == '') {
      return Card(
          child: ListTile(
        title: Text('이용 중인 서비스가 없습니다.'),
      ));
    } else {
      switch (fp.getUserInfo()['service']) {
        case 'periodic20000':
          service = "정기권 20000원";
          break;
        case 'periodic30000':
          service = "정기권 30000원";
          break;
        case 'periodic40000':
          service = "정기권 40000원";
          break;
      }
      return Card(
          child: ListTile(
            title: Text(
              '이용 중인 서비스 : ${service}'
            ),
            subtitle: Text(
              '결제일 : ${fp.getUserInfo()['publish_date']}일'
            ),
          )
      );
    }
  }

  Widget reservationInfoChart() {
    final fromDate = DateTime.now().subtract(Duration(days: 180));
    final toDate = DateTime.now();

    final date1 = DateTime.now().subtract(Duration(days: 1));
    final date2 = DateTime.now().subtract(Duration(days: 30));

    final date3 = DateTime.now().subtract(Duration(days: 60));
    final date4 = DateTime.now().subtract(Duration(days: 90));

    final date5 = DateTime.now().subtract(Duration(days: 120));
    final date6 = DateTime.now().subtract(Duration(days: 150));

    var value1 = 0.0;
    var value2 = 0.0;
    var value3 = 0.0;
    var value4 = 0.0;
    var value5 = 0.0;
    var value6 = 0.0;
    print(fromDate);
    print(toDate);
    List<DocumentSnapshot> reservation_info = reservation_infos.documents;
    reservation_info.forEach((element) {
      DateTime temp;
      if (element.data['state'] == 'complete' ||
          element.data['state'] == 'register') {
        temp = Timestamp.fromMillisecondsSinceEpoch(
                int.parse(element.documentID.split('=')[1].split(',')[0]) *
                    1000)
            .toDate();
      }
      //DateTime temp = DateTime.fromMicrosecondsSinceEpoch(element.data['reservationTime']);
      print(temp);
      print(int.parse(element.documentID.split('=')[1].split(',')[0]));
      print(DateTime.now().difference(temp).inDays);
      if (DateTime.now().difference(temp).inDays < 151) {
        switch ((DateTime.now().difference(temp).inDays ~/ 30)) {
          case 5:
            value6 += 1.0;
            break;
          case 4:
            value5 += 1.0;
            break;
          case 3:
            value4 += 1.0;
            break;
          case 2:
            value3 += 1.0;
            break;
          case 1:
            value2 += 1.0;
            break;
          case 0:
            value1 += 1.0;
            break;
        }
      }
    });

    print("1: ${value1}, 2: ${value2}, 3 : ${value3}, 4 : ${value4}, 5 : ${value5}, 6 : ${value6}");
        return Card(
          child:ListTile(
            title: Text('최근 6개월 이용 내역'),
            subtitle: Center(
              child: Container(
                color: Colors.white,
                height: grid_height * 4,
                width: grid_width * 10,
                child: BezierChart(
                  bezierChartScale: BezierChartScale.MONTHLY,
                  fromDate: fromDate,
                  toDate: toDate,
                  selectedDate: toDate,
                  series: [
                    BezierLine(
                      label: "회 예약",
                      lineColor: COLOR_SSDAM,
                      lineStrokeWidth: 2.0,
                      onMissingValue: (dateTime) {
                        return 0.0;
                      },
                      data: [
                        DataPoint<DateTime>(value: value1, xAxis: date1),
                        DataPoint<DateTime>(value: value2, xAxis: date2),
                        DataPoint<DateTime>(value: value3, xAxis: date3),
                        DataPoint<DateTime>(value: value4, xAxis: date4),
                        DataPoint<DateTime>(value: value5, xAxis: date5),
                        DataPoint<DateTime>(value: value6, xAxis: date6),
                      ],
                    ),
                  ],

                  config: BezierChartConfig(
                    displayLinesXAxis: true,
                    verticalIndicatorStrokeWidth: 10.0,
                    verticalIndicatorColor: Colors.black26,
                    showVerticalIndicator: true,
                    verticalIndicatorFixedPosition: false,
                    backgroundColor: Colors.white60,
                    footerHeight: grid_height,
                    xAxisTextStyle: TextStyle(color: Colors.black),
                    yAxisTextStyle: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          )
        );
  }
}
