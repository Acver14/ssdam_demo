import 'package:flutter/material.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'firebase_provider.dart';
import 'package:ssdam_demo/customWidget/point_charge_button.dart';
import 'package:ssdam_demo/style/textStyle.dart';
//import 'package:ssdam/payment_management/bootpay_payapp.dart';
import 'package:ssdam_demo/payment_management/iamport_inicis_periodic.dart';
import 'package:ssdam_demo/payment_management/iamport_inicis_shortTerm.dart';

PointChargePageState pageState;

class PointChargePage extends StatefulWidget {
  @override
  PointChargePageState createState() {
    pageState = PointChargePageState();
    return pageState;
  }
}

class PointChargePageState extends State<PointChargePage> {
  FirebaseProvider fp;
  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
        drawer: sideDrawer(context, fp),
        appBar: AppBar(
          title: Text('이용권 충전', style: TextStyle(color: Colors.black)),
          iconTheme: new IconThemeData(color: Colors.black),
          backgroundColor: Colors.white.withOpacity(0.0),
          elevation: 0,
          toolbarOpacity: 1.0,
        ),
        body: Column(
          children: <Widget>[
            Center(
                child: Container(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  '정기 결제'
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('이용권 : 4 / 월'),
                                    RaisedButton(
                                      child: Text('20000원',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      color: Color.fromRGBO(0, 100, 0, 1),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Payment_periodic20000(),
                                            ));
                                        setState(() {
                                          fp.getUserInfo();
                                        });
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('이용권 : 6 / 월'),
                                    RaisedButton(
                                      child: Text('30000원',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      color: Color.fromRGBO(0, 100, 0, 1),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Payment_periodic30000(),
                                            ));
                                        setState(() {
                                          fp.getUserInfo();
                                        });
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('이용권 : 8 / 월'),
                                    RaisedButton(
                                      child: Text('40000원',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      color: Color.fromRGBO(0, 100, 0, 1),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Payment_periodic40000(),
                                            ));
                                        setState(() {
                                          fp.getUserInfo();
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ))))),
            Center(
                child: Container(
                    child: Card(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                    '단기 결제'
                               ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('이용권 : 1'),
                                    RaisedButton(
                                      child: Text('5000원',
                                          style:
                                          TextStyle(color: Colors.white)),
                                      color: Color.fromRGBO(0, 100, 0, 1),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Payment_shortTerm5000(),
                                            ));
                                        setState(() {
                                          fp.getUserInfo();
                                        });
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('이용권 : 4'),
                                    RaisedButton(
                                      child: Text('20000원',
                                          style:
                                          TextStyle(color: Colors.white)),
                                      color: Color.fromRGBO(0, 100, 0, 1),
                                      onPressed: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Payment_shortTerm20000(),
                                            ));
                                        setState(() {
                                          fp.getUserInfo();
                                        });
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('이용권 8'),
                                    RaisedButton(
                                      child: Text('40000원',
                                          style:
                                          TextStyle(color: Colors.white)),
                                      color: Color.fromRGBO(0, 100, 0, 1),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Payment_shortTerm40000(),
                                            ));
                                        setState(() {
                                          fp.getUserInfo();
                                        });
                                      },
                                    )
                                  ],
                                ),
                              ],
                            ))))),
          ],
        ));
  }
}
