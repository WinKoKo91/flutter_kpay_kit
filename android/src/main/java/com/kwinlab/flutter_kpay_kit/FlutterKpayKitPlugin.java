package com.kwinlab.flutter_kpay_kit;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.kbzbank.payment.KBZPay;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Random;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterKpayKitPlugin */
public class FlutterKpayKitPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String CHANNEL = "flutter_kpay";
  private static EventChannel.EventSink sink;
  private static final String TAG = "kpay";
  private String mOrderInfo;
  private String mMerchantCode = "";
  private String mAppId = "";
  private String mSignKey = "";
  private String mSign = "";
  private String mSignType = "SHA256";
  private String mTitle = "";
  private String mAmount = "0";
  private String mPrepayId = "";
  private String mMerchantOrderId = "";
  private Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
    channel.setMethodCallHandler(this);
    final EventChannel eventchannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),
            "flutter_kpay/pay_status");
    eventchannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o, EventChannel.EventSink eventSink) {
        SetSink(eventSink);
      }

      @Override
      public void onCancel(Object o) {

      }
    });

  }

  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    // TODO: your plugin is now attached to an Activity
    this.activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("createPay")) {
      HashMap<String, Object> map = call.arguments();
      try {
        JSONObject params = new JSONObject(map);
        Log.v("createPay", params.toString());
        if (params.has("merch_code") && params.has("appid") && params.has("sign_key")) {
          mMerchantCode = params.getString("merch_code");
          mAppId = params.getString("appid");
          mSignKey = params.getString("sign_key");
          mAmount = params.getString("amount");
          mTitle = params.getString("title");
          mMerchantOrderId = params.getString("order_id");
          String createOrderString = createOrder();

          result.success(createOrderString);

        }
      } catch (JSONException e) {
        e.printStackTrace();
        return;
      }
    } else if (call.method.equals("startPay")) {
      Log.d(TAG, "call");
      HashMap<String, Object> map = call.arguments();
      try {
        JSONObject params = new JSONObject(map);
        Log.v("startPay", params.toString());
        if (params.has("prepay_id") && params.has("merch_code") && params.has("appid")
                && params.has("sign_key")) {
          String prepayId = null;
          String merch_code = null;
          String appid = null;
          String sign_key = null;
          prepayId = params.getString("prepay_id");
          merch_code = params.getString("merch_code");
          appid = params.getString("appid");
          sign_key = params.getString("sign_key");
          mPrepayId = prepayId;
          startPay();
          result.success("payStatus " + 0);
        } else {
          result.error("parameter error", "parameter error", null);
        }
      } catch (JSONException e) {
        e.printStackTrace();
        return;
      }
    } else {
      result.notImplemented();
    }

  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public static void SetSink(EventChannel.EventSink eventSink) {
    sink = eventSink;
    HashMap<String, Object> map = new HashMap();
    map.put("status", "10");
    map.put("orderId", "default123");
    sink.success(map);
  }

  public static void sendPayStatus(int status, String orderId) {
    HashMap<String, Object> map = new HashMap();
    map.put("status", status);
    map.put("orderId", orderId);
    sink.success(map);
  }

  private void startPay() {
    buildOrderInfo();
    Log.d(TAG, mOrderInfo);
    Log.d(TAG, mSign);
    KBZPay.startPay(this.activity, mOrderInfo, mSign, mSignType);
  }

  /**
   * Please create order in server side, this function just a demo.
   */
  private String createOrder() {
    Date d = new Date();
    SimpleDateFormat format = new SimpleDateFormat("yyyyMMdd", Locale.getDefault());
    String today = format.format(d) + Integer.parseInt("" + d.getTime() / 1000);
    // mMerchantOrderId = today;
    String json = "";
    try {
      // Order increase
      try {
        Long orderid = Long.parseLong(mMerchantOrderId);
        // orderid++;
        // mMerchantOrderId = "" + orderid;
      } catch (Exception ex) {
        Log.d(TAG, ex.toString());
      }
      String nonceStr = createRandomStr();
      String timestamp = createTimestamp();
      String method = "kbz.payment.precreate";
      String notifyUrl = "http://test.payment.com/notify";
      JSONObject jsonObject = new JSONObject();
      JSONObject jsonRequest = new JSONObject();
      jsonObject.put("Request", jsonRequest);
      jsonRequest.put("timestamp", timestamp);
      jsonRequest.put("method", method);
      jsonRequest.put("notify_url", notifyUrl);
      jsonRequest.put("nonce_str", nonceStr);
      jsonRequest.put("sign_type", "SHA256");
      jsonRequest.put("sign", createOrderSign(method, nonceStr, notifyUrl, timestamp).toUpperCase());
      jsonRequest.put("version", "1.0");
      JSONObject jsonContent = new JSONObject();
      jsonRequest.put("biz_content", jsonContent);
      jsonContent.put("merch_order_id", mMerchantOrderId);
      jsonContent.put("merch_code", mMerchantCode);
      jsonContent.put("appid", mAppId);
      jsonContent.put("trade_type", "APP");
      jsonContent.put("title", mTitle);
      jsonContent.put("total_amount", mAmount);
      jsonContent.put("trans_currency", "MMK");
      jsonContent.put("timeout_express", "100m");
      jsonContent.put("callback_info", "iphonex");
      json = jsonObject.toString();
      return json;
    } catch (JSONException jex) {
      // showNotice("json params error" + jex.toString());
      return "";
    }
  }

  /**
   * create order sign
   * please create order sign in server side, this function just a demo.
   *
   * @return
   */
  private String createOrderSign(String method, String nonceStr, String notifyUrl, String timestamp) {
    String str = "appid=" + mAppId +
            "&callback_info=" + "iphonex" +
            "&merch_code=" + mMerchantCode +
            "&merch_order_id=" + mMerchantOrderId +
            "&method=" + method +
            "&nonce_str=" + nonceStr +
            "&notify_url=" + notifyUrl +
            "&timeout_express=100m" +
            "&timestamp=" + timestamp +
            "&title=" + mTitle +
            "&total_amount=" + mAmount +
            "&trade_type=APP" +
            "&trans_currency=MMK" +
            "&version=1.0";
    String s = str + "&key=" + mSignKey;
    Log.d(TAG, "sign string = " + s);
    return SHA.getSHA256Str(s);
  }

  // /**
  // * order info please create in server side. this function just a demo.
  // */
  private void buildOrderInfo() {
    // prepayId由服务器下单得到
    String prepayId = mPrepayId;
    Log.d(TAG, prepayId);
    String nonceStr = createRandomStr();
    String timestamp = createTimestamp();
    mOrderInfo = "appid=" + mAppId +
            "&merch_code=" + mMerchantCode +
            "&nonce_str=" + nonceStr +
            "&prepay_id=" + prepayId +
            "&timestamp=" + timestamp;
    mSign = SHA.getSHA256Str(mOrderInfo + "&key=" + mSignKey);
  }

  private String createRandomStr() {
    Random random = new Random();
    return Long.toString(Math.abs(random.nextLong()));
  }

  private String createTimestamp() {
    java.util.Calendar cal = java.util.Calendar.getInstance();
    double time = cal.getTimeInMillis() / 1000;
    Double d = Double.valueOf(time);
    return Integer.toString(d.intValue());
  }

  // private void showNotice(String msg) {
  // Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
  // }
}
