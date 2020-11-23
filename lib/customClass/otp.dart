import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'server_host.dart';

class FlutterOtp {
  int _otp, _minOtpValue, _maxOtpValue; //Generated OTP

  /// This function is used to generate a Random OTP in the range [1000, 9999]
  /// which can be used to send and verify. The [Random.nexInt] function is been
  /// used to do the same.
  ///
  /// UPDATE: OTP can be generated in the range desired by passing min and max
  /// params to sendOTP() function. Otherwise the Range [1000, 9999] is taken as
  /// default.

  void generateOtp([int min = 1000, int max = 9999]) {
    //Generates four digit OTP by default
    _minOtpValue = min;
    _maxOtpValue = max;
    _otp = _minOtpValue + Random().nextInt(_maxOtpValue - _minOtpValue);
  }

  /// This function should be called with [phoneNumber] as a Parameter and
  /// [messageText] as a optional parameter. If [messageText] is not passed it is
  /// taken as 'You OTP is : <Generated OTP>'.
  /// You can also pass [countryCode] (optional) as a parameter to sendtOtp function
  /// Otherwise +91 is taken as default country code (INDIA)

  Future<void> sendOtp(String phoneNumber,
      [String messageText,
      int min = 1000,
      int max = 9999,
      String countryCode = '+1']) async {
    //function parameter 'message' is optional.
    generateOtp(min, max);
    //SmsSender sender = new SmsSender();
    String address = (countryCode ?? '+1') +
        phoneNumber; // +1 for USA. Change it according to use.

    /// Use country code as per your requirement.
    /// +1 : USA / Canada
    /// +91: India
    /// +44: UK
    /// For other countries, please refer https://countrycode.org/

    // sender.sendSms(new SmsMessage(
    //     address, messageText ?? '[쓰레기를 담다-쓰담] 인증번호는 [$_otp]입니다.'));
    Logger().d(phoneNumber);
    final response = await http.post(message_send_server,
        body: json.encode(<String, String>{
          // "key": "qxmur964ny9mxlv685pgzbenk5qdlasd",
          // "user_id": "ssdam0501",
          // "sender": "01062143444",
          "receiver": phoneNumber,
          // "msg": '[쓰레기를 담다-쓰담] 인증번호는 [$_otp]입니다.'
          "otp": _otp.toString()
        }));
    //Logger().d(jsonDecode(response.body));
    Logger().d('send otp');
  }

  /// This function is used to validate the OTP entered by the user, by comparing
  /// it with the generated value [_otp]. If validates to be true then bool value
  /// true is returned. Else, false is returned.

  bool resultChecker(int enteredOtp) {
    //To validate OTP
    Logger().d(_otp);
    return enteredOtp == _otp;
  }
}
