//
// ZXPlayer.h
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
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, ZXPlaybackStatus) {
    ZXPlaybackStatusBuffering,
    ZXPlaybackStatusPlaying,
    ZXPlaybackStatusSeeking,
    ZXPlaybackStatusPaused,
    ZXPlaybackStatusEnded,
};

@interface ZXPlayer : NSObject

@property (nonatomic, readonly) BOOL isReadToPlay;
@property (nonatomic, readonly) BOOL isPlaying;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, copy) void (^playerStatus)(AVPlayerStatus status, NSError *error);
@property (nonatomic, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, copy) void (^playbackStatus)(ZXPlaybackStatus status);
@property (nonatomic, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);
@property (nonatomic, assign) NSTimeInterval playbackTimeInterval;

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGFloat seekingFactor; // 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat brightnessFactor; // 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat volumeFactor; // 0 - 1, 0 mean is disabled, default is 0.5

@property (nonatomic, readonly) UIImage *previewImage;
@property (nonatomic, readonly) NSURL *URL;

@property (nonatomic, assign) float volume NS_AVAILABLE(10_7, 7_0);
@property (nonatomic, getter=isMuted) BOOL muted NS_AVAILABLE(10_7, 7_0);

+ (instancetype)playerWithURL:(NSURL *)URL;

- (instancetype)initWithURL:(NSURL *)URL;

- (void)attachToView:(UIView *)view;
- (void)detach;

- (void)play;
- (void)pause;
- (void)stop;

- (void)seekToTime:(NSTimeInterval)time pauseAndPlay:(BOOL)pauseAndPlay;

@end
