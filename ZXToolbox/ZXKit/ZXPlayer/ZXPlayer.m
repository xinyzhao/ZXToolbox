//
// ZXPlayer.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2018 Zhao Xin
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
#import "ZXKeyValueObserver.h"

@interface ZXPlayer ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, weak) UIView *attachView;
@property (nonatomic, weak) ZXBrightnessView *brightnessView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, assign) ZXPlaybackBuffer buffer;
@property (nonatomic, assign) ZXPlaybackStatus status;

@property (nonatomic, strong) ZXKeyValueObserver *playerItemStatusObserver;
@property (nonatomic, strong) ZXKeyValueObserver *playerItemLoadedTimeRangesObserver;
@property (nonatomic, strong) ZXKeyValueObserver *playerItemPlaybackBufferEmptyObserver;
@property (nonatomic, strong) ZXKeyValueObserver *playerItemPlaybackLikelyToKeepUpObserver;
@property (nonatomic, strong) ZXKeyValueObserver *playerItemPlaybackBufferFullObserver;
@property (nonatomic, weak) id playerItemDidPlayToEndTimeObserver;
@property (nonatomic, weak) id playerTimeObserver;
@property (nonatomic, strong) ZXKeyValueObserver *playerLayerObserver;

@property (nonatomic, strong) dispatch_queue_t playerQueue;

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
        _buffer = ZXPlaybackBufferEmpty;
        _status = ZXPlaybackStatusStop;
        //
        _playbackTimeInterval = 1.0;
        _brightnessFactor = 0.5;
        _seekingFactor = 0.5;
        _volumeFactor = 0.5;
        _volume = 1.0;
        _rate = 1.0;
        _muted = NO;
        _shouldAutoplay = NO;
        _videoGravity = AVLayerVideoGravityResizeAspect;
        //
        _playerItemStatusObserver = [[ZXKeyValueObserver alloc] init];
        _playerItemLoadedTimeRangesObserver = [[ZXKeyValueObserver alloc] init];
        _playerItemPlaybackBufferEmptyObserver = [[ZXKeyValueObserver alloc] init];
        _playerItemPlaybackLikelyToKeepUpObserver = [[ZXKeyValueObserver alloc] init];
        _playerItemPlaybackBufferFullObserver = [[ZXKeyValueObserver alloc] init];
        _playerLayerObserver = [[ZXKeyValueObserver alloc] init];
        //
        _playerQueue = dispatch_queue_create("ZXPlayer", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    [_brightnessView removeObserver];
    [self unload];
}

#pragma mark NSURL

- (NSURL *)URL {
    if ([self.asset isKindOfClass:AVURLAsset.class]) {
        AVURLAsset *asset = (AVURLAsset *)self.asset;
        return asset.URL;
    }
    return nil;
}

- (void)setURL:(NSURL *)URL {
    if (URL) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_playerQueue, ^{
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:URL options:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.asset = asset;
            });
        });
    } else {
        [self unload];
    }
}
#pragma mark AVAsset

- (AVAsset *)asset {
    return self.playerItem.asset;
}

- (void)setAsset:(AVAsset *)asset {
    if (asset) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(_playerQueue, ^{
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.playerItem = playerItem;
            });
        });
    } else {
        [self unload];
    }
}

#pragma mark AVPlayerItem

- (AVPlayerItem *)playerItem {
    return self.player.currentItem;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    [self.playerItem removeOutput:self.videoOutput];
    if (playerItem) {
        [playerItem addOutput:self.videoOutput];
        //
        __weak typeof(self) weakSelf = self;
        dispatch_async(_playerQueue, ^{
            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.player = player;
            });
        });
    } else {
        [self unload];
    }
}

#pragma mark AVPlayer

- (void)setPlayer:(AVPlayer *)player {
    [self unload];
    //
    _player = player;
    if (_player) {
        if (@available(iOS 10.0, *)) {
            _player.automaticallyWaitsToMinimizeStalling = YES;
        }
        _player.muted = self.muted;
        _player.volume = self.volume;
        //
        [self reload];
    }
}

#pragma mark Player Layer

- (void)attachToView:(UIView *)view {
    [self detachView];
    _attachView = view;
    //
    if (_attachView) {
        [_attachView addGestureRecognizer:self.panGestureRecognizer];
    }
    //
    [self attachPlayerLayer];
}

- (void)detachView {
    [self detachPlayerLayer];
    //
    if (_attachView) {
        [_attachView removeGestureRecognizer:self.panGestureRecognizer];
        _attachView = nil;
    }
}

- (void)attachPlayerLayer {
    if (_playerLayer == nil && _player) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = _videoGravity;
    }
    if (_attachView && _playerLayer) {
        _playerLayer.frame = _attachView.layer.bounds;
        [_attachView.layer insertSublayer:_playerLayer atIndex:0];
        [self addPlayerLayerObserver];
    }
}

- (void)detachPlayerLayer {
    if (_playerLayer) {
        [self removePlayerLayerObserver];
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
}

#pragma mark Observers

- (void)addPlayerItemObserver {
    [self removePlayerItemObserver];
    if (self.playerItem) {
        __weak typeof(self) weakSelf = self;
        [_playerItemStatusObserver observe:self.playerItem keyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            AVPlayerStatus old = [[change objectForKey:@"old"] integerValue];
            AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
            if (status != old) {
                if (status == AVPlayerStatusReadyToPlay) {
                    [weakSelf addPlayerTimeObserver];
                    //
                    if (weakSelf.shouldAutoplay || weakSelf.isPlaying) {
                        [weakSelf play];
                    }
                }
                if (weakSelf.playerStatus) {
                    weakSelf.playerStatus(status, weakSelf.playerItem.error);
                }
            }
            // https://ja.stackoverflow.com/questions/37142
            if (status == AVPlayerStatusFailed) {
                [weakSelf unload];
            }
        }];
        [_playerItemLoadedTimeRangesObserver observe:self.playerItem keyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            if (weakSelf.loadedTime) {
                weakSelf.loadedTime(weakSelf.preferredLoadedTime, weakSelf.duration);
            }
        }];
        [_playerItemPlaybackBufferEmptyObserver observe:self.playerItem keyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            if (weakSelf.playerItem.playbackBufferEmpty) {
                weakSelf.buffer = ZXPlaybackBufferEmpty;
            }
        }];
        [_playerItemPlaybackLikelyToKeepUpObserver observe:self.playerItem keyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            if (weakSelf.playerItem.playbackLikelyToKeepUp) {
                weakSelf.buffer = ZXPlaybackLikelyToKeepUp;
            }
        }];
        [_playerItemPlaybackBufferFullObserver observe:self.playerItem keyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            if (weakSelf.playerItem.playbackBufferFull) {
                weakSelf.buffer = ZXPlaybackBufferFull;
            }
        }];
        _playerItemDidPlayToEndTimeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object == weakSelf.playerItem) {
                weakSelf.status = ZXPlaybackStatusStop;
            }
        }];
    }
}

- (void)removePlayerItemObserver {
    [_playerItemStatusObserver invalidate];
    [_playerItemLoadedTimeRangesObserver invalidate];
    [_playerItemPlaybackBufferEmptyObserver invalidate];
    [_playerItemPlaybackLikelyToKeepUpObserver invalidate];
    [_playerItemPlaybackBufferFullObserver invalidate];
    if (_playerItemDidPlayToEndTimeObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_playerItemDidPlayToEndTimeObserver];
        _playerItemDidPlayToEndTimeObserver = nil;
    }
}

- (void)addPlayerTimeObserver {
    [self removePlayerTimeObserver];
    if (_player.status == AVPlayerStatusReadyToPlay && _playbackTimeInterval > 0.001) {
        // Invoke callback every _playbackTimeInterval second
        CMTime interval = CMTimeMakeWithSeconds(_playbackTimeInterval, NSEC_PER_SEC);
        // Queue on which to invoke the callback
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        // Add time observer
        __weak typeof(self) weakSelf = self;
        _playerTimeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
            if (weakSelf.isPlaying) {
                if (weakSelf.playbackTime) {
                    weakSelf.playbackTime(CMTimeGetSeconds(time), weakSelf.duration);
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
        [_playerLayerObserver observe:_attachView.layer keyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            CGRect bounds = [[change objectForKey:@"new"] CGRectValue];
            weakSelf.playerLayer.frame = bounds;
        }];
    }
}

- (void)removePlayerLayerObserver {
    [_playerLayerObserver invalidate];
}

#pragma mark Load & Unload

- (void)reload {
    [self addPlayerItemObserver];
    [self attachPlayerLayer];
}

- (void)unload {
    [self detachPlayerLayer];
    [self removePlayerTimeObserver];
    [self removePlayerItemObserver];
    _player = nil;
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
    if (self.playerItem) {
        CMTime time = self.playerItem.currentTime;
        if ([self.videoOutput hasNewPixelBufferForItemTime:time]) {
            CMTime actualTime = kCMTimeZero;
            CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:time itemTimeForDisplay:&actualTime];
            if (pixelBuffer) {
                NSLog(@"currentImage:%.2f actualTime:%.2f", CMTimeGetSeconds(time), CMTimeGetSeconds(actualTime));
                CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
                image = [UIImage imageWithCIImage:ciImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                CVBufferRelease(pixelBuffer);
            }
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

- (void)setPlaybackBuffer:(void (^)(ZXPlaybackBuffer))playbackBuffer {
    _playbackBuffer = [playbackBuffer copy];
    if (_playbackBuffer) {
        _playbackBuffer(_buffer);
    }
}

- (void)setBuffer:(ZXPlaybackBuffer)buffer {
    if (_buffer != buffer) {
        _buffer = buffer;
        //
        if (_playbackBuffer) {
            _playbackBuffer(_buffer);
        }
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
        if (_status == ZXPlaybackStatusStop && status == ZXPlaybackStatusPaused) {
            // The status can’t from Ended to Paused
            return;
        }
        //
        _status = status;
        if (_playbackStatus) {
            _playbackStatus(_status);
        }
    }
}

- (BOOL)isReadyToPlay {
    if (self.playerItem) {
        return self.playerItem.status == AVPlayerItemStatusReadyToPlay;
    }
    return false;
}

- (BOOL)isPlaying {
    return _status == ZXPlaybackStatusPlaying;
}

- (BOOL)isPaused {
    return _status == ZXPlaybackStatusPaused;
}

- (BOOL)isStop {
    return _status == ZXPlaybackStatusStop;
}

#pragma mark Playback Control

- (void)play {
    BOOL replay = self.isStop;
    if (self.isReadyToPlay) {
        if (replay) {
            __weak typeof(self) weakSelf = self;
            [self seekToTime:0 completion:^(BOOL finished) {
                if (finished) {
                    weakSelf.player.rate = weakSelf.rate;
                }
            }];
        } else {
            _player.rate = _rate;
        }
    }
    self.status = ZXPlaybackStatusPlaying;
}

- (void)pause {
    if (self.isPlaying) {
        [_player pause];
    }
    self.status = ZXPlaybackStatusPaused;
}

- (void)resume {
    if (self.isPaused) {
        [self play];
    }
    self.status = ZXPlaybackStatusPlaying;
}

- (void)stop {
    self.status = ZXPlaybackStatusStop;
    [self pause];
    [self unload];
}

#pragma mark Rate

- (void)setRate:(float)rate {
    _rate = rate;
    if (self.isPlaying) {
        _player.rate = rate;
    }
}

#pragma mark Time

- (NSTimeInterval)currentTime {
    CMTime ct = self.playerItem.currentTime;
    if (CMTIME_IS_NUMERIC(ct)) {
        return CMTimeGetSeconds(ct);
    }
    return 0.0;
}

- (NSTimeInterval)duration {
    CMTime duration = self.playerItem.duration;
    if (CMTIME_IS_NUMERIC(duration)) {
        return CMTimeGetSeconds(duration);
    }
    return 0.0;
}

- (NSTimeInterval)preferredLoadedTime {
    CMTime current = self.playerItem.currentTime;
    NSArray<NSValue *> *ranges = self.playerItem.loadedTimeRanges;
    for (NSValue *value in ranges) {
        CMTimeRange range = [value CMTimeRangeValue];
        int start = CMTimeCompare(current, range.start);
        int duration = CMTimeCompare(current, range.duration);
        if (start >= 0 && duration <= 0) {
            return CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
        }
    }
    NSValue *value = ranges.firstObject;
    if (value) {
        CMTimeRange range = [value CMTimeRangeValue];
        return CMTimeGetSeconds(range.start) + CMTimeGetSeconds(range.duration);
    }
    return 0.0;
}

- (void)setLoadedTime:(void (^)(NSTimeInterval, NSTimeInterval))loadedTime {
    _loadedTime = [loadedTime copy];
    if (_loadedTime && self.isReadyToPlay) {
        _loadedTime(self.preferredLoadedTime, self.duration);
    }
}

- (void)setPlaybackTime:(void (^)(NSTimeInterval, NSTimeInterval))playbackTime {
    _playbackTime = [playbackTime copy];
    if (_playbackTime && self.isReadyToPlay) {
        _playbackTime(self.currentTime, self.duration);
    }
}

- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    _playbackTimeInterval = playbackTimeInterval;
    [self addPlayerTimeObserver];
}

#pragma mark Seek

- (void)seekToTime:(NSTimeInterval)time completion:(void (^_Nullable)(BOOL finished))completion {
    if (self.isReadyToPlay) {
        NSTimeInterval duration = [self duration];
        if (time > duration) {
            time = duration;
        }
        CMTime toTime = CMTimeMakeWithSeconds(floor(time), NSEC_PER_SEC);
        //
        [self.playerItem seekToTime:toTime completionHandler:completion];
    }
}

- (void)seekToTime:(NSTimeInterval)time tolerance:(CMTime)tolerance completion:(void (^_Nullable)(BOOL finished))completion {
    if (self.isReadyToPlay) {
        NSTimeInterval duration = [self duration];
        if (time > duration) {
            time = duration;
        }
        CMTime toTime = CMTimeMakeWithSeconds(floor(time), NSEC_PER_SEC);
        //
        [self.playerItem seekToTime:toTime toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:completion];
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
                    [self seekToTime:time completion:nil];
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
