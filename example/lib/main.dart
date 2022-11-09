import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_kpay_kit/flutter_kpay_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String orderId = '2',
      merchCode = '100187778',
      appId = 'kp1234567890987654321abcdefghijk',
      signKey = '123456';
  double amount = 10000;

  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    FlutterKpayKit.onPayStatus().listen((data) {
      print('onPayStatus $data');
    });
  }

  void success(dynamic data) {
    print(data);
  }

  void error(dynamic data) {
    print(data);
  }

  void startPay() {
    FlutterKpayKit.startPay(
            merchCode: this.merchCode,
            // "10000",
            appId: this.appId,
            //"kp4c1706c8675a45fghjklrskyf",
            signKey: this.signKey,
            //"123",
            orderId: this.orderId,
            //"294",
            amount: this.amount,
            title: "title",
            urlScheme: "",
            //Only Ios
            isProduction: false,
            notifyURL: 'http://test.payment.com/notify')
        .then((res) {
      print('startPay' + res.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Form(
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            child: ListView(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Order ID:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7826ea),
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: '2',
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => orderId = value!,
                ),
                const SizedBox(height: 15.0),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'merchCode:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7826ea),
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: '100187778',
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => merchCode = value!,
                ),
                const SizedBox(height: 15.0),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'appId:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7826ea),
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: 'kp1234567890987654321abcdefghijk',
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => appId = value!,
                ),
                const SizedBox(height: 15.0),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'signKey:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7826ea),
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: '123456',
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => signKey = value!,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Amount:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7826ea),
                    ),
                  ),
                ),
                TextFormField(
                  initialValue: '10000',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),

                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => amount = double.parse(value!),
                ),
                const SizedBox(height: 15.0),
                ElevatedButton(
                    child: const Text('Pay'),
                    onPressed: () {
                      startPay();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
