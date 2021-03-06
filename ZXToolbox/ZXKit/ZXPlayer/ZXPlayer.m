//
// ZXPlayer.m
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

#import "ZXPlayer.h"
#import "AVAsset+ZXToolbox.h"
#import "ZXBrightnessView.h"
#import "ZXKVObserver.h"

@interface ZXPlayer ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, weak) UIView *attachView;
@property (nonatomic, weak) ZXBrightnessView *brightnessView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, assign) ZXPlaybackStatus status;
@property (nonatomic, assign) BOOL playing;

@property (nonatomic, strong) ZXKVObserver *playerItemStatusObserver;
@property (nonatomic, strong) ZXKVObserver *playerItemLoadedTimeRangesObserver;
@property (nonatomic, strong) ZXKVObserver *playerItemPlaybackBufferEmptyObserver;
@property (nonatomic, strong) ZXKVObserver *playerItemPlaybackBufferFullObserver;
@property (nonatomic, strong) ZXKVObserver *playerItemPlaybackLikelyToKeepUpObserver;
@property (nonatomic, weak) id playerItemDidPlayToEndTimeObserver;

@property (nonatomic, strong) ZXKVObserver *playerRateObserver;
@property (nonatomic, weak) id playerTimeObserver;
@property (nonatomic, strong) ZXKVObserver *playerLayerObserver;

@end

@implementation ZXPlayer

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[ZXPlayer alloc] initWithURL:URL];
}

+ (instancetype)playerWithAsset:(AVAsset *)asset {
    return [[ZXPlayer alloc] initWithAsset:asset];
}

+ (instancetype)playerWithPlayerItem:(AVPlayerItem *)playerItem {
    return [[ZXPlayer alloc] initWithPlayerItem:playerItem];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        self.URL = URL;
    }
    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [self init];
    if (self) {
        self.asset = asset;
    }
    return self;
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)playerItem {
    self = [self init];
    if (self) {
        self.playerItem = playerItem;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _playbackTimeInterval = 1.0;
        _brightnessFactor = 0.5;
        _seekingFactor = 0.5;
        _volumeFactor = 0.5;
        _volume = 1.0;
        _muted = NO;
        _videoGravity = AVLayerVideoGravityResizeAspect;
        //
        _playerItemStatusObserver = [[ZXKVObserver alloc] init];
        _playerItemLoadedTimeRangesObserver = [[ZXKVObserver alloc] init];
        _playerItemPlaybackBufferEmptyObserver = [[ZXKVObserver alloc] init];
        _playerItemPlaybackBufferFullObserver = [[ZXKVObserver alloc] init];
        _playerItemPlaybackLikelyToKeepUpObserver = [[ZXKVObserver alloc] init];
        _playerRateObserver = [[ZXKVObserver alloc] init];
        _playerLayerObserver = [[ZXKVObserver alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_brightnessView removeObserver];
    [self unload];
}

#pragma mark NSURL

- (void)setURL:(NSURL *)URL {
    _URL = [URL copy];
    if (_URL) {
        self.asset = [AVURLAsset URLAssetWithURL:_URL options:nil];
    }
}

#pragma mark AVAsset

- (AVAsset *)asset {
    return self.playerItem.asset;
}

- (void)setAsset:(AVAsset *)asset {
    if (asset) {
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
}

#pragma mark AVPlayerItem

- (AVPlayerItem *)playerItem {
    return self.player.currentItem;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    [self unload];
    //
    if (playerItem) {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        [self reload];
    }
}

#pragma mark Load & Unload

- (void)reload {
    if (self.playerItem) {
        [self.playerItem addOutput:self.videoOutput];
    }
    if (self.player) {
        if (@available(iOS 10.0, *)) {
            self.player.automaticallyWaitsToMinimizeStalling = NO;
        }
        self.player.muted = self.muted;
        self.player.volume = self.volume;
    }
    //
    [self addItemObserver];
    [self addPlayerRateObserver];
    [self attachLayer];
}

- (void)unload {
    [self detachLayer];
    [self removePlayerTimeObserver];
    [self removePlayerRateObserver];
    [self removeItemObserver];
    self.player = nil;
}

#pragma mark Observers

- (void)addItemObserver {
    [self removeItemObserver];
    if (self.playerItem) {
        __weak typeof(self) weakSelf = self;
        [_playerItemStatusObserver addObserver:self.playerItem forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            AVPlayerStatus old = [[change objectForKey:@"old"] integerValue];
            AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
            if (status != old) {
                if (status == AVPlayerStatusReadyToPlay) {
                    [weakSelf addPlayerTimeObserver];
                    //
                    if (weakSelf.playing) {
                        [weakSelf play];
                    }
                }
                if (weakSelf.playerStatus) {
                    weakSelf.playerStatus(status, weakSelf.playerItem.error);
                }
            }
        }];
        [_playerItemLoadedTimeRangesObserver addObserver:self.playerItem forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            CMTimeRange timeRange = [weakSelf.playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
            NSTimeInterval loaded = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval duration = [weakSelf duration];
            if (weakSelf.loadedTime) {
                weakSelf.loadedTime(loaded, duration);
            }
        }];
        [_playerItemPlaybackBufferEmptyObserver addObserver:self.playerItem forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            //NSLog(@"playbackBufferEmpty %@", change[NSKeyValueChangeNewKey]);
            if (weakSelf.playing) {
                if (weakSelf.playerItem.isPlaybackBufferEmpty) {
                    weakSelf.status = ZXPlaybackStatusBuffering;
                } else {
                    [weakSelf play];
                }
            }
        }];
        [_playerItemPlaybackBufferFullObserver addObserver:self.playerItem forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            //NSLog(@"playbackBufferFull %@", change[NSKeyValueChangeNewKey]);
        }];
        [_playerItemPlaybackLikelyToKeepUpObserver addObserver:self.playerItem forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            //NSLog(@"playbackLikelyToKeepUp %@", change[NSKeyValueChangeNewKey]);
        }];
        _playerItemDidPlayToEndTimeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object == weakSelf.playerItem) {
                weakSelf.status = ZXPlaybackStatusEnded;
            }
        }];
    }
}

- (void)removeItemObserver {
    [_playerItemStatusObserver removeObserver];
    [_playerItemLoadedTimeRangesObserver removeObserver];
    [_playerItemPlaybackBufferEmptyObserver removeObserver];
    [_playerItemPlaybackBufferFullObserver removeObserver];
    [_playerItemPlaybackLikelyToKeepUpObserver removeObserver];
    if (_playerItemDidPlayToEndTimeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_playerItemDidPlayToEndTimeObserver];
        _playerItemDidPlayToEndTimeObserver = nil;
    }
}

- (void)addPlayerRateObserver {
    [self removePlayerRateObserver];
    if (_player) {
        __weak typeof(self) weakSelf = self;
        [_playerRateObserver addObserver:_player forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            BOOL isPlaying = ABS([[change objectForKey:@"new"] floatValue]) > 0.0;
            if (isPlaying && !weakSelf.isEnded) {
                weakSelf.status = ZXPlaybackStatusPlaying;
            } else if (!weakSelf.isBuffering && !weakSelf.isSeeking && !weakSelf.isEnded) {
                weakSelf.status = ZXPlaybackStatusPaused;
            }
        }];
    }
}

- (void)removePlayerRateObserver {
    [_playerRateObserver removeObserver];
}

- (void)addPlayerTimeObserver {
    [self removePlayerTimeObserver];
    if (_player.status == AVPlayerStatusReadyToPlay && _playbackTimeInterval > 0.001) {
        // Invoke callback every _playbackTimeInterval second
        CMTime interval = CMTimeMakeWithSeconds(_playbackTimeInterval, NSEC_PER_SEC);
        // Queue on which to invoke the callback
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        // Add time observer
        NSTimeInterval duration = [self duration];
        __weak typeof(self) weakSelf = self;
        _playerTimeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
            if (weakSelf.status == ZXPlaybackStatusPlaying) {
                if (weakSelf.playbackTime) {
                    weakSelf.playbackTime(CMTimeGetSeconds(time), duration);
                }
            }
        }];
    }
}

- (void)removePlayerTimeObserver {
    if (_playerTimeObserver) {
        [_player removeTimeObserver:_playerTimeObserver];
        _playerTimeObserver = nil;
    }
}

- (void)addPlayerLayerObserver {
    [self removePlayerLayerObserver];
    if (_attachView.layer) {
        __weak typeof(self) weakSelf = self;
        [_playerLayerObserver addObserver:_attachView.layer forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL observeValue:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change) {
            CGRect bounds = [[change objectForKey:@"new"] CGRectValue];
            weakSelf.playerLayer.frame = bounds;
        }];
    }
}

- (void)removePlayerLayerObserver {
    [_playerLayerObserver removeObserver];
}

#pragma mark Player Layer

- (AVPlayerLayer *)playerLayer {
    if (_playerLayer == nil && _player) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = _videoGravity;
    }
    return _playerLayer;
}

- (void)attachToView:(UIView *)view {
    [self detachLayer];
    self.attachView = view;
    [self attachLayer];
}

- (void)attachLayer {
    if (_attachView) {
        if (self.playerLayer) {
            _playerLayer.frame = _attachView.layer.bounds;
            [_attachView.layer insertSublayer:_playerLayer atIndex:0];
            [self addPlayerLayerObserver];
        }
        [_attachView addGestureRecognizer:self.panGestureRecognizer];
    }
}

- (void)detachLayer {
    if (_attachView) {
        [self removePlayerLayerObserver];
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [_attachView removeGestureRecognizer:self.panGestureRecognizer];
        _attachView = nil;
    }
}

#pragma mark Video image

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = [videoGravity copy];
    if (_playerLayer) {
        _playerLayer.videoGravity = _videoGravity;
    }
}

- (AVPlayerItemVideoOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVPlayerItemVideoOutput alloc] init];
    }
    return _videoOutput;
}

- (UIImage *)previewImage {
    return [self.asset copyImageAtTime:0];
}

- (UIImage *)currentImage {
    UIImage *image = nil;
    //
    CMTime time = self.playerItem.currentTime;
    if ([_videoOutput hasNewPixelBufferForItemTime:time]) {
        CMTime actualTime = kCMTimeZero;
        CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:time itemTimeForDisplay:&actualTime];
        if (pixelBuffer) {
            NSLog(@"currentImage:%.2f actualTime:%.2f", CMTimeGetSeconds(time), CMTimeGetSeconds(actualTime));
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            image = [UIImage imageWithCIImage:ciImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CVBufferRelease(pixelBuffer);
        }
    }
    //
    return image;
}

#pragma mark Status

- (void)setPlayerStatus:(void (^)(AVPlayerStatus, NSError * _Nullable))playerStatus {
    _playerStatus = [playerStatus copy];
    if (_playerStatus) {
        _playerStatus(_player.status, _player.error);
    }
}

- (void)setPlaybackStatus:(void (^)(ZXPlaybackStatus))playbackStatus {
    _playbackStatus = [playbackStatus copy];
    if (_playbackStatus) {
        _playbackStatus(_status);
    }
}

- (void)setStatus:(ZXPlaybackStatus)status {
    if (_status != status) {
        _status = status;
        //
        if (_playbackStatus) {
            _playbackStatus(_status);
        }
    }
}

- (BOOL)isReadToPlay {
    if (self.playerItem) {
        return self.playerItem.status == AVPlayerItemStatusReadyToPlay;
    }
    return false;
}

- (BOOL)isPlaying {
    return _status == ZXPlaybackStatusPlaying;
}

- (BOOL)isBuffering {
    return _status == ZXPlaybackStatusBuffering;
}

- (BOOL)isSeeking {
    return _status == ZXPlaybackStatusSeeking;
}

- (BOOL)isPaused {
    return _status == ZXPlaybackStatusPaused;
}

- (BOOL)isEnded {
    return _status == ZXPlaybackStatusEnded;
}

#pragma mark Playback Control

- (void)play {
    _playing = YES;
    //
    if (self.isReadToPlay) {
        if (self.isEnded) {
            [self seekToTime:0 playAfter:YES];
        } else {
            [_player play];
        }
    }
}

- (void)pause {
    _playing = NO;
    //
    if (self.isReadToPlay) {
        [_player pause];
    }
}

- (void)resume {
    if (self.isPaused) {
        [self play];
    }
}

- (void)stop {
    [self pause];
    [self unload];
}

#pragma mark Time

- (NSTimeInterval)currentTime {
    NSTimeInterval time = 0.f;
    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        time = CMTimeGetSeconds(self.playerItem.currentTime);
        if (time < 0.f) {
            time = 0.f;
        }
    }
    return time;
}

- (NSTimeInterval)duration {
    NSTimeInterval duration = 0.f;
    if (self.isReadToPlay) {
        duration = CMTimeGetSeconds(self.playerItem.duration);
    } else if (self.asset) {
        duration = CMTimeGetSeconds(self.asset.duration);
    }
    // Strange occurred in some iOS version
    if (isnan(duration) || isinf(duration)) {
        duration = 0.f;
    }
    return duration;
}

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    _loadedTime = [loadedTime copy];
    if (_loadedTime) {
        CMTimeRange range = [self.playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval loaded = CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
        _loadedTime(loaded, self.duration);
    }
}

- (void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    _playbackTime = [playbackTime copy];
    if (_playbackTime) {
        NSTimeInterval time = CMTimeGetSeconds(_player.currentTime);
        _playbackTime(time, self.duration);
    }
}

- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    _playbackTimeInterval = playbackTimeInterval;
    [self addPlayerTimeObserver];
}

#pragma mark Seek

- (void)seekToTime:(NSTimeInterval)time playAfter:(BOOL)playAfter {
    if (self.isReadToPlay) {
        self.status = ZXPlaybackStatusSeeking;
        [_player pause];
        //
        NSTimeInterval duration = [self duration];
        if (time > duration) {
            time = duration;
        }
        CMTime toTime = CMTimeMakeWithSeconds(floor(time), NSEC_PER_SEC);
        //
        __weak typeof(self) weakSelf = self;
        [self.playerItem seekToTime:toTime completionHandler:^(BOOL finished) {
            if (weakSelf.playbackTime) {
                weakSelf.playbackTime(time, duration);
            }
            if (finished && playAfter) {
                [weakSelf play];
            }
        }];
    }
}

- (void)seekToTime:(NSTimeInterval)time tolerance:(CMTime)tolerance playAfter:(BOOL)playAfter {
    if (self.isReadToPlay) {
        self.status = ZXPlaybackStatusSeeking;
        [_player pause];
        //
        NSTimeInterval duration = [self duration];
        if (time > duration) {
            time = duration;
        }
        CMTime toTime = CMTimeMakeWithSeconds(floor(time), NSEC_PER_SEC);
        //
        __weak typeof(self) weakSelf = self;
        [self.playerItem seekToTime:toTime toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:^(BOOL finished) {
            if (weakSelf.playbackTime) {
                weakSelf.playbackTime(time, duration);
            }
            if (finished && playAfter) {
                [weakSelf play];
            }
        }];
    }
}

#pragma mark Volume

- (UISlider *)volumeSlider {
    if (_volumeSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeSlider;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    if (_player) {
        _player.volume = volume;
    }
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (_player) {
        _player.muted = muted;
    }
}

#pragma mark UIPanGestureRecognizer

- (void)setBrightnessFactor:(CGFloat)brightnessFactor {
    if (brightnessFactor < 0.00) {
        _brightnessFactor = 0.00;
    } else if (brightnessFactor > 1.00) {
        _brightnessFactor = 1.00;
    } else {
        _brightnessFactor = brightnessFactor;
    }
}

- (void)setSeekingFactor:(CGFloat)seekingFactor {
    if (seekingFactor < 0.00) {
        _seekingFactor = 0.00;
    } else if (seekingFactor > 1.00) {
        _seekingFactor = 1.00;
    } else {
        _seekingFactor = seekingFactor;
    }
}

- (void)setVolumeFactor:(CGFloat)volumeFactor {
    if (volumeFactor < 0.00) {
        _volumeFactor = 0.00;
    } else if (volumeFactor > 1.00) {
        _volumeFactor = 1.00;
    } else {
        _volumeFactor = volumeFactor;
    }
}

- (ZXBrightnessView *)brightnessView {
    if (_brightnessView == nil) {
        _brightnessView = [ZXBrightnessView brightnessView];
        [_brightnessView addObserver];
    }
    return _brightnessView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecognizer:)];
    }
    return _panGestureRecognizer;
}

- (void)onPanGestureRecognizer:(id)sender {
    UIPanGestureRecognizer *pan = sender;
    // 上下滑动：左侧亮度/右侧音量
    static BOOL isBrightness = NO;
    // 左右滑动：时间定位
    static BOOL isSeeking = NO;
    // 亮度/音量/时间
    static CGFloat brightness = 0;
    static float volume = 0;
    static NSTimeInterval seekTime = 0;
    //
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint velocity = [pan velocityInView:pan.view];
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            isSeeking = x > y;
            if (isSeeking) {
                seekTime = self.currentTime;
            } else {
                CGPoint point = [pan locationInView:pan.view];
                isBrightness = point.x < pan.view.frame.size.width / 2;
                if (isBrightness) {
                    brightness = [UIScreen mainScreen].brightness;
                } else {
                    volume = self.volumeSlider.value;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [pan translationInView:pan.view];
            if (isSeeking) {
                if (_seekingFactor > 0.00) {
                    NSTimeInterval duration = [self duration];
                    NSTimeInterval time = seekTime + (point.x / (pan.view.frame.size.width * _seekingFactor)) * duration;
                    if (time < 0) {
                        time = 0;
                    }
                    if (time > duration) {
                        time = duration;
                    }
                    [self seekToTime:time playAfter:pan.state == UIGestureRecognizerStateEnded];
                }
            } else if (isBrightness) {
                if (_brightnessFactor > 0.00) {
                    CGFloat y = point.y / (pan.view.frame.size.height * _brightnessFactor);
                    [UIScreen mainScreen].brightness = brightness - y;
                }
            } else {
                if (_volumeFactor > 0.00) {
                    CGFloat y = point.y / (pan.view.frame.size.height * _volumeFactor);
                    _volumeSlider.value = volume - y;
                }
            }
            break;
        }
        default:
            break;
    }
}

@end
