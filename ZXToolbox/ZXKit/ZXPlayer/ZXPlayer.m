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
#import "ZXBrightnessView.h"

@interface ZXPlayer ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, weak) id periodicTimeObserver;
@property (nonatomic, weak) id playerItemDidPlayToEndTimeObserver;

@property (nonatomic, weak) UIView *attachView;
@property (nonatomic, weak) ZXBrightnessView *brightnessView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, assign) ZXPlaybackStatus status;
@property (nonatomic, assign) BOOL playing;

@end

@implementation ZXPlayer

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[ZXPlayer alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        self.URL = URL;
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
        _rate = 0.0;
        _videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return self;
}

- (void)dealloc {
    [_brightnessView removeObserver];
    [self unload];
}

#pragma mark Load & Unload

- (void)reload {
    [self unload];
    //
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.URL) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.URL options:nil];
            if (asset) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            }
        }
        if (self.playerItem) {
            [self.playerItem addOutput:self.videoOutput];
            //
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        }
        if (self.player) {
            if (@available(iOS 10.0, *)) {
                self.player.automaticallyWaitsToMinimizeStalling = NO;
            }
            self.player.muted = self.muted;
            self.player.volume = self.volume;
        }
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addItemObserver];
            [self addPlayerObserver];
            [self attachLayer];
        });
    });
}

- (void)unload {
    [self detachLayer];
    [self removeTimeObserver];
    [self removePlayerObserver];
    [self removeItemObserver];
    _playerItem = nil;
    _player = nil;
}

#pragma mark Attach & Detach

- (void)attachToView:(UIView *)view {
    [self detachLayer];
    _attachView = view;
    [self attachLayer];
}

- (void)attachLayer {
    if (_attachView) {
        if (self.playerLayer) {
            _playerLayer.frame = _attachView.layer.bounds;
            [_attachView.layer insertSublayer:_playerLayer atIndex:0];
            [self addLayerObserver];
        }
        [_attachView addGestureRecognizer:self.panGestureRecognizer];
    }
}

- (void)detachLayer {
    if (_attachView) {
        [self removeLayerObserver];
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
        [_attachView removeGestureRecognizer:self.panGestureRecognizer];
        _attachView = nil;
    }
}

#pragma mark Observer

- (void)addItemObserver {
    [self removeItemObserver];
    if (_playerItem) {
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        //
        __weak typeof(self) weakSelf = self;
        _playerItemDidPlayToEndTimeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (note.object == weakSelf.playerItem) {
                weakSelf.status = ZXPlaybackStatusEnded;
            }
        }];
    }
}

- (void)removeItemObserver {
    if (_playerItem) {
        @try {
            [_playerItem removeObserver:self forKeyPath:@"status"];
            [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        } @catch (NSException *ex) {
            NSLog(@"%@", ex.description);
        }
        //
        if (_playerItemDidPlayToEndTimeObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:_playerItemDidPlayToEndTimeObserver];
            _playerItemDidPlayToEndTimeObserver = nil;
        }
    }
}

- (void)addPlayerObserver {
    [self removePlayerObserver];
    if (_player) {
        [_player addObserver:self forKeyPath:@"rate" options:(NSKeyValueObservingOptionNew) context:nil];
    }
}

- (void)removePlayerObserver {
    if (_player) {
        @try {
            [_player removeObserver:self forKeyPath:@"rate"];
        } @catch (NSException *ex) {
            NSLog(@"%@", ex.description);
        }
    }
}

- (void)addTimeObserver {
    [self removeTimeObserver];
    if (_player.status == AVPlayerStatusReadyToPlay && _playbackTimeInterval > 0.001) {
        // Invoke callback every _playbackTimeInterval second
        CMTime interval = CMTimeMakeWithSeconds(_playbackTimeInterval, NSEC_PER_SEC);
        // Queue on which to invoke the callback
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        // Add time observer
        NSTimeInterval duration = [self duration];
        __weak typeof(self) weakSelf = self;
        _periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
            if (weakSelf.status == ZXPlaybackStatusPlaying) {
                if (weakSelf.playbackTime) {
                    weakSelf.playbackTime(CMTimeGetSeconds(time), duration);
                }
            }
        }];
    }
}

- (void)removeTimeObserver {
    if (_periodicTimeObserver) {
        [_player removeTimeObserver:_periodicTimeObserver];
        _periodicTimeObserver = nil;
    }
}

- (void)addLayerObserver {
    [self removeLayerObserver];
    if (_attachView.layer) {
        [_attachView.layer addObserver:self
                            forKeyPath:@"bounds"
                               options:NSKeyValueObservingOptionNew
                               context:NULL];
    }
}

- (void)removeLayerObserver {
    if (_attachView.layer) {
        @try {
            [_attachView.layer removeObserver:self forKeyPath:@"bounds"];
        } @catch (NSException *ex) {
            NSLog(@"%@", ex.description);
        }
    }
}

#pragma mark Getter

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

- (AVPlayerLayer *)playerLayer {
    if (_player && _playerLayer == nil) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.videoGravity = _videoGravity;
    }
    return _playerLayer;
}

- (AVPlayerItemVideoOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVPlayerItemVideoOutput alloc] init];
    }
    return _videoOutput;
}

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

- (BOOL)isReadToPlay {
    return _playerItem.status == AVPlayerItemStatusReadyToPlay;
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

#pragma mark Setter

- (void)setURL:(NSURL *)URL {
    _URL = [URL copy];
    [self reload];
}

- (void)setPlaybackStatus:(void (^)(ZXPlaybackStatus))playbackStatus {
    _playbackStatus = [playbackStatus copy];
    if (_playbackStatus) {
        _playbackStatus(_status);
    }
}

- (void)setPlaybackTimeInterval:(NSTimeInterval)playbackTimeInterval {
    _playbackTimeInterval = playbackTimeInterval;
    //
    [self addTimeObserver];
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

- (void)setRate:(float)rate {
    _rate = rate;
    [self playAtRate];
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = [videoGravity copy];
    if (_playerLayer) {
        _playerLayer.videoGravity = _videoGravity;
    }
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

#pragma mark Playing

- (void)play {
    _playing = YES;
    //
    if (self.isReadToPlay) {
        if (self.isEnded) {
            [self seekToTime:0 playAfter:YES];
        } else {
            [self playAtRate];
        }
        //
        if (_playerItem.isPlaybackBufferEmpty) {
            self.status = ZXPlaybackStatusBuffering;
        }
    }
}

- (void)playAtRate {
    [_player play];
    if (_rate > 0) {
        _player.rate = _rate;
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
    if (self.isReadToPlay && self.isPaused) {
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
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        time = CMTimeGetSeconds(_playerItem.currentTime);
        if (time < 0.f) {
            time = 0.f;
        }
    }
    return time;
}

- (NSTimeInterval)duration {
    NSTimeInterval duration = 0.f;
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        duration = CMTimeGetSeconds(_playerItem.duration);
    } else if (_playerItem.asset) {
        duration = CMTimeGetSeconds(_playerItem.asset.duration);
    } else if (_URL) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_URL options:nil];
        duration = CMTimeGetSeconds(asset.duration);
    }
    // Strange occurred in some iOS version
    if (isnan(duration) || isinf(duration)) {
        duration = 0.f;
    }
    return duration;
}

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
        [_playerItem seekToTime:toTime completionHandler:^(BOOL finished) {
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
        [_playerItem seekToTime:toTime toleranceBefore:tolerance toleranceAfter:tolerance completionHandler:^(BOOL finished) {
            if (weakSelf.playbackTime) {
                weakSelf.playbackTime(time, duration);
            }
            if (finished && playAfter) {
                [weakSelf play];
            }
        }];
    }
}

#pragma mark Image

- (UIImage *)previewImage {
    return [self copyImageAtTime:0];
}

- (UIImage *)currentImage {
    return [self copyImageAtTime:self.currentTime];
}

- (UIImage *)copyImageAtTime:(NSTimeInterval)time {
    UIImage *image = nil;
    //
    CMTime atTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    if ([_videoOutput hasNewPixelBufferForItemTime:atTime]) {
        CMTime actualTime = kCMTimeZero;
        CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:atTime itemTimeForDisplay:&actualTime];
        if (pixelBuffer) {
            NSLog(@"copyImageAtTime:%.2f actualTime:%.2f", CMTimeGetSeconds(atTime), CMTimeGetSeconds(actualTime));
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            image = [UIImage imageWithCIImage:ciImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CVBufferRelease(pixelBuffer);
        }
    }
    //
    return image;
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus old = [[change objectForKey:@"old"] integerValue];
        AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
        if (status != old) {
            if (status == AVPlayerStatusReadyToPlay) {
                [self addTimeObserver];
            }
            if (_playerStatus) {
                _playerStatus(status, _playerItem.error);
            }
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        CMTimeRange timeRange = [_playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval loaded = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval duration = [self duration];
        if (_loadedTime) {
            _loadedTime(loaded, duration);
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (_playing) {
            if (_playerItem.isPlaybackBufferEmpty) {
                self.status = ZXPlaybackStatusBuffering;
            } else {
                [self playAtRate];
            }
        }
        
    } else if ([keyPath isEqualToString:@"rate"]) {
        BOOL isPlaying = ABS([[change objectForKey:@"new"] floatValue]) > 0.0;
        if (isPlaying) {
            self.status = ZXPlaybackStatusPlaying;
        } else if (!self.isBuffering && !self.isSeeking && !self.isEnded) {
            self.status = ZXPlaybackStatusPaused;
        }
        
    } else if ([keyPath isEqualToString:@"bounds"]) {
        CGRect bounds = [[change objectForKey:@"new"] CGRectValue];
        _playerLayer.frame = bounds;
    }
}

#pragma mark Gestures

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
