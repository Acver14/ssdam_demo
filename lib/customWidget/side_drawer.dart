import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssdam_demo/customWidget/reservation_button.dart';
import 'package:ssdam_demo/firebase_provider.dart';
import 'package:ssdam_demo/point_charge_page.dart';
import 'package:ssdam_demo/style/customColor.dart';
import 'package:ssdam_demo/reservation_list_page.dart';
import 'package:provider/provider.dart';
import 'loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ssdam_demo/style/textStyle.dart';
import 'package:ssdam_demo/page_state_provider.dart';
import 'package:ssdam_demo/charge_list_page.dart';
import 'package:ssdam_demo/myPage_page.dart';
import 'package:ssdam_demo/reservation_list_page.dart';
import 'package:ssdam_demo/customClass/size_constant.dart';
import 'package:expandable/expandable.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:ssdam_demo/event_list_page.dart';
import 'package:ssdam_demo/notice_list_page.dart';

Future<Map<String, dynamic>> Loading(FirebaseProvider fp) async {
  if (fp.getUserInfo() != null) return fp.getUserInfo();
}

Widget sideDrawer(BuildContext context, FirebaseProvider fp) {
  return Drawer(
      child: ListView(
    children: [
      Column(
        //padding: EdgeInsets.zero,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 140,
                child: DrawerHeader(
                    child: Wrap(
                      children: [
                        Column(
                          children: [
                            Row(children: <Widget>[
                              Container(
                                child: Image.asset(
                                  "assets/user_default_image.png",
                                ),
                                width: 60,
                              ),
                              Padding(
                                padding: EdgeInsets.all(5),
                              ),
                              FutureBuilder(
                                  future: Loading(fp),
                                  builder: (BuildContext context,
                                      AsyncSnapshot snapshot) {
                                    if (snapshot.hasData &&
                                        !snapshot.data.isEmpty) {
                                      return userInterface(context, fp);
                                    } else {
                                      return Center(
                                        child: LoadingBouncingGrid.square(
                                          size: 50,
                                          backgroundColor: Colors.grey,
                                        ),
                                      );
                                    }
                                  })
                            ]),
                            // Container(
                            //   width: double.infinity,
                            //   decoration: BoxDecoration(
                            //     boxShadow:  [
                            //       BoxShadow(
                            //         color: COLOR_SSDAM.withOpacity(0.5),
                            //         spreadRadius: 2,
                            //         blurRadius: 7,
                            //         offset: Offset(3, 0), // changes position of shadow
                            //       ),
                            //     ],
                            //   ),
                            //   child: RaisedButton(
                            //     color: COLOR_SSDAM.withOpacity(0.5),
                            //       child: Text(
                            //         '이용권 충전',
                            //         style:TextStyle(color:Colors.black),
                            //       ),
                            //       onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder:(context)=>PointChargePage()))
                            //   ),
                            // )
                            ReservationButton(
                              text: '이용권 충전',
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PointChargePage())),
                              color: COLOR_CHARGE,
                            )
                          ],
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: COLOR_SSDAM,
                    )),
              ),
              Column(
                children: [
                  ListTile(
                      title: Text(
                        '마이페이지',
                        style: drawerMenuButtonStyle,
                      ),
                      onTap: () async {
                        await fp.setUserInfo_notify();
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => MyPage()));
                      }),
                  ListTile(
                      title: Text('예약 목록', style: drawerMenuButtonStyle),
                      onTap: () async {
                        await fp.setUserInfo_notify();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReservationListPage()));
                      }),
                  ListTile(
                      title: Text('결제 내역', style: drawerMenuButtonStyle),
                      onTap: () async {
                        await fp.setUserInfo_notify();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChargeListPage()));
                      }),
                  ListTile(
                      title: Text('이벤트', style: drawerMenuButtonStyle),
                      onTap: () async {
                        await fp.setUserInfo_notify();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventListPage()));
                      }),
                  ListTile(
                      title: Text('공지사항', style: drawerMenuButtonStyle),
                      onTap: () async {
                        await fp.setUserInfo_notify();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoticeListPage()));
                      }),
                ],
              )
            ],
          ),
          Card(
            child: ListTile(
                title: Text(
                  'Info',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                "assets/button/kakao_logo.png",
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(width: 5),
                              Text('카카오톡 채널', style: drawerInfoButtonStyle),
                            ],
                          ),
                          onTap: () => launchBrowser(
                              "http://pf.kakao.com/_RcxkLxb/friend"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.call,
                              ),
                              SizedBox(width: 5),
                              Text('010-6214-3444',
                                  style: drawerInfoButtonStyle),
                            ],
                          ),
                          onTap: () => launchBrowser("tel://01062143444"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.mail),
                              SizedBox(width: 5),
                              Text('help@ssdam.net',
                                  style: drawerInfoButtonStyle),
                            ],
                          ),
                          onTap: () => launchBrowser("mailto:help@ssdam.net"),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Divider(),
                        Container(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('쓰레기를 담다 - 쓰담\n', style: footerStyle),
                            Text(
                                '대표 이주형, 서울특별시 광진구 자양로 131, 414호\n사업자등록번호 : 521-37-00615',
                                style: footerStyle),
                            Text('통신판매업신고 서울광진-0991호', style: footerStyle),
                            InkWell(
                              child: Text('개인정보처리방침', style: footerStyle),
                              onTap: () => launchWebView(
                                  'https://ssdam.net/%EA%B0%9C%EC%9D%B8%EC%A0%95%EB%B3%B4%EC%B2%98%EB%A6%AC%EB%B0%A9%EC%B9%A8.html'),
                            ),
                          ],
                        )),
                        Container(
                            width: double.infinity,
                            child: RaisedButton(
                                child: Text("로그아웃"),
                                onPressed: () async {
                                  await fp.signOut();
                                  // Navigator.pop(context);
                                  SystemNavigator.pop();
                                }))
                      ],
                    )
                  ],
                )),
          ),
        ],
      ),
    ],
  ));
}

Widget userInterface(BuildContext context, FirebaseProvider fp) {
  return Wrap(
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${fp.getUserInfo()['name']}님 환영합니다!',
            style: TextStyle(color: Colors.white),
          ),
          // Text(
          //     'Lv. ${fp.getUserInfo()['level']}'
          // ),
          Text(
            '이용권 : ${fp.getUserInfo()['tickets'] + fp
                .getUserInfo()['p_tickets'] + fp.getUserInfo()['r_tickets']}',
            style: TextStyle(
                color: Colors.white
            ),
          ),
          Text(
            '포인트 : ${fp.getUserInfo()['points'] +
                fp.getUserInfo()['promotion_points']}',
            style: TextStyle(
                color: Colors.white
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: COLOR_SSDAM,
          //     border: Border.all(
          //       color: Colors.white
          //     ),
          //   ),
          //   child:  InkWell(
          //       child: Text(
          //         '이용권 충전',
          //         style:TextStyle(color:Colors.black),
          //       ),
          //       onTap: ()=>Navigator.push(context, MaterialPageRoute(builder:(context)=>PointChargePage()))
          //   ),
          // )
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      )
    ],
  );
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
  }
  else {
    throw 'could not launch';
  }
}