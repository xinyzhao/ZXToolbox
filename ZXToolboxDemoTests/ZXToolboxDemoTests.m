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

- (void)testKeychain {
    NSString *key = @"ZXKeychainDemoTests";
    NSString *text = [NSUUID UUID].UUIDString;
    ZXKeychain *keychain = [[ZXKeychain alloc] init];
    // add
    if ([keychain setText:text forKey:key]) {
        NSLog(@">>>add success: %@", text);
    } else {
        NSLog(@">>>add error: %@", keychain.lastError);
    }
    // allkeys
    NSArray *keys = [keychain allKeys];
    if (keys) {
        NSLog(@">>>all keys: %@", keys);
    } else {
        NSLog(@">>>all keys error: %@", keychain.lastError);
    }
    // search
    text = [keychain textForKey:key];
    if (text) {
        NSLog(@">>>search result: %@", text);
    } else {
        NSLog(@">>>search error: %@", keychain.lastError);
    }
    // delete
    if ([keychain removeItemForKey:key]) {
        NSLog(@">>>delete success!");
    } else {
        NSLog(@">>>delete error: %@", keychain.lastError);
    }
    // clear
    if ([keychain removeAllItems]) {
        NSLog(@">>>delete all success!");
    } else {
        NSLog(@">>>delete all error: %@", keychain.lastError);
    }
}

- (void)testUDID {
    NSLog(@">>>UDID: %@", [UIDevice currentDevice].UDIDString);
}

@end
