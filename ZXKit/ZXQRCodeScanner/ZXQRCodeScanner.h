//
// ZXQRCodeScanner.h
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

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

/**
 ZXQRCodeScanner
 */
@interface ZXQRCodeScanner : NSObject

/**
 Indicates whether the receiver has a torch.
 */
@property(nonatomic, readonly) BOOL hasTorch;

/**
 Indicates whether the receiver's torch is currently available for use.
 */
@property(nonatomic, readonly) BOOL isTorchAvailable;

@property(nonatomic, readonly, getter=isTorchActive) BOOL torchActive;

/**
 Sets the current mode of the receiver's torch to AVCaptureTorchModeOn at the specified level.
 The value from 0.0 (off) -> 1.0 (full), check AVCaptureMaxAvailableTorchLevel
 */
@property (nonatomic, assign) float torchLevel;

/**
 initialzes with preview and capture rect

 @param preview The preview view
 @param frame Capture frame in preview view
 @return ZXQRCodeScanner
 */
- (instancetype)initWithPreview:(UIView *)preview captureRect:(CGRect)frame;

/**
 Start scanning

 @param output Output handler
 */
- (void)startScanning:(void(^)(NSArray<NSString *> *outputs))output;

/**
 Start scanning
 
 @param brightness Brightness handler
 @param output output Output handler
 */
- (void)startScanning:(void(^)(float brightness))brightness output:(void(^)(NSArray<NSString *> *outputs))output;

/**
 Stop scanning
 */
- (void)stopScanning;

/**
 Whether or not scanning

 @return Is scanning is YES, otherwise is NO.
 */
- (BOOL)isScanning;

@end
