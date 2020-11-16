import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:ssdam_demo/customWidget/side_drawer.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_provider.dart';
import 'package:ssdam_demo/payment_management/iamport_inicis_periodic.dart';
import 'package:ssdam_demo/payment_management/iamport_inicis_shortTerm.dart';
import 'package:expandable/expandable.dart';
import 'package:ssdam_demo/customWidget/loading_widget.dart';
import 'package:popup_box/popup_box.dart';
import 'package:ntp/ntp.dart';

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
  bool _periodic_usable;
  bool _shortTerm_usable;
  var point_to_ticket = 1;
  var exchanged_points = 5000;
  final _refund_regulation =
      '<조항>\n\t1) 법정대리인의 동의 없는 미성년자의 계약\n\t2) 쓰담이 판매하는 유료 서비스를 소비자가 구입 후 7일 이내에 청약철회를 요구하는 경우\n\t3) 1개월 이상의 정기권 구매 고객인 경우\n\t\t- 소비자가 계약해지를 요구한 경우\n\t4) 서비스의 중지․장애\n\t\t- 사전고지하지 않은 경우\n\t\t3일 이상 서비스가 연속해서 중지되거나 장애가 발생한 경우 또는 1개월 동안의 서비스 중지․장애발생 누적시간이 72시간을 초과한 경우\n\t\t4시간 이상 서비스 중지 또는 장애로 인한 피해\n\t\t- 사전고지 한 경우\n\t\t서비스중지․장애를 사전에 고지하였으나 서비스중지․장애 시간이 10시간을 초과하는 경우\n\n<환불>\n\t1) 계약취소\n\t2) 유료 콘텐츠 구입가 환급\n\t3) 해지일 까지의 이용일수에 해당하는 금액과 잔여기간 이용요금의 10% 공제 후 환급\n\t(포인트가 주 원칙이나 협의에 따라 현금 환불도 가능)\n\t현금으로 구매한 이용권을 우선적으로 환불하는 형태로 진행됨.\n\t4) 계약해지 및 잔여기간에 대한 이용료 환급\n\t서비스 중지․장애시간을 일자로 계산하여 서비스 티켓지급\n\t초과된 시간만큼 이용기간을 무료로 연장\n\n<비고>\n\t1) 기납부한 요금은 환급하고, 미납요금 및 위약금은 청구를 금지함.\n\t2) 단,「전자상거래 등에서의 소비자보호에 관한 법률」제17조 제2항에 해당하는 경우에는 청약철회 대상에서 제외함.\n\t3) 단, 계약체결일 또는 서비스 이용 가능일로부터 7일 이내에 해지를 요구하는 경우에는 위약금 없이 이용 일수에 해당하는 금액만 공제하고 환급함.\n\t\t단, 쓰담 포인트로 구매한 정기권 티켓의 경우 환불이 불가능함\n\t4) 서비스 중지․장애시간에 대하여 다툼이 있는 경우 소비자가 회사에 통지한 후부터 계산하며, 서비스가 불가항력(천재지변 등)이나 소비자과실로 인하여 중지되거나 장애가 발생한 경우에는, 서비스 중지․장애시간 계산에서 제외함.\n\t\t사전고지라 함은 서비스 중지, 장애 24시간 이전에 고지된 것을 의미함.';
  final _expanation_for_period =
      '일반, 재활용, 음식물 쓰레기를 한데 버리면 이를 한꺼번에 해결해주는 서비스 1회 이용할 수 있는 쿠폰';
  var _load = false;
  var refundController = ExpandableController(initialExpanded: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paymentUsable();
    logger.d(_periodic_usable);
  }

  Future<DocumentSnapshot> paymentUsable() async {
    var ret;
    await Firestore.instance
        .collection('ssdamInfo')
        .document('paymentState')
        .get()
        .then((value) async {
      setState(() {
        _periodic_usable = value.data['periodic_usable'];
        _shortTerm_usable = value.data['shortTerm_usable'];
      });
      ret = value;
    });
    return ret;
  }

  Future<Map<String, dynamic>> Loading() async {
    if (fp.getUserInfo() != null) return fp.getUserInfo();
  }

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
        body: ListView(
          children: <Widget>[
            Builder(
              builder: (context) {
                if (_shortTerm_usable != null) {
                  if (_shortTerm_usable) {
                    return Center(
                        child: Container(
                            child: Card(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 5.0, 10.0, 5.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text('이용권 결제(이벤트)'),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text.rich(TextSpan(
                                                text: '1회',
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: ' + 5000point',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11))
                                                ])),
                                            SizedBox(
                                              width: 100,
                                              child: RaisedButton(
                                                child: Text('5000원',
                                                    style:
                                                    TextStyle(
                                                        color: Colors.white)),
                                                color: Color.fromRGBO(
                                                    0, 100, 0, 1),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Payment_promotion5000(),
                                                      ));
                                                  setState(() {
                                                    fp.getUserInfo();
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )))));
                  }
                  else {
                    return SizedBox();
                  }
                } else {
                  return widgetLoading();
                }
              },
            ),
            Builder(
              builder: (context) {
                if (_shortTerm_usable != null) {
                  if (_shortTerm_usable) {
                    return Center(
                        child: Container(
                            child: Card(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 5.0, 10.0, 5.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text('이용권 결제'),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text('1회'),
                                            SizedBox(
                                              width: 100,
                                              child: RaisedButton(
                                                child: Text('5000원',
                                                    style:
                                                    TextStyle(
                                                        color: Colors.white)),
                                                color: Color.fromRGBO(
                                                    0, 100, 0, 1),
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
                                              ),
                                            )
                                          ],
                                        ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //   MainAxisAlignment.spaceBetween,
                                        //   children: <Widget>[
                                        //     Text('4회'),
                                        //     SizedBox(
                                        //       width: 100,
                                        //       child: RaisedButton(
                                        //         child: Text('20000원',
                                        //             style:
                                        //             TextStyle(color: Colors.white)),
                                        //         color: Color.fromRGBO(0, 100, 0, 1),
                                        //         onPressed: () {
                                        //           Navigator.push(
                                        //               context,
                                        //               MaterialPageRoute(
                                        //                 builder: (context) =>
                                        //                     phoneTest(),
                                        //               ));
                                        //           setState(() {
                                        //             fp.getUserInfo();
                                        //           });
                                        //         },
                                        //       ),
                                        //     )
                                        //   ],
                                        // ),
                                        // Row(
                                        //   mainAxisAlignment:
                                        //   MainAxisAlignment.spaceBetween,
                                        //   children: <Widget>[
                                        //     Text('8회'),
                                        //     SizedBox(
                                        //         width: 100,
                                        //         child: RaisedButton(
                                        //           child: Text('40000원',
                                        //               style: TextStyle(
                                        //                   color: Colors.white)),
                                        //           color: Color.fromRGBO(0, 100, 0, 1),
                                        //           onPressed: () {
                                        //             Navigator.push(
                                        //                 context,
                                        //                 MaterialPageRoute(
                                        //                   builder: (context) =>
                                        //                       Payment_shortTerm40000(),
                                        //                 ));
                                        //             setState(() {
                                        //               fp.getUserInfo();
                                        //             });
                                        //           },
                                        //         ))
                                        //   ],
                                        // ),
                                      ],
                                    )))));
                  }
                  else {
                    // return Card(
                    //   child: ListTile(
                    //     title: Text('죄송합니다.'),
                    //     subtitle: Text('현재 정기 결제 상품은 점검 중입니다.'),
                    //   ),
                    // );
                    return SizedBox();
                  }
                } else {
                  return widgetLoading();
                }
              },
            ),
            Builder(
              builder: (context) {
                if (_periodic_usable != null) {
                  if (_periodic_usable) {
                    return Center(

                        child: Container(
                            child: Card(
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        10.0, 5.0, 10.0, 5.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text('정기 결제'),
                                        Center(
                                          child: Text(
                                            '매월 ${DateTime
                                                .now()
                                                .day}일 자동 결제',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 11),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text.rich(TextSpan(
                                                text: '월 4회',
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: ' + 1000point',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11))
                                                ])),
                                            SizedBox(
                                              width: 100,
                                              child: RaisedButton(
                                                child: Text('20000원',
                                                    style:
                                                    TextStyle(
                                                        color: Colors.white)),
                                                color: Color.fromRGBO(
                                                    0, 100, 0, 1),
                                                onPressed: () async {
                                                  logger.d(fp
                                                      .getUserInfo()['service']);
                                                  if (fp
                                                      .getUserInfo()['service'] ==
                                                      null) {
                                                    DateTime now = await NTP
                                                        .now();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Payment_periodic20000(
                                                                  dt: now),
                                                        ));
                                                    setState(() {
                                                      fp.getUserInfo();
                                                    });
                                                  }
                                                  else {
                                                    await PopupBox.showPopupBox(
                                                        context: context,
                                                        button: Container(
                                                          width: 0,
                                                          height: 0,
                                                          child: MaterialButton(
                                                            onPressed: () {},
                                                          ),
                                                        ),
                                                        willDisplayWidget: Column(
                                                          children: <Widget>[
                                                            Text(
                                                              '이미 다른 정기결제 서비스를 이용하고 계십니다.',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ));
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            //Text('월 6회'),
                                            Text.rich(TextSpan(
                                                text: '월 6회',
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: ' + 1500point',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11))
                                                ])),
                                            SizedBox(
                                                width: 100,
                                                child: RaisedButton(
                                                  child: Text('30000원',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  color: Color.fromRGBO(
                                                      0, 100, 0, 1),
                                                  onPressed: () async {
                                                    logger.d(fp
                                                        .getUserInfo()['service']);
                                                    if (fp
                                                        .getUserInfo()['service'] ==
                                                        null) {
                                                      DateTime now = await NTP
                                                          .now();
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                                context) =>
                                                                Payment_periodic30000(
                                                                    dt: now),
                                                          ));
                                                      setState(() {
                                                        fp.getUserInfo();
                                                      });
                                                    }
                                                    else {
                                                      await PopupBox
                                                          .showPopupBox(
                                                          context: context,
                                                          button: Container(
                                                            width: 0,
                                                            height: 0,
                                                            child: MaterialButton(
                                                              onPressed: () {},
                                                            ),
                                                          ),
                                                          willDisplayWidget: Column(
                                                            children: <Widget>[
                                                              Text(
                                                                '이미 다른 정기결제 서비스를 이용하고 계십니다.',
                                                                style: TextStyle(
                                                                    fontSize: 16,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ],
                                                          ));
                                                    }
                                                  },
                                                ))
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text.rich(TextSpan(
                                                text: '월 8회',
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: ' + 2000point',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 11))
                                                ])),
                                            SizedBox(
                                              width: 100,
                                              child: RaisedButton(
                                                child: Text('40000원',
                                                    style:
                                                    TextStyle(
                                                        color: Colors.white)),
                                                color: Color.fromRGBO(
                                                    0, 100, 0, 1),
                                                onPressed: () async {
                                                  logger.d(fp
                                                      .getUserInfo()['service']);
                                                  if (fp
                                                      .getUserInfo()['service'] ==
                                                      null) {
                                                    DateTime now = await NTP
                                                        .now();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Payment_periodic40000(
                                                                  dt: now),
                                                        ));
                                                    setState(() {
                                                      fp.getUserInfo();
                                                    });
                                                  }
                                                  else {
                                                    await PopupBox.showPopupBox(
                                                        context: context,
                                                        button: Container(
                                                          width: 0,
                                                          height: 0,
                                                          child: MaterialButton(
                                                            onPressed: () {},
                                                          ),
                                                        ),
                                                        willDisplayWidget: Column(
                                                          children: <Widget>[
                                                            Text(
                                                              '이미 다른 정기결제 서비스를 이용하고 계십니다.',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ));
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )))));
                  }
                  else {
                    // return Card(
                    //   child: ListTile(
                    //     title: Text('죄송합니다.'),
                    //     subtitle: Text('현재 정기 결제 상품은 점검 중입니다.'),
                    //   ),
                    // );
                    return SizedBox();
                  }
                } else {
                  return widgetLoading();
                }
              },
            ),

            FutureBuilder(
              future: Loading(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Center(
                      child: Container(
                          child: Card(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 5.0, 10.0, 5.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text('포인트 교환'),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          DropdownButton(
                                            value: point_to_ticket,
                                            items: [
                                              DropdownMenuItem(
                                                child: Text('1회'),
                                                value: 1,
                                              ),
                                              DropdownMenuItem(
                                                child: Text('2회'),
                                                value: 2,
                                              ),
                                              DropdownMenuItem(
                                                child: Text('3회'),
                                                value: 3,
                                              ),
                                              DropdownMenuItem(
                                                child: Text('4회'),
                                                value: 4,
                                              ),
                                              DropdownMenuItem(
                                                child: Text('5회'),
                                                value: 5,
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                point_to_ticket = value;
                                                exchanged_points = value * 5000;
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: RaisedButton(
                                              child: Text(
                                                  '$exchanged_points pt',
                                                  style:
                                                  TextStyle(
                                                      color: Colors.white)),
                                              color: Color.fromRGBO(
                                                  0, 100, 0, 1),
                                              onPressed: () async {
                                                if (fp.getUserInfo()['points'] +
                                                    fp
                                                        .getUserInfo()['promotion_points'] <
                                                    exchanged_points) {
                                                  await PopupBox.showPopupBox(
                                                      context: context,
                                                      button: Container(
                                                        width: 0,
                                                        height: 0,
                                                        child: MaterialButton(
                                                          onPressed: () {},
                                                        ),
                                                      ),
                                                      willDisplayWidget: Column(
                                                        children: <Widget>[
                                                          Text(
                                                            '포인트가 부족합니다.',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ));
                                                }
                                                else {
                                                  var paid_points = exchanged_points;
                                                  if (paid_points > fp
                                                      .getUserInfo()['promotion_points']) {
                                                    paid_points = paid_points -
                                                        fp
                                                            .getUserInfo()['promotion_points'];
                                                    Firestore.instance
                                                        .collection('userInfo')
                                                        .document(fp
                                                        .getUser()
                                                        .uid)
                                                        .setData(
                                                        {
                                                          'promotion_points': 0,
                                                          'points': fp
                                                              .getUserInfo()['points'] -
                                                              paid_points,
                                                          'tickets': fp
                                                              .getUserInfo()['tickets'] +
                                                              1
                                                        }, merge: true
                                                    );
                                                  } else {
                                                    var rest_points = fp
                                                        .getUserInfo()['promotion_points'] -
                                                        paid_points;
                                                    Firestore.instance
                                                        .collection('userInfo')
                                                        .document(fp
                                                        .getUser()
                                                        .uid)
                                                        .setData(
                                                        {
                                                          'promotion_points': rest_points,
                                                          'tickets': fp
                                                              .getUserInfo()['tickets'] +
                                                              1
                                                        }, merge: true
                                                    );
                                                  }
                                                  await fp.setUserInfo_notify();
                                                  await PopupBox.showPopupBox(
                                                      context: context,
                                                      button: Container(
                                                        width: 0,
                                                        height: 0,
                                                        child: MaterialButton(
                                                          onPressed: () {},
                                                        ),
                                                      ),
                                                      willDisplayWidget: Column(
                                                        children: <Widget>[
                                                          Text(
                                                            '이용권 교환이 완료되었습니다.',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      ));
                                                }
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )))));
                }
                else {
                  return widgetLoading();
                }
              },
            ),
            Card(
              child: ExpandableNotifier(
                child: ScrollOnExpand(
                  scrollOnExpand: true,
                  child: ExpandablePanel(
                    header: Text(
                      '   이용권이란?',
                      style: TextStyle(fontWeight: FontWeight.w600, height: 2),
                    ),
                    //collapsed: Text('...',  softWrap: true, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    expanded: Text(
                      _expanation_for_period,
                      softWrap: true,
                    ),
                    tapHeaderToExpand: true,
                    hasIcon: true,
                  ),
                ),
              ),
            ),
            Card(
              child: ExpandableNotifier(
                child: ScrollOnExpand(
                  scrollOnExpand: true,
                  child: ExpandablePanel(
                    header: Text(
                      '   환불 규정',
                      style: TextStyle(fontWeight: FontWeight.w600, height: 2),
                    ),
                    //collapsed: Text('...',  softWrap: true, maxLines: 1, overflow: TextOverflow.ellipsis,),
                    expanded: Text(
                      _refund_regulation,
                      softWrap: true,
                    ),
                    tapHeaderToExpand: true,
                    hasIcon: true,
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
