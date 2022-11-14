# Flutter Kpay Kit

KBZ Mobile Payment package for Flutter

## Getting Started



## Installation
```dart
dependencies:
  flutter_kpay_kit:latest version
```


## Usage
### Android


UAT version - tast with uat kbz pay app as the following link
- https://drive.google.com/drive/folders/1y8rwhg8tF35U_S5CKbROrR-FXI8B-0S7?usp=share_link
add uat kbzsdk.arr under yourproject/android/app/lib

Product version
- https://drive.google.com/drive/folders/1YFiXmBNv1zAM4kZb32A8ujrMlG08pxd4?usp=share_link
add prod kbzsdk.arr under yourproject/android/app/lib


android/app/src/main/manifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
....
	<activity android:name="com.kbzbank.payment.sdk.callback.CallbackResultActivity" android:theme="@android:style/Theme.NoDisplay" android:exported="true"
....
```
### IOS
App project configuration in the Info. Add kbzpay pist white list
ios/Runner/Info.plist
```plist
<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>kbzpay</string>
	</array>
```

### Payment callback
Payment callback, payment completion or payment cancellation, currently there are only two states. The callback parameter is returned as an OpenUrl, as shown below

1：Pay for success，
3：Payment failed, the remaining fields are reserved for later addition。

## Example
```dart
import 'package:flutter_kpay_kit/flutter_kpay_kit.dart';

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
  void initState() {
    super.initState();
    FlutterKpayKit.onPayStatus().listen((data) {
      print('onPayStatus $data');
    });
  }
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

