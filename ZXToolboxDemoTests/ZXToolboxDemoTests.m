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

- (void)testBase64Encoding {
    NSString *str = @"testBase64Encoding";
    str = [str base64EncodedStringWithOptions:0];
    NSLogA(@"#base64EncodedString: %@", str);
    str = [str base64DecodedStringWithOptions:0];
    NSLogA(@"#base64DecodedString: %@", str);
}

- (void)testJSONObject {
    NSString *json = @"{\"name\":\"BeJson\",\"url\":\"http://www.bejson.com\",\"page\":88,\"isNonProfit\":true,\"address\":{\"street\":\"科技园路.\",\"city\":\"江苏苏州\",\"country\":\"中国\"},\"links\":[{\"name\":\"Google\",\"url\":\"http://www.google.com\"},{\"name\":\"Baidu\",\"url\":\"http://www.baidu.com\"},{\"name\":\"SoSo\",\"url\":\"http://www.SoSo.com\"}]}";
    id obj = [JSONObject JSONObjectWithString:json];
    id str = [JSONObject stringWithJSONObject:obj options:0];
    NSLogA(@"#JSONObject: %@", obj);
    NSLogA(@"#JSONString: %@", str);
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

- (void)testNSStringNumberValue {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 2; i <= 36; i++) {
        [arr addObject:[NSString stringWithFormat:@"[10]100 -> [%d]%@", i, [NSString stringWithValue:@"100" baseIn:10 baseOut:i alphabet:nil]]];
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

- (void)testUIDevice {
    NSLogA(@"#Model Type: %@", [UIDevice currentDevice].modelType);
    NSLogA(@"#Model Name: %@", [UIDevice currentDevice].modelName);
    NSLogA(@"#UIIDString: %@", [UIDevice currentDevice].UDIDString);
}

- (void)testUIScreen {
    CGSize size = CGSizeMake(100, 100);
    NSLogA(@"#adapt height: %.2f for base width %.2f = %.2f", size.height, size.width, [UIScreen adaptHeight:size.height forBaseWidth:size.width]);
    NSLogA(@"#adapt height: %.2f for base width %.2f = %.2f", size.width, size.height, [UIScreen adaptWidth:size.width forBaseHeight:size.height]);
}

- (void)testZXAudioDevice {
    ZXAudioDevice *ad = [ZXAudioDevice sharedDevice];
    NSLogA(@"#category: %@", ad.category);
    NSLogA(@"#currentInput: %@", ad.currentInput);
    NSLogA(@"#currentOutput: %@", ad.currentOutput);
    NSLogA(@"#isOverrideSpeaker: %d", ad.isOverrideSpeaker);
    NSLogA(@"#isProximityMonitoringEnabled: %d", ad.isProximityMonitoringEnabled);
    NSLogA(@"#proximityState: %d", ad.proximityState);
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

- (void)testZXHTTPClient {
    
}

- (void)testZXKeychain {
    NSString *key = @"ZXKeychainDemoTests";
    NSString *text = [NSUUID UUID].UUIDString;
    ZXKeychain *keychain = [[ZXKeychain alloc] init];
    // add
    if ([keychain setText:text forKey:key]) {
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
    text = [keychain textForKey:key];
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

- (void)testZXLocalAuthentication {
    
}

- (void)testZXLocationManager {
    
}

- (void)testZXPhotoLibrary {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testZXPhotoLibrary"];
    [[ZXPhotoLibrary defaultLibrary] requestAuthorization:^(AVAuthorizationStatus status) {
        if (status == AVAuthorizationStatusAuthorized) {
            UIImage *image = [UIImage imageWithColor:[UIColor randomColor] size:[UIScreen mainScreen].bounds.size];
            [[ZXPhotoLibrary defaultLibrary] saveImage:image toPhotoAlbum:^(NSError *error) {
                NSLogA(@"%@", error ? error.localizedDescription : @"success");
                [expectation fulfill];
            }];
        } else {
            NSLogA(@"没有权限");
            [expectation fulfill];
        }
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        NSLogA(@"Timeout");
    }];
}

@end
