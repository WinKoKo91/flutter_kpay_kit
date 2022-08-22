import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class FlutterKpayKit {
  static const MethodChannel _channel = MethodChannel('flutter_kpay_kit');
  static const EventChannel _eventChannel =
      EventChannel('flutter_kpay_kit/pay_status');
  static Stream<dynamic>? _streamPayStatus;
  static String prepay_id = "";

  // String COMPLETED = 1;
  // String FAIL = 2;
  // String CANCEL = 3;
  static Stream<dynamic> onPayStatus() {
    _streamPayStatus = _eventChannel.receiveBroadcastStream();
    return _streamPayStatus!;
  }

  static Future<String> startPay(
      {required String merchCode,
      required String appId,
      required String signKey,
      String? urlScheme,
      required String orderId,
      required double amount,
      required String title,
      required bool isProduction}) async {
    final String orderString = await _channel.invokeMethod('createPay', {
      'merch_code': merchCode,
      'appid': appId,
      'sign_key': signKey,
      'url_scheme': urlScheme,
      'order_id': orderId,
      'amount': amount,
      'title': title,
    });
    Dio dio = Dio();
    var options = Options(
      headers: {"Content-Type": "application/json"},
    );
    String orderCreateApi = "";
    if (isProduction) {
      orderCreateApi = "https://api.kbzpay.com/payment/gateway/precreate";
    } else {
      orderCreateApi = "http://api.kbzpay.com/payment/gateway/uat/precreate";
    }
    print(orderString);
    Response response =
        await dio.post(orderCreateApi, options: options, data: orderString);
    print(response);


    prepay_id = response.data["Response"]["prepay_id"];

    print(prepay_id);
    final String data = await _channel.invokeMethod('startPay', {
      'prepay_id': prepay_id,
      'merch_code': merchCode,
      'appid': appId,
      'sign_key': signKey,
      'url_scheme': urlScheme,
    });

    return data;
  }
}
