import 'dart:convert';

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
  String orderId = '123',
      merchCode = '10000',
      appId = 'kp4c1706c8675a45fghjklrskyf',
      signKey = '123';
  double amount = 5000;

  GlobalKey _formKey = new GlobalKey<FormState>();

  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

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
            merchCode: merchCode,
            // "10000",
            appId: appId,
            //"kp4c1706c8675a45fghjklrskyf",
            signKey: signKey,
            //"123",
            orderId: orderId,
            //"294",
            amount: amount,
            title: "title",
            urlScheme: "",
            //Only Ios
            isProduction: false,
            notifyURL: 'http://test.payment.com/notify')
        .then((res) {
      Map response = json.decode(res);
      String result = response["Response"]["result"];
      if (result == "FAIL") {
        _messangerKey.currentState!.showSnackBar(
          SnackBar(content: Text(response["Response"]["msg"])),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
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
                TextFormField(
                  initialValue: orderId,
                  decoration: const InputDecoration(
                    label: Text('Order ID:'),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => orderId = value!,
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  initialValue: merchCode,
                  decoration: const InputDecoration(
                    label: Text(
                      'Merch Code:',
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => merchCode = value!,
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  initialValue: appId,
                  decoration: const InputDecoration(
                    label: Text(
                      'App ID:',
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => appId = value!,
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  initialValue: signKey,
                  decoration: const InputDecoration(
                    label: Text('Sign Key'),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  validator: (String? value) => value == null ? '' : null,
                  onSaved: (String? value) => signKey = value!,
                ),
                TextFormField(
                  initialValue: '10000',
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    label: Text('Amount:'),
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
