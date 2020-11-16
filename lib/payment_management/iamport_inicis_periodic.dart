import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:iamport_flutter/iamport_flutter.dart';
/* 아임포트 결제 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_payment.dart';
/* 아임포트 결제 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:iamport_flutter/widget/iamport_webview.dart';
import 'package:ssdam_demo/point_charge_page.dart';

import 'package:popup_box/popup_box.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/firebase_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

final _date_format = new DateFormat('yyyyMMdd');

class Payment_periodic20000 extends StatelessWidget {
  FirebaseProvider fp;
  DateTime dt;

  Payment_periodic20000({Key key, @required this.dt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    return IamportPayment(
      appBar: new AppBar(
        title: new Text('쓰담 이용권 구매'),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp72709337',
      /* [필수입력] 결제 데이터 */
      data: PaymentData.fromJson({
        'pg': 'html5_inicis.MOIcmakbil', // PG사
        'payMethod': 'card', // 결제수단
        'name': '쓰담 정기권 - 20000원', // 주문명
        'merchantUid':
            '${fp.getUserInfo()['email']}_periodic20000_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
        'customerUid': '${fp.getUserInfo()['email']}_periodic20000',
        'amount': 20000, // 결제금액
        'buyerName': fp.getUserInfo()['name'], // 구매자 이름
        'buyerTel': fp.getUserInfo()['phone'], // 구매자 연락처
        //'buyerEmail': 'example@naver.com', // 구매자 이메일
        //'buyerAddr': '서울시 강남구 신사동 661-16', // 구매자 주소
        //'buyerPostcode': '06018', // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'period': {
          'from': _date_format.format(dt).toString(),
          'to': _date_format.format(dt.add(Duration(days: 90))).toString()
        },
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) async {
        logger.d(result);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => PointChargePage(),
        //     ));
        if (result['success'] == 'true') {
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                onPressed: () {},
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    '결제가 완료되었습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        } else {
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                onPressed: () {},
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    '결제에 실패하였습니다.\n다른 결제 수단을 이용해주시기 바랍니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        }
        Navigator.pop(context);
      },
    );
  }
}

class Payment_periodic30000 extends StatelessWidget {
  FirebaseProvider fp;
  DateTime dt;

  Payment_periodic30000({Key key, @required this.dt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    return IamportPayment(
      appBar: new AppBar(
        title: new Text('쓰담 정기권 - 30000원'),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp72709337',
      /* [필수입력] 결제 데이터 */
      data: PaymentData.fromJson({
        'pg': 'html5_inicis.MOIcmakbil', // PG사
        'payMethod': 'card', // 결제수단
        'name': '쓰담 이용권 구매', // 주문명
        'merchantUid':
        '${fp.getUserInfo()['email']}_periodic30000_${DateTime
            .now()
            .millisecondsSinceEpoch}', // 주문번호
        'customerUid':
        '${fp.getUserInfo()['email']}_periodic30000',
        'amount': 30000, // 결제금액
        'buyerName': fp.getUserInfo()['name'], // 구매자 이름
        'buyerTel': fp.getUserInfo()['phone'], // 구매자 연락처
        //'buyerEmail': 'example@naver.com', // 구매자 이메일
        //'buyerAddr': '서울시 강남구 신사동 661-16', // 구매자 주소
        //'buyerPostcode': '06018', // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'period': {
          'from': _date_format.format(dt).toString(),
          'to': _date_format.format(dt.add(Duration(days: 90))).toString()
        },
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) async {
        print(result);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => PointChargePage(),
        //     ));
        if (result['success'] == 'true') {
          fp.setUserInfo_notify();
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                onPressed: () {},
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    '결제가 완료되었습니다.',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        } else {
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                onPressed: () {},
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    '결제에 실패하였습니다.\n다른 결제 수단을 이용해주시기 바랍니다.',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        }
        Navigator.pop(context);
      },
    );
  }
}

class Payment_periodic40000 extends StatelessWidget {
  FirebaseProvider fp;
  DateTime dt;

  Payment_periodic40000({Key key, @required this.dt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    return IamportPayment(
      appBar: new AppBar(
        title: new Text('쓰담 정기권 - 40000원'),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
              ),
            ],
          ),
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp72709337',
      /* [필수입력] 결제 데이터 */
      data: PaymentData.fromJson({
        'pg': 'html5_inicis.MOIcmakbil', // PG사
        'payMethod': 'card', // 결제수단
        'name': '쓰담 이용권 구매', // 주문명
        'merchantUid':
        '${fp.getUserInfo()['email']}_periodic40000_${DateTime
            .now()
            .millisecondsSinceEpoch}', // 주문번호
        'customerUid':
        '${fp.getUserInfo()['email']}_periodic40000',
        'amount': 40000, // 결제금액
        'buyerName': fp.getUserInfo()['name'], // 구매자 이름
        'buyerTel': fp.getUserInfo()['phone'], // 구매자 연락처
        //'buyerEmail': 'example@naver.com', // 구매자 이메일
        //'buyerAddr': '서울시 강남구 신사동 661-16', // 구매자 주소
        //'buyerPostcode': '06018', // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'period': {
          'from': _date_format.format(dt).toString(),
          'to': _date_format.format(dt.add(Duration(days: 90))).toString()
        },
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) async {
        print(result);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => PointChargePage(),
        //     ));
        if (result['success'] == 'true') {
          fp.setUserInfo_notify();
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                onPressed: () {},
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    '결제가 완료되었습니다.',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        } else {
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                onPressed: () {},
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    '결제에 실패하였습니다.\n다른 결제 수단을 이용해주시기 바랍니다.',
                    style: TextStyle(
                        fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        }
        Navigator.pop(context);
      },
    );
  }
}
