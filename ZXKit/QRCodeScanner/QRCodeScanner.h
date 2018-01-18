//
// QRCodeScanner.h
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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
#import <UIKit/UIKit.h>

/**
 QRCode Scanner Output handler block

 @param results Scanning output results
 */
typedef void(^QRCodeScannerOutput)(NSArray<NSString *> *results);

/**
 QRCodeScanner
 */
@interface QRCodeScanner : NSObject
/**
 torchMode Default AVCaptureTorchModeOff
 */
@property (nonatomic, assign) AVCaptureTorchMode torchMode;

/**
 initialzes with preview and capture rect

 @param preview The preview view
 @param frame Capture frame in preview view
 @return QRCodeScanner
 */
- (instancetype)initWithPreview:(UIView *)preview captureRect:(CGRect)frame;

/**
 Start scanning

 @param output Output handler
 */
- (void)startScanning:(QRCodeScannerOutput)output;

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
