import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ssdam_demo/auth/enroll_email_page.dart';

// import 'package:kakao_flutter_sdk/auth.dart';
// import 'package:kakao_flutter_sdk/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:popup_box/popup_box.dart';
import 'dart:io';
import 'package:apple_sign_in_firebase/apple_sign_in_firebase.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'dart:math';

Logger logger = Logger();

class FirebaseProvider with ChangeNotifier {
  final FirebaseAuth fAuth = FirebaseAuth.instance; // Firebase 인증 플러그인의 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthResult authResult;
  final FacebookLogin facebookLogin = FacebookLogin();
  FirebaseUser _user; // Firebase에 로그인 된 사용자
  var _user_info = Map<String, dynamic>();
  var token;
  String _lastFirebaseResponse = ""; // Firebase로부터 받은 최신 메시지(에러 처리용)
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  FirebaseProvider() {
    logger.d("init FirebaseProvider");
    _prepareUser();
    _firebaseMessaging.getToken().then((_token) {
      token = _token;
    });
  }

  setDeviceToken() async {
    await Firestore.instance
        .collection('userInfo')
        .document(_user.uid)
        .setData({'token': token}, merge: true);
  }

  FirebaseUser getUser() {
    return _user;
  }

  void setUser(FirebaseUser value) {
    _user = value;
    notifyListeners();
  }

  // 최근 Firebase에 로그인한 사용자의 정보 획득
  _prepareUser() async {
    await fAuth.currentUser().then((FirebaseUser currentUser) async {
      setUser(currentUser);
      await setUserInfo_notify();
      logger.d('${_user.email} \n ${_user_info.toString()}');
      notifyListeners();
    });
  }

  // 이메일/비밀번호로 Firebase에 회원가입
  Future<bool> signUpWithEmail(String email, String password, String phone,
      bool marketing, bool personal,
      [String recommendedCode]) async {
    try {
      AuthResult result = await fAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        _user = result.user;
        if (recommendedCode != null)
          await enroll_user_info(phone, marketing, personal, recommendedCode);
        else
          await enroll_user_info(phone, marketing, personal);
        //사용자 이름 업데이트
        // UserUpdateInfo uui = UserUpdateInfo();
        // uui.displayName = name;
        // await result.user.updateProfile(uui);
        // 새로운 계정 생성이 성공하였으므로 기존 계정이 있을 경우 로그아웃 시킴
        // 인증 메일 발송
        //result.user.sendEmailVerification();
        logger.d('send verification');
        // await Firestore.instance
        //     .collection('fcmTokenInfo')
        //     .document(_user_info['email'])
        //     .setData({'token': _token}, merge: false);
        signOut();
        return true;
      }
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  // 이메일/비밀번호로 Firebase에 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      var result = await fAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result != null) {
        setUser(result.user);
        await setUserInfo();
        logger.d(getUser());
        // await Firestore.instance
        //     .collection('fcmTokenInfo')
        //     .document(_user_info['email'])
        //     .setData({'token': _token}, merge: false);
        return true;
      }
      return false;
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  // 구글 계정을 이용하여 Firebase에 로그인
  Future<bool> signInWithGoogleAccount() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final authResult = await fAuth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;

      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await fAuth.currentUser();
      assert(user.uid == currentUser.uid);
      setUser(user);
      await setUserInfo();
      return true;
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  Future<bool> signInWithAppleAccount(BuildContext context) async {
    try {
      if (Platform.isIOS) {
        if (!await AppleSignIn.isAvailable()) {
          logger.e('애플 로그인 사용 불가');
          setLastFBMessage('해당 소프트웨어 버전에서는 애플 로그인을 사용할 수 없습니다.');
          return false;
        }
        AuthorizationRequest authorizationRequest = AppleIdRequest(
            requestedScopes: [Scope.email, Scope.fullName]);
        AuthorizationResult authorizationResult = await AppleSignIn
            .performRequests([authorizationRequest]);
        logger.d(authorizationResult);
        AppleIdCredential appleCredential = authorizationResult.credential;

        OAuthProvider provider = new OAuthProvider(providerId: "apple.com");
        logger.d(appleCredential.toString());
        AuthCredential credential = provider.getCredential(
          idToken: String.fromCharCodes(appleCredential.identityToken),
          accessToken: String.fromCharCodes(
              appleCredential.authorizationCode),);
        FirebaseAuth auth = FirebaseAuth.instance;
        AuthResult authResult = await auth.signInWithCredential(credential);
        // 인증에 성공한 유저 정보
        FirebaseUser user = authResult.user;
        String name = appleCredential.fullName.givenName;
        logger.d('user name for apple : ${name}');
        UserUpdateInfo uui = UserUpdateInfo();
        uui.displayName = name;
        await user.updateProfile(uui);
        setUser(user);
        await enroll_user_info(null, false, true);
        await setUserInfo();
        // await Firestore.instance
        //     .collection('userInfo')
        //     .document(user.uid)
        //     .setData({'name': name}, merge: true);
      } else {
        final Map appleCredential = await AppleSignInFirebase.signIn();
        //logger.d(String.fromCharCodes(appleCredential['idToken']));
        OAuthProvider provider = new OAuthProvider(providerId: "apple.com");
        AuthCredential credential = provider.getCredential(
          idToken: appleCredential['idToken'],
          accessToken: appleCredential['accessToken'],);
        FirebaseAuth auth = FirebaseAuth.instance;
        AuthResult authResult = await auth.signInWithCredential(credential);
        // 인증에 성공한 유저 정보
        FirebaseUser user = authResult.user;
        setUser(user);
        await setUserInfo();
        // await Firestore.instance
        //     .collection('userInfo')
        //     .document(user.uid)
        //     .setData({'name': user.displayName}, merge: true);
      }
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  Future<bool> signInWithFacebookAccount(BuildContext context) async {
    try {
      var log = Logger();
      FacebookLoginResult result =
      await facebookLogin.logIn(['email', 'public_profile']);
      log.d(result.toString());
      AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token);
      authResult = await fAuth.signInWithCredential(credential);
      final graphResponse = await http.get(
          'https://graph.facebook.com/me?fields=name,email&access_token=${result
              .accessToken.token}');
      final profile = jsonDecode(graphResponse.body);
      // if (profile['email'] == null) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => EnrollEmailPage(),
      //     ), //MaterialPageRoute
      //   );
      // }
      if (result != null) {
        setUser(authResult.user);
        await setUserInfo();
        logger.d(getUser());

        // await Firestore.instance
        //     .collection('userInfo')
        //     .document(authResult.user.uid)
        //     .setData({'name': authResult.user.displayName}, merge: true);
        if (!_user.isEmailVerified) {
          _user.sendEmailVerification();
          await PopupBox.showPopupBox(
              context: context,
              button: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              willDisplayWidget: Column(
                children: <Widget>[
                  Text(
                    'facebook에 등록하신 이메일로'
                        '인증 확인부탁드리겠습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ));
        }
        return true; // login success
      }
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  //
  // Future<bool> enroll_user_info(String email) async {
  //   try {
  //     await _user.updateEmail(email);
  //     await _user.sendEmailVerification();
  //     signOut();
  //     return true;
  //   } on Exception catch (e) {
  //     logger.e(e.toString());
  //     List<String> result = e.toString().split(", ");
  //     setLastFBMessage(result[1]);
  //     return false;
  //   }
  // }

  Future<bool> enroll_user_info(var phone, bool marketing, bool personal,
      [String recommendedCode, String email]) async {
    try {
      if (email != null) {
        await _user.updateEmail(email);
      }

      await Firestore.instance
          .collection('userInfo')
          .document(_user.uid)
          .setData({
        'name': '쓰담_${DateTime.now().millisecondsSinceEpoch % 100000}',
        'phone': phone == null ? '0' : phone,
        'email': email == null ? _user.email : email,
        'marketing': marketing,
        'personal': personal,
        'recommender': recommendedCode == null ? 'none' : recommendedCode,
        'getTrash?': false
      }, merge: true);
      await Firestore.instance
          .collection('uidSet')
          .document(email == null ? _user.email : email)
          .setData(
          {
            'phone': phone == null ? '0' : phone,
          }, merge: true);
      if (!_user.isEmailVerified) {
        await _user.sendEmailVerification();
        UserUpdateInfo uui = UserUpdateInfo();
        await _user.updateProfile(uui);
        setLastFBMessage('이메일 인증 후 로그인해주시기 바랍니다.');
        signOut();
        notifyListeners();
      } else {
        await setUserInfo();
      }
      return true;
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      logger.d(_user.uid);
      logger.e(result[0]);
      if (result[0] == 'ERROR_TOO_MANY_REQUESTS') {
        setLastFBMessage('해당 기기에서 너무 많은 요청이 발생하였습니다. 잠시 후 다시 시도해주십시오.');
      }
      else
        setLastFBMessage(result[1]);
      return false;
    }
  }

  Future<bool> setUserInfo() async {
    if (_user != null) {
      await Firestore.instance
          .collection('userInfo')
          .document(_user.uid)
          .get()
          .then((value) {
        _user_info = value.data;
        //logger.d('read db');
      });
      notifyListeners();
      return true;
    }
    else {
      notifyListeners();
      return false;
    }
  }

  Future<void> setUserInfo_notify() async {
    await setUserInfo();
    notifyListeners();
  }

  Map<String, dynamic> getUserInfo() {
    return _user_info;
  }

  // Firebase로부터 로그아웃
  signOut() async {
    await fAuth.signOut();
    setUser(null);
  }

  // 사용자에게 비밀번호 재설정 메일을 영어로 전송 시도
  sendPasswordResetEmailByEnglish() async {
    await fAuth.setLanguageCode("en");
    sendPasswordResetEmail();
  }

  // 사용자에게 비밀번호 재설정 메일을 한글로 전송 시도
  sendPasswordResetEmailByKorean() async {
    await fAuth.setLanguageCode("ko");
    sendPasswordResetEmail();
  }

  // 사용자에게 비밀번호 재설정 메일을 전송
  sendPasswordResetEmail() async {
    fAuth.sendPasswordResetEmail(email: getUser().email);
  }

  // Firebase로부터 회원 탈퇴
  withdrawalAccount() async {
    await getUser().delete();
    setUser(null);
  }

  // Firebase로부터 수신한 메시지 설정
  setLastFBMessage(String msg) {
    _lastFirebaseResponse = msg;
  }

  // Firebase로부터 수신한 메시지를 반환하고 삭제
  getLastFBMessage() {
    String returnValue = _lastFirebaseResponse;
    _lastFirebaseResponse = null;
    return returnValue;
  }

  showGuidance(String text, GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.black,
        duration: Duration(seconds: 10),
        content: Text(text),
        action: SnackBarAction(
          label: "Done",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ));
  }
}
