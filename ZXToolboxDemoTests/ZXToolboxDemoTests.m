//
//  ZXToolboxDemoTests.m
//  ZXToolboxDemoTests
//
//  Created by xyz on 2020/1/9.
//  Copyright © 2020 xinyzhao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ZXToolbox/ZXToolbox.h>

@interface ZXToolboxDemoTests : XCTestCase

@end

@implementation ZXToolboxDemoTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testAVAudioSession {
    AVAudioSession *ad = [AVAudioSession sharedInstance];
    NSLogA(@"#category: %@", ad.category);
    NSLogA(@"#currentInput: %@", ad.currentInput);
    NSLogA(@"#currentOutput: %@", ad.currentOutput);
    NSLogA(@"#isOverrideSpeaker: %d", ad.isOverrideSpeaker);
}

- (void)testBase64Encoding {
    NSString *str = @"testBase64Encoding";
    str = [str base64EncodedStringWithOptions:0];
    NSLogA(@"#base64EncodedString: %@", str);
    str = [str base64DecodedStringWithOptions:0];
    NSLogA(@"#base64DecodedString: %@", str);
}

- (void)testJSONObject {
    id src = @{@"string":@"json", @"array":@[@1,@2,@3], @"object":@{@"a":@"a", @"b":@"b", @"c":@"c"}};
    id str = [JSONObject stringWithJSONObject:src];
    id pty = [JSONObject stringWithJSONObject:src options:NSJSONWritingPrettyPrinted];
    id obj = [JSONObject JSONObjectWithString:str];
    NSLogA(@"#JSONString: %@", str);
    NSLogA(@"#JSONPretty: %@", pty);
    NSLogA(@"#JSONObject: %@", obj);
}

- (void)testNSArray {
    NSArray *a0 = @[];
    NSArray *a1 = @[@1];
    NSArray *a2 = @[@1, @2];
    NSArray *a3 = [a2 mutableCopy];
    if (a0[3] == [a0 objectAtIndex:3]) {}
    if (a1[3] == [a1 objectAtIndex:3]) {}
    if (a2[3] == [a2 objectAtIndex:3]) {}
    if (a3[3] == [a3 objectAtIndex:3]) {}
}

- (void)testNSDate {
    NSDate *date = [NSDate date];
    NSLogA(@"#DateTime: %@", [date stringWithFormat:kZXToolboxDateFormatDateTime]);
    NSLogA(@"#Date: %@", [date stringWithFormat:kZXToolboxDateFormatDate]);
    NSLogA(@"#Time: %@", [date stringWithFormat:kZXToolboxDateFormatTime]);
}

- (void)testNSFileManager {
    NSLogA(@"#%@ [%llu bytes]", [NSFileManager cachesDirectory], [NSFileManager fileSizeAtPath:[NSFileManager cachesDirectory]]);
    NSLogA(@"#%@ [%llu bytes]", [NSFileManager documentDirectory], [NSFileManager fileSizeAtPath:[NSFileManager documentDirectory]]);
    NSLogA(@"#%@ [%llu bytes]", [NSFileManager temporaryDirectory], [NSFileManager fileSizeAtPath:[NSFileManager temporaryDirectory]]);
}

- (void)testNSNumberFormatter {
    NSNumber *num = @1234.56789;
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    NSString *str1 = [fmt stringFromNumber:num integerFormat:@",###" minimumDecimal:4 maximumDecimal:6 paddingZeros:NO];
    NSString *str2 = [fmt stringFromNumber:num integerFormat:@",###" minimumDecimal:6 maximumDecimal:9 paddingZeros:NO];
    NSString *str3 = [fmt stringFromNumber:num integerFormat:@",###" minimumDecimal:6 maximumDecimal:9 paddingZeros:YES];
    NSLogA(@"#%@ -> %@", num, str1);
    NSLogA(@"#%@ -> %@", num, str2);
    NSLogA(@"#%@ -> %@", num, str3);
}

- (void)testNSObject {
    [self testNSObjectMethod1];
    [self testNSObjectMethod2];
    [[self class] swizzleMethod:@selector(testNSObjectMethod1) with:@selector(testNSObjectMethod2)];
    [self testNSObjectMethod1];
    [self testNSObjectMethod2];
}

- (void)testNSObjectMethod1 {
    NSLogA(@">testNSObjectMethod1");
}

- (void)testNSObjectMethod2 {
    NSLogA(@">testNSObjectMethod2");
}

- (void)testNSStringNumberValue {
    NSString *str = [NSString stringWithNumber:@(arc4random())];
    NSLogA(@"str: %@", str);
    NSLogA(@"arr: %@", [str numberComponents]);
    //
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 2; i <= 36; i++) {
        [arr addObject:[NSString stringWithFormat:@"[Base10]100 -> [Base%d]%@", i, [NSString stringWithValue:@"100" baseIn:10 baseOut:i alphabet:nil]]];
    }
    NSLogA(@"%@", arr);
}

- (void)testNSStringPinyin {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSString *str = @"我是中国人";
    [arr addObject:[NSString stringWithFormat:@"str = %@", str]];
    [arr addObject:[NSString stringWithFormat:@"py0 = %@", [str stringByPinyinStyle:NSStringPinyinMandarinLatin]]];
    [arr addObject:[NSString stringWithFormat:@"py1 = %@", [str stringByPinyinStyle:NSStringPinyinStripDiacritics]]];
    [arr addObject:[NSString stringWithFormat:@"py2 = %@", [str stringByPinyinAcronym]]];
    [arr addObject:[NSString stringWithFormat:@"co0 = %@", [str containsChineseCharacters] ? @"YES" : @"NO"]];
    [arr addObject:[NSString stringWithFormat:@"co1 = %@", [str containsString:@"ZG" options:NSStringPinyinSearchNone] ? @"YES" : @"NO"]];
    [arr addObject:[NSString stringWithFormat:@"co2 = %@", [str containsString:@"ZG" options:NSStringPinyinSearchAcronym] ? @"YES" : @"NO"]];
    NSLogA(@"%@", arr);
}

- (void)testNSStringUnicode {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSString *str = @"\u6211\u662f\u4e2d\u56fd\u4eba";
    [arr addObject:[NSString stringWithFormat:@"str = %@", str]];
    NSLogA(@"%@", arr);
}

- (void)testNSStringURLEncoding {
    NSString *str = @" ~`!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?";
    NSLogA(@"#Char      : %@", str);
    NSLogA(@"#User      : %@", [str stringByURLEncoding:NSStringURLEncodingUser]);
    NSLogA(@"#Password  : %@", [str stringByURLEncoding:NSStringURLEncodingPassword]);
    NSLogA(@"#Host      : %@", [str stringByURLEncoding:NSStringURLEncodingHost]);
    NSLogA(@"#Path      : %@", [str stringByURLEncoding:NSStringURLEncodingPath]);
    NSLogA(@"#Query     : %@", [str stringByURLEncoding:NSStringURLEncodingQuery]);
    NSLogA(@"#Fragment  : %@", [str stringByURLEncoding:NSStringURLEncodingFragment]);
}

- (void)testUIApplication {
    UIApplication.sharedApplication.idleTimerEnabled = NO;
    [UIApplication.sharedApplication openSettingsURL];
    [UIApplication.sharedApplication exitWithCode:0 afterDelay:1];
}

- (void)testUIButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [button setTitle:@"button" forState:UIControlStateNormal];
    button.titleImageLayout = UIButtonTitleImageLayoutRight;
    button.titleImageSpacing = 10;
    NSLogA(@"#title: %@", NSStringFromUIEdgeInsets(button.titleEdgeInsets));
    NSLogA(@"#image: %@", NSStringFromUIEdgeInsets(button.imageEdgeInsets));
}

- (void)testUIColor {
    NSLogA(@"#[UIColor colorWithString:] %@", [UIColor colorWithString:@"#999999"]);
    NSLogA(@"#[UIColor colorWithString:alpha:] %@", [UIColor colorWithString:@"#999999" alpha:0.5]);
    NSLogA(@"#[UIColor colorWithInteger:] %@", [UIColor colorWithInteger:0x999999]);
    NSLogA(@"#[UIColor colorWithInteger:alpha:] %@", [UIColor colorWithInteger:0x999999 alpha:0.5]);
    NSLogA(@"#[UIColor randomColor] %@", [UIColor randomColor]);
    NSLogA(@"#[UIColor inverseColor] %@", [[UIColor blackColor] inverseColor]);
    NSLogA(@"#[UIColor stringValue] %@", [[UIColor redColor] stringValue]);
    NSLogA(@"#[UIColor stringValueWithPrefix:] %@", [[UIColor redColor] stringValueWithPrefix:@"#"]);
    NSLogA(@"#[UIColor integerValue] %lx", (long)[[UIColor redColor] integerValue]);
    NSLogA(@"#[UIColor integerValueWithAlpha:] %lx", (long)[[UIColor redColor] integerValueWithAlpha:YES]);
}

- (void)testUIControl {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.timeIntervalByUserInteractionEnabled = YES;
    [button setTimeInteval:1 forControlEvents:UIControlEventTouchUpInside];
    [button removeTimeIntevalForControlEvents:UIControlEventTouchUpInside];
}

- (void)testUIDevice {
    NSLogA(@"#CPU Bits: %d", [UIDevice currentDevice].cpuBits);
    NSLogA(@"#CPU Type: %d", [UIDevice currentDevice].cpuType);
    NSLogA(@"#Model Type: %@", [UIDevice currentDevice].modelType);
    NSLogA(@"#Model Name: %@", [UIDevice currentDevice].modelName);
    NSLogA(@"#UUIDString: %@", [UIDevice currentDevice].UDIDString);
    NSLogA(@"#FileSystemSize: %lld bytes", [UIDevice currentDevice].fileSystemSize);
    NSLogA(@"#FileSystemFreeSize: %lld bytes", [UIDevice currentDevice].fileSystemFreeSize);
    NSLogA(@"#FileSystemUsedSize: %lld bytes", [UIDevice currentDevice].fileSystemUsedSize);
    NSLogA(@"#isProximityMonitoringEnabled: %d", [UIDevice currentDevice].isProximityMonitoringEnabled);
    NSLogA(@"#proximityState: %d", [UIDevice currentDevice].proximityState);
}

- (void)testUIImage {
    UIImage *image = [UIImage imageWithColor:[UIColor blueColor] size:CGSizeMake(1000, 1000)];
    UIImage *blurImage = [image blurImage:10];
    UIImage *grayImage = [image grayscaleImage];
    UIImage *thumbImage = [image thumbnailImage:CGSizeMake(100, 100) aspect:NO];
    NSData *data = [image compressToData:1024 * 2];
    NSLogA(@"#[UIImage imageWithColor:size:]%@", image);
    NSLogA(@"#[UIImage blurImage:]%@", blurImage);
    NSLogA(@"#[UIImage grayscaleImage]%@", grayImage);
    NSLogA(@"#[UIImage thumbnailImage:aspect:]%@", thumbImage);
    NSLogA(@"#[UIImage compressToData:] -> %ld bytes", (long)data.length);
}

- (void)testUIScreen {
    CGSize size = CGSizeMake(100, 100);
    NSLogA(@"#adapt height: %.2f for base width %.2f = %.2f", size.height, size.width, [UIScreen adaptHeight:size.height forBaseWidth:size.width]);
    NSLogA(@"#adapt height: %.2f for base width %.2f = %.2f", size.width, size.height, [UIScreen adaptWidth:size.width forBaseHeight:size.height]);
}

- (void)testZXCommonCrypto {
    CCAlgorithm alg = kCCAlgorithmAES;
    CCMode mode = kCCModeCBC;
    CCPadding padding = ccPKCS7Padding;
    id iv = @"1234567890123456";
    id key = @"12345678901234561234567890123456";
    id value = @"1234567890123456";
    NSError *error = nil;
    NSData *data = nil;
    // encrypt
    data = [value encryptedDataUsingAlgorithm:alg mode:mode padding:padding key:key iv:iv error:&error];
    if (error) {
        NSLogA(@"#error: %@", error);
    } else {
        value = [data base64EncodedStringWithOptions:0];
        NSLogA(@"#encoded: %@", value);
    }
    // decrypt
    data = [data decryptedDataUsingAlgorithm:alg mode:mode padding:padding key:key iv:iv error:&error];
    if (error) {
        NSLogA(@"#error: %@", error);
    } else {
        value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLogA(@"#decoded: %@", value);
    }
}

- (void)testZXCoordinate2D {
    ZXCoordinate2D world = ZXCoordinate2DMake(40.01845989630743, 116.461795056622);
    NSLogA(@"#WGS-84: %f, %f", world.latitude, world.longitude);
    ZXCoordinate2D china = ZXCoordinate2DWorldToChina(world);
    NSLogA(@"#GCJ-02: %f, %f", china.latitude, china.longitude);
    ZXCoordinate2D baidu = ZXCoordinate2DChinaToBaidu(china);
    NSLogA(@"#BD-09: %f, %f", baidu.latitude, baidu.longitude);
    china = ZXCoordinate2DBaiduToChina(baidu);
    NSLogA(@"#GCJ-02: %f, %f", china.latitude, china.longitude);
    world = ZXCoordinate2DChinaToWorld(china);
    NSLogA(@"#WGS-84: %f, %f", world.latitude, world.longitude);
    NSLogA(@"#W-C: %fm", ZXCoordinate2DDistanceMeters(world, china));
    NSLogA(@"#C-B: %fm", ZXCoordinate2DDistanceMeters(china, baidu));
    NSLogA(@"#W-B: %fm", ZXCoordinate2DDistanceMeters(world, baidu));
}

- (void)testZXDownloader {
    XCTestExpectation *expectation = [self expectationWithDescription:@"ZXDownloader"];
    //
    NSURL *url = [NSURL URLWithString:@"https://vod.300hu.com/4c1f7a6atransbjngwcloud1oss/4bb3e4c1242645539656048641/v.f30.mp4"];
    ZXDownloadTask *task = [ZXDownloader.defaultDownloader downloadTaskWithURL:url];
    [task addObserver:self state:^(NSURLSessionTaskState state, NSString * _Nullable filePath, NSError * _Nullable error) {
        NSLogA(@"#state: %d filePath: %@ error: %@", (int)state, filePath, error);
        if (state != NSURLSessionTaskStateRunning) {
            [expectation fulfill];
        }
        if (filePath) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    } progress:^(int64_t receivedSize, int64_t expectedSize, float progress) {
        NSLogA(@"#receivedSize: %lld expectedSize: %lld progress: %.2f", receivedSize, expectedSize, progress);
    }];
    [task resume];
    //
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        [ZXDownloader.defaultDownloader cancelAllTasks];
    }];
}

- (void)testZXKeychain {
    NSString *key = @"ZXKeychainDemoTests";
    NSString *text = [NSUUID UUID].UUIDString;
    ZXKeychain *keychain = [[ZXKeychain alloc] init];
    // add
    if ([keychain setString:text forKey:key]) {
        NSLogA(@"#add success: %@", text);
    } else {
        NSLogA(@"#add error: %@", keychain.lastError);
    }
    // allkeys
    NSArray *keys = [keychain allKeys];
    if (keys) {
        NSLogA(@"#all keys: %@", keys);
    } else {
        NSLogA(@"#all keys error: %@", keychain.lastError);
    }
    // search
    text = [keychain stringForKey:key];
    if (text) {
        NSLogA(@"#search result: %@", text);
    } else {
        NSLogA(@"#search error: %@", keychain.lastError);
    }
    // delete
    if ([keychain removeItemForKey:key]) {
        NSLogA(@"#delete success!");
    } else {
        NSLogA(@"#delete error: %@", keychain.lastError);
    }
    // clear
    if ([keychain removeAllItems]) {
        NSLogA(@"#delete all success!");
    } else {
        NSLogA(@"#delete all error: %@", keychain.lastError);
    }
}

- (void)testZXKVObserver {
    ZXDownloader *obj = [ZXDownloader defaultDownloader];
    ZXKVObserver *obs = [[ZXKVObserver alloc] init];
    [obs addObserver:obj forKeyPath:@"downloadPath" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
        NSLogA(@"%@", [change objectForKey:NSKeyValueChangeNewKey]);
    }];
    obj.downloadPath = @"1";
    obj.downloadPath = @"2";
    obj.downloadPath = @"3";
    [obs removeObserver];
    obj.downloadPath = @"4";
    obj.downloadPath = @"5";
    obj.downloadPath = @"6";
}

- (void)testZXLocalAuthentication {
    NSLogA(@"#canEvaluatePolicy:%d", [ZXLocalAuthentication canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics]);
}

- (void)testZXLocationManager {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testZXLocationManager"];
    //
    ZXLocationManager *lm = [[ZXLocationManager alloc] init];
    __weak typeof(lm) weak = lm;
    lm.didUpdateLocation = ^(CLLocation * _Nonnull location, CLPlacemark * _Nullable placemark) {
        [weak stopUpdatingLocation];
        NSLogA(@"#location: %@", location);
        NSLogA(@"#province: %@", placemark.province);
        NSLogA(@"#city: %@", placemark.city);
        NSLogA(@"#district: %@", placemark.district);
        NSLogA(@"#street: %@", placemark.street);
        NSLogA(@"#streetNumber: %@", placemark.streetNumber);
        NSLogA(@"#address: %@", placemark.address);
        [expectation fulfill];
    };
    if (@available(iOS 9.0, *)) {
        [lm requestLocation];
    } else {
        [lm startUpdatingLocation];
    }
    //
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLogA(@"#%@", error);
        } else {
            NSLogA(@"#Done");
        }
    }];
}

- (void)testZXNetworkTrafficMonitor {
    ZXNetworkTrafficMonitor *tm = [[ZXNetworkTrafficMonitor alloc] init];
    ZXNetworkTrafficData *data = tm.currentTrafficData;
    NSLogA(@"#WiFiSent:     %lld bytes", data.WiFiSent);
    NSLogA(@"#WiFiReceived: %lld bytes", data.WiFiReceived);
    NSLogA(@"#WWANSent:     %lld bytes", data.WWANSent);
    NSLogA(@"#WWANReceived: %lld bytes", data.WWANReceived);
}

- (void)testZXPhotoLibrary {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testZXPhotoLibrary"];
    [ZXPhotoLibrary requestAuthorization:^(AVAuthorizationStatus status) {
        if (status == AVAuthorizationStatusAuthorized) {
            UIImage *image = [UIImage imageWithColor:[UIColor randomColor] size:[UIScreen mainScreen].bounds.size];
            [[ZXPhotoLibrary sharedPhotoLibrary] saveImage:image toSavedPhotoAlbum:^(NSError *error) {
                NSLogA(@"%@", error ? error.localizedDescription : @"#success");
                [expectation fulfill];
            }];
        } else {
            NSLogA(@"没有权限");
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLogA(@"#%@", error);
        } else {
            NSLogA(@"#Done");
        }
    }];
}

- (void)testZXQRCodeGenerator {
    UIImage *image = [ZXQRCodeGenerator imageWithText:@"ZXQRCodeGenerator"];
    NSLogA(@"#ZXQRCodeGenerator %@", image);
}

- (void)testZXQRCodeReader {
    UIImage *image = [ZXQRCodeGenerator imageWithText:@"ZXQRCodeReader"];
    id results = [ZXQRCodeReader decodeQRCodeImage:image];
    NSLogA(@"#ZXQRCodeReader %@", results);
}

- (void)testNaN {
    NSLog(@"0.0 / 0.0 =%f", 0.0/0.0);
    NSLog(@"1.0 / 0.0 =%f", 1.0/0.0);
    NSLog(@"0.0 / 1.0 =%f", 0.0/1.0);
    NSLog(@"log(0.0)  =%f", log(0.0));

    NSLog(@"isfinite:\t0.0 / 0.0 = %d", isfinite(0.0/0.0));
    NSLog(@"isfinite:\t1.0 / 0.0 = %d", isfinite(1.0/0.0));
    NSLog(@"isfinite:\t0.0 / 1.0 = %d", isfinite(0.0/1.0));
    NSLog(@"isfinite:\tlog(0.0)  = %d", isfinite(log(0.0)));
 
    NSLog(@"isnormal:\t0.0 / 0.0 = %d", isnormal(0.0/0.0));
    NSLog(@"isnormal:\t1.0 / 0.0 = %d", isnormal(1.0/0.0));
    NSLog(@"isnormal:\t0.0 / 1.0 = %d", isnormal(0.0/1.0));
    NSLog(@"isnormal:\tlog(0.0)  = %d", isnormal(log(0.0)));
 
    NSLog(@"isnan:\t\t0.0 / 0.0 = %d", isnan(0.0/0.0));
    NSLog(@"isnan:\t\t1.0 / 0.0 = %d", isnan(1.0/0.0));
    NSLog(@"isnan:\t\t0.0 / 1.0 = %d", isnan(0.0/1.0));
    NSLog(@"isnan:\t\tlog(0.0)  = %d", isnan(log(0.0))) ;

    NSLog(@"isinf:\t\t0.0 / 0.0 = %d", isinf(0.0/0.0));
    NSLog(@"isinf:\t\t1.0 / 0.0 = %d", isinf(1.0/0.0));
    NSLog(@"isinf:\t\t0.0 / 1.0 = %d", isinf(0.0/1.0));
    NSLog(@"isinf:\t\tlog(0.0)  = %d", isinf(log(0.0)));
}

@end
