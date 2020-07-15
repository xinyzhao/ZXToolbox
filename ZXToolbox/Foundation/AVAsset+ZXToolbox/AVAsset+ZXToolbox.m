//
// AVAsset+ZXToolbox.m
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

#import "AVAsset+ZXToolbox.h"

@implementation AVAsset (ZXToolbox)

- (UIImage *)copyImageAtTime:(NSTimeInterval)time {
    return [self copyImageAtTime:time tolerance:kCMTimePositiveInfinity];
}

- (UIImage *)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance {
    UIImage *image = nil;
    //
    CMTime atTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    CMTime actualTime = kCMTimeZero;
    NSError *error = nil;
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = tolerance;
    generator.requestedTimeToleranceAfter = tolerance;
    CGImageRef imageRef = [generator copyCGImageAtTime:atTime actualTime:&actualTime error:&error];
    if (imageRef) {
        image = [[UIImage alloc] initWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    if (image) {
        NSLog(@"copyImageAtTime:%.3f torlerance:%.3f actualTime:%.3f", time, CMTimeGetSeconds(tolerance), CMTimeGetSeconds(actualTime));
    }
    if (error) {
        NSLog(@"copyImageAtTime:%.3f torlerance:%.3f error:%@", time, CMTimeGetSeconds(tolerance), error);
    }
    //
    return image;
}

- (void)copyImageAtTime:(NSTimeInterval)time tolerance:(CMTime)tolerance completion:(void (^ _Nullable)(UIImage * _Nullable image, NSError * _Nullable error))completion {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = tolerance;
    generator.requestedTimeToleranceAfter = tolerance;
    NSValue *value = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
    [generator generateCGImagesAsynchronouslyForTimes:@[value] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable imageRef, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage *image = nil;
        if (imageRef) {
            image = [[UIImage alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        if (image) {
            NSLog(@"copyImageAtTime:%.3f torlerance:%.3f actualTime:%.3f", time, CMTimeGetSeconds(tolerance), CMTimeGetSeconds(actualTime));
        }
        if (error) {
            NSLog(@"copyImageAtTime:%.3f torlerance:%.3f error:%@", time, CMTimeGetSeconds(tolerance), error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(image, error);
            }
        });
    }];
}

@end
