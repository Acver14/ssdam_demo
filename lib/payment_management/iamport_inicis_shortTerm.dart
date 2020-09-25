import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_flutter.dart';
/* 아임포트 결제 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_payment.dart';
/* 아임포트 결제 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:iamport_flutter/widget/iamport_webview.dart';
import 'package:ssdam_demo/point_charge_page.dart';
import 'package:provider/provider.dart';
import 'package:ssdam_demo/firebase_provider.dart';

class Payment_shortTerm5000 extends StatelessWidget {
  FirebaseProvider fp;
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
        'pg': 'html5_inicis', // PG사
        'payMethod': 'card', // 결제수단
        'name': '쓰담 이용권 구매', // 주문명
        'merchantUid':
            '${fp.getUserInfo()['email']}_shortTerm5000_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
        'amount': 5000, // 결제금액
        'buyerName': fp.getUserInfo()['name'], // 구매자 이름
        'buyerTel': '01012345678', // 구매자 연락처
        //'buyerEmail': 'example@naver.com', // 구매자 이메일
        //'buyerAddr': '서울시 강남구 신사동 661-16', // 구매자 주소
        //'buyerPostcode': '06018', // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        print(result);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PointChargePage(),
            ));
      },
    );
  }
}

class Payment_shortTerm20000 extends StatelessWidget {
  FirebaseProvider fp;
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
        'pg': 'html5_inicis', // PG사
        'payMethod': 'card', // 결제수단
        'name': '쓰담 이용권 구매', // 주문명
        'merchantUid':
        '${fp.getUserInfo()['email']}_shortTerm20000_${DateTime
            .now()
            .millisecondsSinceEpoch}', // 주문번호
        'amount': 20000, // 결제금액
        'buyerName': fp.getUserInfo()['name'], // 구매자 이름
        'buyerTel': '01012345678', // 구매자 연락처
        //'buyerEmail': 'example@naver.com', // 구매자 이메일
        //'buyerAddr': '서울시 강남구 신사동 661-16', // 구매자 주소
        //'buyerPostcode': '06018', // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        print(result);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PointChargePage(),
            ));
      },
    );
  }
}

class Payment_shortTerm40000 extends StatelessWidget {
  FirebaseProvider fp;
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
        'pg': 'html5_inicis', // PG사
        'payMethod': 'card', // 결제수단
        'name': '쓰담 이용권 구매', // 주문명
        'merchantUid':
        '${fp.getUserInfo()['email']}_shortTerm40000_${DateTime
            .now()
            .millisecondsSinceEpoch}', // 주문번호
        'amount': 40000, // 결제금액
        'buyerName': fp.getUserInfo()['name'], // 구매자 이름
        'buyerTel': '01012345678', // 구매자 연락처
        //'buyerEmail': 'example@naver.com', // 구매자 이메일
        //'buyerAddr': '서울시 강남구 신사동 661-16', // 구매자 주소
        //'buyerPostcode': '06018', // 구매자 우편번호
        'appScheme': 'example', // 앱 URL scheme
        'display': {
          'cardQuota': [2, 3] //결제창 UI 내 할부개월수 제한
        }
      }),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        print(result);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PointChargePage(),
            ));
      },
    );
  }
}
