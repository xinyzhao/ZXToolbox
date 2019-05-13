//
// ZXAuthorizationHelper.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ZXAuthorizationHelper.h"

typedef void(^CLAuthorizationHandler)(CLAuthorizationStatus status);

@interface ZXAuthorizationHelper () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) CLAuthorizationHandler locationHandler;

+ (instancetype)defaultHelper;

@end

@implementation ZXAuthorizationHelper

+ (instancetype)defaultHelper {
    static ZXAuthorizationHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[ZXAuthorizationHelper alloc] init];
    });
    return helper;
}

+ (void)requestAuthorizationForCamera:(void(^)(AVAuthorizationStatus status))handler {
    if (@available(iOS 7.0, *)) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
                    });
                }
            }];
        } else if (handler) {
            handler(status);
        }
    }
}

+ (void)requestAuthorizationForContacts:(void(^)(AVAuthorizationStatus status))handler {
    if (@available(iOS 9.0, *)) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *__nullable error) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
                    });
                }
            }];
        } else if (handler) {
            handler((NSInteger)status);
        }
    } else {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            CFRelease(addressBook);
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
                });
            }
        });
    }
}

+ (void)requestAuthorizationForLocation:(BOOL)always handler:(void(^)(CLAuthorizationStatus status))handler {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            if (@available(iOS 8.0, *)) {
                ZXAuthorizationHelper *helper = [ZXAuthorizationHelper defaultHelper];
                if (helper.locationManager == nil) {
                    helper.locationManager = [[CLLocationManager alloc] init];
                }
                helper.locationManager.delegate = helper;
                helper.locationHandler = handler;
                //
                if (always) {
                    [helper.locationManager requestAlwaysAuthorization];
                } else {
                    [helper.locationManager requestWhenInUseAuthorization];
                }
            }
        } else if (handler) {
            handler(status);
        }
    }
}

+ (void)requestAuthorizationForMicrophone:(void(^)(AVAuthorizationStatus status))handler {
    if (@available(iOS 7.0, *)) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (status == AVAuthorizationStatusNotDetermined) {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
                    });
                }
            }];
//            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//                if (handler) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
//                    });
//                }
//            }];
        } else if (handler) {
            handler(status);
        }
    }
}

+ (void)requestAuthorizationForPhotoLibrary:(void(^)(AVAuthorizationStatus status))handler {
    if (@available(iOS 8.0, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (handler) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        handler((NSInteger)status);
                    });
                }
            }];
        } else if (handler) {
            handler((NSInteger)status);
        }
    } else {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (handler) {
            handler((NSInteger)status);
        }
    }
}

#pragma mark <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (self.locationHandler) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.locationHandler(status);
        });
    }
}

@end
