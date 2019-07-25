//
// ZXAuthorizationHelper.h
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

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Contacts/Contacts.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCellularData.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface ZXAuthorizationHelper : NSObject

/**
 相机权限
 Add NSCameraUsageDescription to info.plist

 @param handler Authorization handler
 */
+ (void)requestAuthorizationForCamera:(void(^)(AVAuthorizationStatus status))handler;

/**
 通讯录权限
 Add NSContactsUsageDescription to info.plist

 @param handler Authorization handler
 */
+ (void)requestAuthorizationForContacts:(void(^)(AVAuthorizationStatus status))handler;

/**
 位置权限
 Add NSLocationAlwaysUsageDescription/NSLocationWhenInUseUsageDescription to info.plist

 @param always Request always authorization
 @param handler Authorization handler
 */
+ (void)requestAuthorizationForLocation:(BOOL)always handler:(void(^)(CLAuthorizationStatus status))handler;

/**
 麦克风权限
 Add NSMicrophoneUsageDescription to info.plist

 @param handler Authorization handler
 */
+ (void)requestAuthorizationForMicrophone:(void(^)(AVAuthorizationStatus status))handler;

/**
 相册权限
 Add NSPhotoLibraryAddUsageDescription/NSPhotoLibraryUsageDescription to info.plist

 @param handler Authorization handler
 */
+ (void)requestAuthorizationForPhotoLibrary:(void(^)(AVAuthorizationStatus status))handler;

@end
