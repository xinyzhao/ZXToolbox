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

/// The statuses that indicate whether a player can successfully play items.
typedef NS_ENUM(NSInteger, ZXPlaybackStatus) {
    ZXPlaybackStatusBuffering,
    ZXPlaybackStatusPlaying,
    ZXPlaybackStatusSeeking,
    ZXPlaybackStatusPaused,
    ZXPlaybackStatusEnded,
};

/// ZXPlayer
@interface ZXPlayer : NSObject

/// Returns a new player to play a single audiovisual resource referenced by a given URL.
/// @param URL A URL identifying the media resource to be played.
+ (instancetype)playerWithURL:(NSURL *)URL;

/// Returns a new player initialized to play the specified asset.
/// @param asset The AVAsset to be played.
+ (instancetype)playerWithAsset:(AVAsset *)asset;

/// Returns a new player initialized to play the specified player item.
/// @param playerItem The player item to play.
+ (instancetype)playerWithPlayerItem:(AVPlayerItem *)playerItem;

/// Creates a new player to play a single audiovisual resource referenced by a given URL.
/// @param URL A URL identifying the media resource to be played.
- (instancetype)initWithURL:(NSURL *)URL;

/// Creates a new player to play the specified player item.
/// @param asset The AVAsset to be played.
- (instancetype)initWithAsset:(AVAsset *)asset;

/// Creates a new player to play the specified asset.
/// @param playerItem The player item to play.
- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem;

/// A URL that identifies an audiovisual resource.
@property (nonatomic, strong, nullable) NSURL *URL;
/// The AVAsset to be played.
@property (nonatomic, strong, nullable) AVAsset *asset;
/// The player item to play.
@property (nonatomic, strong, nullable) AVPlayerItem *playerItem;

/// A status that indicates whether the player can be used for playback.
@property (nonatomic, nullable, copy) void (^playerStatus)(AVPlayerStatus status, NSError * _Nullable error);
/// A time ranges indicating media data that is readily available.
@property (nonatomic, nullable, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

/// A status that indicates whether playback is currently in progress.
@property (nonatomic, nullable, copy) void (^playbackStatus)(ZXPlaybackStatus status);
/// Requests the periodic invocation of a given block during playback to report changing time.
@property (nonatomic, nullable, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);
/// The time interval at which the block should be invoked during normal playback, according to progress of the player’s current time.
@property (nonatomic, assign) NSTimeInterval playbackTimeInterval;

/// Returns the current time of the player.
@property (nonatomic, readonly) NSTimeInterval currentTime;
/// The duration of the player.
@property (nonatomic, readonly) NSTimeInterval duration;

/// The player is ready to play.
@property (nonatomic, readonly) BOOL isReadToPlay;
/// A Boolean value that indicates whether playback has consumed all buffered media and that playback will stall or end.
@property (nonatomic, readonly) BOOL isBuffering;
/// The player is ready to play.
@property (nonatomic, readonly) BOOL isPlaying;
/// The player is ready to play.
@property (nonatomic, readonly) BOOL isSeeking;
/// The player is ready to play.
@property (nonatomic, readonly) BOOL isPaused;
/// The player is end at play.
@property (nonatomic, readonly) BOOL isEnded;

/// The audio playback volume for the player.
@property (nonatomic, assign) float volume NS_AVAILABLE(10_7, 7_0);
/// A Boolean value that indicates whether the audio output of the player is muted.
@property (nonatomic, getter=isMuted) BOOL muted NS_AVAILABLE(10_7, 7_0);

/// AVLayerVideoGravityResizeAspect is default.
@property (nonatomic, copy) AVLayerVideoGravity videoGravity;

/// Attach to view of preview
/// @param view The view
- (void)attachToView:(UIView *)view;

/// Preview image for video
@property (nonatomic, nullable, readonly) UIImage *previewImage;

/// Get video image for current time
@property (nonatomic, nullable, readonly) UIImage *currentImage;

/// Begins playback of the current item.
- (void)play;
/// Pauses playback of the current item.
- (void)pause;
/// Resume playback when paused.
- (void)resume;
/// Stop playback of the current item and release player.
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

/// A UIPanGestureRecognizer of player view.
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
/// Factor of seeking for UIPanGestureRecognizer, 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat seekingFactor;
/// Factor of brightness for UIPanGestureRecognizer, 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat brightnessFactor;
/// Factor of volume for UIPanGestureRecognizer, 0 - 1, 0 mean is disabled, default is 0.5
@property (nonatomic, assign) CGFloat volumeFactor;

@end

NS_ASSUME_NONNULL_END
