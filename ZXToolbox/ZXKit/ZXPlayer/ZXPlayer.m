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
@property (nonatomic, strong) ZXBrightnessView *brightnessView;
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, assign) ZXPlaybackStatus status;
@property (nonatomic, assign) BOOL playing;

@end

@implementation ZXPlayer

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[ZXPlayer alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        _status = ZXPlaybackStatusBuffering;
        _playing = NO;
        _playbackTimeInterval = 1.0;
        _URL = [URL copy];
        if (_URL) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_URL options:nil];
            if (asset) {
                _playerItem = [AVPlayerItem playerItemWithAsset:asset];
            }
        }
        if (_playerItem) {
            [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
            [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
            //
            __weak typeof(self) weakSelf = self;
            if (_playerItemDidPlayToEndTimeObserver) {
                [[NSNotificationCenter defaultCenter] removeObserver:_playerItemDidPlayToEndTimeObserver];
            }
            _playerItemDidPlayToEndTimeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                if (note.object == weakSelf.playerItem) {
                    weakSelf.status = ZXPlaybackStatusEnded;
                }
            }];
            //
            _videoOutput = [[AVPlayerItemVideoOutput alloc] init];
            [_playerItem addOutput:_videoOutput];
            //
            _player = [AVPlayer playerWithPlayerItem:_playerItem];
        }
        if (_player) {
            if (@available(iOS 10.0, *)) {
                _player.automaticallyWaitsToMinimizeStalling = NO;
            }
            [_player addObserver:self forKeyPath:@"rate" options:(NSKeyValueObservingOptionNew) context:nil];
            //
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
            _playerLayer.videoGravity = _videoGravity;
        }
        //
        _brightnessFactor = 0.5;
        _seekingFactor = 0.5;
        _volumeFactor = 0.5;
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecognizer:)];
        //
        _brightnessView = [ZXBrightnessView brightnessView];
        [_brightnessView addObserver];
        //
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return self;
}

- (void)dealloc {
    if (_brightnessView) {
        [_brightnessView removeObserver];
        _brightnessView = nil;
    }
    [self detach];
    [self stop];
}

#pragma mark Attach & Detach

- (void)attachToView:(UIView *)view {
    [self detach];
    //
    _attachView = view;
    if (_attachView) {
        if (_playerLayer) {
            _playerLayer.frame = _attachView.bounds;
            [_attachView.layer insertSublayer:_playerLayer atIndex:0];
            [_attachView.layer addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
        }
        if (_panGestureRecognizer) {
            [_attachView addGestureRecognizer:_panGestureRecognizer];
        }
    }
}

- (void)detach {
    if (_attachView) {
        [_playerLayer removeFromSuperlayer];
        [_attachView removeGestureRecognizer:_panGestureRecognizer];
        @try {
            [_attachView.layer removeObserver:self forKeyPath:@"bounds"];
        } @catch (NSException *ex) {
            NSLog(@"%@", ex.description);
        }
        _attachView = nil;
    }
}

#pragma mark Time Observer

- (void)addTimeObserver {
    if (_player.status == AVPlayerStatusReadyToPlay) {
        [self removeTimeObserver];
        //
        if (_playbackTimeInterval > 0.001) {
            // Invoke callback every _playbackTimeInterval second
            CMTime interval = CMTimeMakeWithSeconds(_playbackTimeInterval, NSEC_PER_SEC);
            // Queue on which to invoke the callback
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            // Add time observer
            __weak typeof(self) weakSelf = self;
            _periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
                if (weakSelf.status == ZXPlaybackStatusPlaying) {
                    if (weakSelf.playbackTime) {
                        weakSelf.playbackTime(CMTimeGetSeconds(time), weakSelf.duration);
                    }
                }
            }];
        }
    }
}

- (void)removeTimeObserver {
    if (_periodicTimeObserver) {
        [_player removeTimeObserver:_periodicTimeObserver];
        _periodicTimeObserver = nil;
    }
}

#pragma mark Setter

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

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    _videoGravity = [videoGravity copy];
    if (_playerLayer) {
        _playerLayer.videoGravity = _videoGravity;
    }
}

- (void)setRate:(float)rate {
    _rate = rate;
    [self playAtRate];
}

#pragma mark Getter

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
    //
    [self removeTimeObserver];
    //
    if (_player) {
        @try {
            [_player removeObserver:self forKeyPath:@"rate"];
        } @catch (NSException *ex) {
            NSLog(@"%@", ex.description);
        }
        _player = nil;
    }
    //
    if (_playerItem) {
        if (_playerItemDidPlayToEndTimeObserver) {
            [[NSNotificationCenter defaultCenter] removeObserver:_playerItemDidPlayToEndTimeObserver];
            _playerItemDidPlayToEndTimeObserver = nil;
        }
        @try {
            [_playerItem removeObserver:self forKeyPath:@"status"];
            [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
            [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        } @catch (NSException *ex) {
            NSLog(@"%@", ex.description);
        }
        _playerItem = nil;
    }
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
    }
    return duration;
}

- (void)seekToTime:(NSTimeInterval)time playAfter:(BOOL)playAfter {
    if (self.isReadToPlay) {
        self.status = ZXPlaybackStatusSeeking;
        [_player pause];
        //
        NSTimeInterval duration = self.duration;
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

#pragma mark Image

- (UIImage *)previewImage {
    return [self copyImageAtTime:0];
}

- (UIImage *)currentImage {
    return [self copyImageAtTime:self.currentTime];
}

- (UIImage *)copyImageAtTime:(NSTimeInterval)time {
    UIImage *image = nil;
    CMTime atTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    CMTime actualTime = kCMTimeZero;
    /*/ 不能用 copyPixelBufferForItemTime，原因是 iPhoneXR/iPhoneXS 在暂停或停止播放后 Copy 出来的 Image 是无效的
    CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:atTime itemTimeForDisplay:&actualTime];
    if (pixelBuffer) {
        NSLog(@"copyImageAtTime:%.2f actualTime:%.2f", CMTimeGetSeconds(atTime), CMTimeGetSeconds(actualTime));
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        CVBufferRelease(pixelBuffer);
        image = [UIImage imageWithCIImage:ciImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    }*/
    //
    if (self.playerItem.asset) {
        NSError *error = nil;
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self.playerItem.asset];
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        CGImageRef imageRef = [generator copyCGImageAtTime:atTime actualTime:&actualTime error:&error];
        if (imageRef == nil) {
            generator.requestedTimeToleranceBefore = kCMTimePositiveInfinity;
            generator.requestedTimeToleranceAfter = kCMTimePositiveInfinity;
            imageRef = [generator copyCGImageAtTime:atTime actualTime:&actualTime error:&error];
        }
        if (error) {
            NSLog(@"copyImageAtTime:%.2f error:%@", time, error.localizedDescription);
        } else {
            NSLog(@"copyImageAtTime:%.2f actualTime:%.2f", time, CMTimeGetSeconds(actualTime));
        }
        if (imageRef) {
            image = [[UIImage alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
    }
    //
    return image;
}

#pragma mark Volume

- (void)setVolume:(float)volume {
    _player.volume = volume;
}

- (float)volume {
    return _player.volume;
}

- (void)setMuted:(BOOL)muted {
    _player.muted = muted;
}

- (BOOL)isMuted {
    return _player.muted;
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
        NSTimeInterval duration = self.duration;
        if (_loadedTime) {
            _loadedTime(loaded, duration);
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        if (_playing) {
            if (_playerItem.isPlaybackBufferEmpty) {
                self.status = ZXPlaybackStatusBuffering;
            } else {
                [_player play];
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
                    NSTimeInterval time = seekTime + (point.x / (pan.view.frame.size.width * _seekingFactor)) * self.duration;
                    if (time < 0) {
                        time = 0;
                    }
                    if (time > self.duration) {
                        time = self.duration;
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
