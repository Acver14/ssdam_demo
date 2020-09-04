import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

// import 'package:kakao_flutter_sdk/auth.dart';
// import 'package:kakao_flutter_sdk/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

Logger logger = Logger();

class FirebaseProvider with ChangeNotifier {
  final FirebaseAuth fAuth = FirebaseAuth.instance; // Firebase 인증 플러그인의 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  AuthResult authResult;
  FirebaseUser _user; // Firebase에 로그인 된 사용자
  var _user_info = Map<String, dynamic>();
  String _lastFirebaseResponse = ""; // Firebase로부터 받은 최신 메시지(에러 처리용)
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  FirebaseProvider() {
    logger.d("init FirebaseProvider");
    _prepareUser();
    _firebaseMessaging.getToken().then((token) {
      print('device token : ${token}');
    });
  }

  FirebaseUser getUser() {
    return _user;
  }

  void setUser(FirebaseUser value) {
    _user = value;
    notifyListeners();
  }

  // 최근 Firebase에 로그인한 사용자의 정보 획득
  _prepareUser() {
    fAuth.currentUser().then((FirebaseUser currentUser) {
      setUser(currentUser);
    });
    setUserInfo();
  }

  // 이메일/비밀번호로 Firebase에 회원가입
  Future<bool> signUpWithEmail(
      String email, String password, String name) async {
    try {
      AuthResult result = await fAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        print(name);
        //이름 입력값 추가 (이후 카카오, 네이버에서도 같은 역할 필요할듯)
        await Firestore.instance
            .collection('userInfo')
            .document(result.user.email.toString())
            .setData({'name': name, 'email': email}, merge: true);
        //사용자 이름 업데이트
        UserUpdateInfo uui = UserUpdateInfo();
        uui.displayName = name;
        await result.user.updateProfile(uui);
        // 새로운 계정 생성이 성공하였으므로 기존 계정이 있을 경우 로그아웃 시킴
        // 인증 메일 발송
        result.user.sendEmailVerification();
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
      logger.e("hi ${fAuth.toString()}");
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

      var _token;
      await _firebaseMessaging.getToken().then((token) {
        _token = token;
      });
      await Firestore.instance
          .collection('fcmTokenInfo')
          .document(_user_info['email'])
          .setData({'token': _token}, merge: true);
      //await setUserInfo();
      return true;
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  //
  // Future<bool> signInWithKakaoAccount() async{
  //   final installed = await isKakaoTalkInstalled();
  //   print('kakao Install : ' + installed.toString());
  //   var code, token;
  //
  //   try{
  //     if(installed){
  //       try{
  //         code = await AuthCodeClient.instance.requestWithTalk();   // AuthCode
  //         try{
  //           token = await AuthApi.instance.issueAccessToken(code);
  //           await AccessTokenStore.instance.toStore(token);
  //           print(token);
  //         }catch(e){
  //           print("error on issuing access token: $e");
  //           return false;
  //         }
  //       }catch(e){
  //         print(e);
  //       }
  //     }else{
  //       code = await AuthCodeClient.instance.request();
  //       try{
  //         token = await AuthApi.instance.issueAccessToken(code);
  //         await AccessTokenStore.instance.toStore(token);
  //         print(token);
  //       }catch(e){
  //         print("error on issuing access token: $e");
  //         return false;
  //       }
  //     }
  //     return true;
  //   }catch(e){
  //     return false;
  //   }
  //   //fAuth.signInWithCustomToken(token: token);
  // }

  Future<void> setUserInfo() async {
    await Firestore.instance
        .collection('userInfo')
        .document(_user.email)
        .get()
        .then((value) {
      print(value);
      _user_info = value.data;
    });
  }

  Map<String, dynamic> getUserInfo() {
    setUserInfo();
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
}
