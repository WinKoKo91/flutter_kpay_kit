#import "FlutterKbzPayPlugin.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import <KBZPayAPPPay/PaymentViewController.h>

@interface FlutterKbzPayPlugin () <FlutterStreamHandler>
@end

@implementation FlutterKbzPayPlugin {
    FlutterEventSink _eventSink;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"flutter_kpay_kit"
                  binaryMessenger:[registrar messenger]];
    FlutterKbzPayPlugin* instance = [[FlutterKbzPayPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    FlutterEventChannel* chargingChannel =
            [FlutterEventChannel eventChannelWithName:@"flutter_kpay_kit/pay_status"
                                      binaryMessenger:[registrar messenger]];
    [chargingChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"startPay" isEqualToString:call.method]) {
        NSString *appId = call.arguments[@"appid"];
        NSString *prepayId = call.arguments[@"prepay_id"];
        NSString *merchCode = call.arguments[@"merch_code"];
        NSString *signKey = call.arguments[@"sign_key"];
        NSString *urlScheme = call.arguments[@"url_scheme"];
        NSString *data = [self startPay:appId :merchCode :prepayId :signKey :urlScheme];
        result((data));
    } else if([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSString *)startPay:(NSString*)appId :(NSString*)merchantCode :(NSString*)prepayId :(NSString*)signKey :(NSString*)urlScheme{

    NSString *nonceStrTF = [self getRandomStr];
    NSString *timeSp = [self getCurrentTimes];
    NSString *orderString = [NSString stringWithFormat:@"appid=%@&merch_code=%@&nonce_str=%@&prepay_id=%@&timestamp=%@",appId,merchantCode,nonceStrTF,prepayId,timeSp];
    NSLog(@"orderString data %@",orderString);
    NSString *signStr = [NSString stringWithFormat:@"%@&key=%@",orderString,signKey];
    NSLog(@"signStr data %@",signStr);
    NSString *sign = [self SHA256WithSignString:signStr];
    NSLog(@"sign data %@",sign);
    PaymentViewController *vc = [PaymentViewController new];
    [vc startPayWithOrderInfo:orderString signType:@"SHA256" sign:sign appScheme:urlScheme];
    return orderString;
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPayStatus:) name:@"APPCallBack" object:nil];
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

- (void) sendPayStatus:(NSNotification *)noti {
    NSDictionary *infoDic = [noti object];
    NSString *extraResult = infoDic[@"EXTRA_RESULT"];
    if ([@"0" isEqualToString:extraResult]) {
        extraResult = @"1";
    }
    //0:success 3: cancel  目前只有两种状态返回
    _eventSink(extraResult);
}

-(NSString *)getRandomStr {
    char data[32];
    for (int x=0;x < 32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    NSString *randomStr = [[NSString alloc] initWithBytes:data length:6 encoding:NSUTF8StringEncoding];
    NSString *string = [NSString stringWithFormat:@"%@",randomStr];
    return string;
}

- (NSString*)SHA256WithSignString:(NSString*)signString {
    const char* str = [signString UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    ret = (NSMutableString *)[ret uppercaseString];
    return ret;
}

- (NSString *)getCurrentTimes {
    double currentTime =  [[NSDate date] timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%.0f",currentTime];
    return strTime;
}

@end