//
// ZXPlayer.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZXPlaybackStatus) {
    ZXPlaybackStatusBuffering,
    ZXPlaybackStatusPlaying,
    ZXPlaybackStatusSeeking,
    ZXPlaybackStatusPaused,
    ZXPlaybackStatusEnded,
};

@interface ZXPlayer : NSObject

@property (nonatomic, nullable, readonly) AVPlayerItem *playerItem;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, readonly) BOOL isReadToPlay;
@property (nonatomic, readonly) BOOL isBuffering;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isSeeking;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL isEnded;

@property (nonatomic, nullable, copy) void (^playerStatus)(AVPlayerStatus status, NSError * _Nullable error);
@property (nonatomic, nullable, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, nullable, copy) void (^playbackStatus)(ZXPlaybackStatus status);
@property (nonatomic, nullable, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);
@property (nonatomic, assign) NSTimeInterval playbackTimeInterval;

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGFloat seekingFactor; // 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat brightnessFactor; // 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat volumeFactor; // 0 - 1, 0 mean is disabled, default is 0.5

@property (nonatomic, assign) float volume NS_AVAILABLE(10_7, 7_0);
@property (nonatomic, getter=isMuted) BOOL muted NS_AVAILABLE(10_7, 7_0);

/// Rate of playback, default is 0 not to setting.
@property (nonatomic, assign) float rate;

/// AVLayerVideoGravityResizeAspect is default.
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

/// Creates a ZXPlayer instance by URL
/// @param URL The URL
+ (instancetype)playerWithURL:(NSURL *)URL;

/// Creates a ZXPlayer instance
/// @param asset An AVAsset instance
+ (instancetype)playerWithAsset:(AVAsset *)asset;

/// Creates a ZXPlayer instance
/// @param playerItem An AVPlayerItem instance
+ (instancetype)playerWithPlayerItem:(AVPlayerItem *)playerItem;

/// Initializes a ZXPlayer by URL
/// @param URL The URL
- (instancetype)initWithURL:(NSURL *)URL;

/// Initializes a ZXPlayer by AVAsset
/// @param asset An AVAsset instance
- (instancetype)initWithAsset:(AVAsset *)asset;

/// Initializes a ZXPlayer by AVPlayerItem
/// @param playerItem An AVPlayerItem instance
- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;

/// Attach to view of preview
/// @param view The view
- (void)attachToView:(UIView *)view;

- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

/// Moves the playback cursor and play when the seek operation has completed.
/// @param time The time to which to seek.
/// @param playAfter Play when seek completed
- (void)seekToTime:(NSTimeInterval)time playAfter:(BOOL)playAfter;

/// Sets the current playback time within a specified time bound and invokes the specified block when the seek operation completes or is interrupted.
/// @param time The time to which to seek.
/// @param tolerance The temporal tolerance time.
/// Pass kCMTimeZero to request sample accurate seeking (this may incur additional decoding delay).
/// @param playAfter Play when seek completed
- (void)seekToTime:(NSTimeInterval)time tolerance:(CMTime)tolerance playAfter:(BOOL)playAfter;

/// Preview image for video
@property (nonatomic, nullable, readonly) UIImage *previewImage;

/// Get video image for current time
@property (nonatomic, nullable, readonly) UIImage *currentImage;

@end

NS_ASSUME_NONNULL_END
