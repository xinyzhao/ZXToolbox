//
// AVAsset+ZXToolbox.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2020 Zhao Xin
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

NS_ASSUME_NONNULL_BEGIN

@interface AVAsset (ZXToolbox)

/// Return an image for video at or near the specified time.
/// @param time The requested time
- (UIImage * _Nullable)copyImageAtTime:(NSTimeInterval)time;

/// Return an image for video at or near the specified time.
/// @param time The requested time
/// @param tolerance The temporal tolerance time.
/// Pass kCMTimeZero to request sample accurate seeking (this may incur additional decoding delay).
- (UIImage * _Nullable)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance;

/// Creates a series of image objects for an asset at or near specified times.
/// @param time The requested time
/// @param tolerance The temporal tolerance time.
/// @param completion The completion block
- (void)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance completion:(void (^ _Nullable)(UIImage * _Nullable image, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
