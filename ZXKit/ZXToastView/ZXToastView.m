//
// ZXToastView.m
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

#import "ZXToastView.h"

#define ZXToastViewMagicWidth round([UIScreen mainScreen].bounds.size.width * 0.1375)

@interface ZXToastView ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isRunaway) BOOL runaway;

@property (nonatomic, readonly) UIVisualEffectView *effectView NS_AVAILABLE_IOS(8_0);

@end

@implementation ZXToastView

+ (NSMutableArray *)toastQueue {
    static NSMutableArray *toastQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toastQueue = [[NSMutableArray alloc] init];
    });
    return toastQueue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentInset = UIEdgeInsetsMake(64.0, ZXToastViewMagicWidth, 64.0, ZXToastViewMagicWidth);
        self.contentMargin = 20.0;
        self.contentPadding = 8.0;
        self.duration = 3.0;
        self.fadeDuration = 0.2;
        self.position = ZXToastPositionCenter;
        self.dismissWhenTouchInside = YES;
        self.captureWhenTouchOutside = YES;
        //
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            _bubbleView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            _bubbleView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        } else {
            _bubbleView = [[UIView alloc] initWithFrame:CGRectZero];
            _bubbleView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        }
        [self addSubview:_bubbleView];
    }
    return self;
}

- (instancetype)initWithActivity:(NSString *)text {
    self = [self initWithText:text];
    if (self) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        if (@available(iOS 8.0, *)) {
            _activityView.color = [UIColor colorWithWhite:0 alpha:0.7];
            [self.effectView.contentView addSubview:_activityView];
        } else {
            [self.bubbleView addSubview:_activityView];
        }
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text {
    self = [self init];
    if (self) {
        if (text) {
            _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            _textLabel.numberOfLines = 0;
            _textLabel.textAlignment = NSTextAlignmentLeft;
            _textLabel.text = text;
            if (@available(iOS 8.0, *)) {
                _textLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
                [self.effectView.contentView addSubview:_textLabel];
            } else {
                _textLabel.textColor = [UIColor whiteColor];
                [self.bubbleView addSubview:_textLabel];
            }
        }
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text
                    duration:(NSTimeInterval)duration {
    self = [self initWithText:text];
    if (self) {
        self.duration = duration;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text
                    duration:(NSTimeInterval)duration
                       image:(UIImage *)image {
    self = [self initWithText:text duration:duration];
    if (self) {
        if (image) {
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
            _imageView.image = image;
            if (@available(iOS 8.0, *)) {
                [self.effectView.contentView addSubview:_imageView];
            } else {
                [self.bubbleView addSubview:_imageView];
            }
        }
    }
    return self;
}

#pragma mark Effect

- (UIVisualEffectView *)effectView {
    return (UIVisualEffectView *)_bubbleView;
}

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle {
    _effectStyle = effectStyle;
    //
    self.effectView.effect = [UIBlurEffect effectWithStyle:_effectStyle];
}

#pragma mark Size

- (void)sizeToFit:(CGSize)size {
    //
    if (self.textLabel) {
        CGFloat width = size.width - (_contentInset.left + _contentInset.right);
        CGFloat height = size.height - (_contentInset.top + _contentInset.bottom);
        CGSize maxSize = CGSizeMake(width - _contentMargin * 2, height - _contentMargin * 2);
        CGSize msgSize = [self.textLabel sizeThatFits:maxSize];
        // UILabel can return a size larger than the max size when the number of lines is 1
        msgSize = CGSizeMake(MIN(maxSize.width, msgSize.width),
                             MIN(maxSize.height, msgSize.height));
        self.textLabel.frame = CGRectMake(0.0, 0.0, msgSize.width, msgSize.height);
    }
    //
    CGRect toastFrame = CGRectZero;
    if (self.activityView) {
        toastFrame.size.width = _contentMargin * 2 + self.activityView.bounds.size.width;
        toastFrame.size.height = _contentMargin * 2 + self.activityView.bounds.size.height;
    } else if (self.imageView) {
        toastFrame.size.width = _contentMargin * 2 + self.imageView.bounds.size.width;
        toastFrame.size.height = _contentMargin * 2 + self.imageView.bounds.size.height;
    }
    if (self.textLabel) {
        CGFloat width = _contentMargin * 2 + self.textLabel.bounds.size.width;
        toastFrame.size.width = MAX(toastFrame.size.width, width);
        if (self.activityView || self.imageView) {
            toastFrame.size.height += _contentPadding + self.textLabel.bounds.size.height;
        } else {
            toastFrame.size.height = _contentMargin * 2 + self.textLabel.bounds.size.height;
        }
    }
    //
    switch (self.position) {
        case ZXToastPositionTop:
            toastFrame.origin.x = (size.width - toastFrame.size.width) / 2;
            toastFrame.origin.y = _contentInset.top;
            break;
        case ZXToastPositionBottom:
            toastFrame.origin.x = (size.width - toastFrame.size.width) / 2;
            toastFrame.origin.y = size.height - toastFrame.size.height - _contentInset.bottom;
            break;
        case ZXToastPositionLeft:
            toastFrame.origin.x = _contentInset.left;
            toastFrame.origin.y = (size.height - toastFrame.size.height) / 2;
            break;
        case ZXToastPositionRight:
            toastFrame.origin.x = size.width - toastFrame.size.width - _contentInset.right;
            toastFrame.origin.y = (size.height - toastFrame.size.height) / 2;
            break;
        case ZXToastPositionTopLeft:
            toastFrame.origin.x = _contentInset.left;
            toastFrame.origin.y = _contentInset.top;
            break;
        case ZXToastPositionTopRight:
            toastFrame.origin.x = size.width - toastFrame.size.width - _contentInset.right;
            toastFrame.origin.y = _contentInset.top;
            break;
        case ZXToastPositionBottomLeft:
            toastFrame.origin.x = _contentInset.left;
            toastFrame.origin.y = size.height - toastFrame.size.height - _contentInset.bottom;
            break;
        case ZXToastPositionBottomRight:
            toastFrame.origin.x = size.width - toastFrame.size.width - _contentInset.right;
            toastFrame.origin.y = size.height - toastFrame.size.height - _contentInset.bottom;
            break;
        default:
            toastFrame.origin.x = (size.width - toastFrame.size.width) / 2;
            toastFrame.origin.y = (size.height - toastFrame.size.height) / 2;
            break;
    }
    //
    if (self.captureWhenTouchOutside) {
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.bubbleView.frame = toastFrame;
    } else {
        self.frame = toastFrame;
        self.bubbleView.frame = self.bounds;
    }
    //
    if (self.activityView) {
        self.activityView.center = CGPointMake(toastFrame.size.width / 2, _contentMargin + self.activityView.bounds.size.height / 2);
    } else if (self.imageView) {
        self.imageView.center = CGPointMake(toastFrame.size.width / 2, _contentMargin + self.imageView.bounds.size.height / 2);
    }
    if (self.textLabel) {
        CGRect frame = self.textLabel.frame;
        frame.origin.x = (toastFrame.size.width - frame.size.width) / 2;
        if (self.activityView) {
            frame.origin.y = _contentPadding + self.activityView.frame.origin.y + self.activityView.frame.size.height;
        } else if (self.imageView) {
            frame.origin.y = _contentPadding + self.imageView.frame.origin.y + self.imageView.frame.size.height;
        } else {
            frame.origin.y = _contentMargin;
        }
        self.textLabel.frame = frame;
    }
}

#pragma mark Show

- (void)showInView:(UIView *)view {
    if (view == nil) {
        return;
    }
    if (self.activityView == nil && self.textLabel == nil && self.imageView == nil) {
        return;
    }
    //
    _bubbleView.layer.cornerRadius = _contentMargin / 2;
    _bubbleView.layer.masksToBounds = YES;
    //
    [self sizeToFit:view.bounds.size];
    //
    if (self.dismissWhenTouchInside && self.activityView == nil) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBubble:)];
        self.bubbleView.gestureRecognizers = @[tap];
        self.bubbleView.exclusiveTouch = YES;
        self.bubbleView.userInteractionEnabled = YES;
    } else {
        self.bubbleView.userInteractionEnabled = NO;
    }
    //
    self.alpha = 0.0;
    self.userInteractionEnabled = self.captureWhenTouchOutside || self.bubbleView.userInteractionEnabled;
    [view addSubview:self];
    //
    ZXToastView *toastView = [[ZXToastView toastQueue] firstObject];
    if ([ZXToastView toastQueue].count > 1) {
        for (ZXToastView *view in [ZXToastView toastQueue]) {
            if (view != toastView) {
                [view removeFromSuperview];
            }
        }
        //
        NSRange range = NSMakeRange(1, [ZXToastView toastQueue].count - 1);
        [[ZXToastView toastQueue] removeObjectsInRange:range];
    }
    [[ZXToastView toastQueue] addObject:self];
    //
    if (toastView) {
        if (toastView.isRunning && !toastView.isRunaway) {
            [toastView hideAnimated:NO];
        }
    } else {
        [self showAnimated:YES];
    }
}

- (void)showStatus:(NSString *)text {
    if (self.textLabel) {
        self.textLabel.text = text;
        //
        if (self.superview) {
            [self sizeToFit:self.superview.bounds.size];
        }
    }
}

- (void)showAnimated:(BOOL)animated {
    if (self.isRunning) {
        return;
    }
    self.running = YES;
    //
    if (self.activityView) {
        [self.activityView startAnimating];
    }
    //
    __weak typeof(self) weakSelf = self;
    void (^completion)(void) = ^{
        weakSelf.alpha = 1.0;
        if (weakSelf && weakSelf.activityView == nil) {
            weakSelf.timer = [NSTimer timerWithTimeInterval:weakSelf.duration target:weakSelf selector:@selector(hideTimer:) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:weakSelf.timer forMode:NSRunLoopCommonModes];
        }
    };
    //
    if (animated) {
        [UIView animateWithDuration:_fadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             weakSelf.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             completion();
                         }];
    } else {
        completion();
    }
}

#pragma mark Hide

- (void)hideAnimated:(BOOL)animated {
    if (!self.isRunning || self.isRunaway) {
        return;
    }
    self.runaway = YES;
    self.running = NO;
    //
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    //
    __weak typeof(self) weakSelf = self;
    void (^completion)(void) = ^{
        [weakSelf removeFromSuperview];
        [[ZXToastView toastQueue] removeObject:weakSelf];
        weakSelf.runaway = NO;
        //
        ZXToastView *toastView = [[ZXToastView toastQueue] lastObject];
        if (toastView) {
            [toastView showAnimated:animated];
        }
    };
    //
    if (animated) {
        [UIView animateWithDuration:_fadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             weakSelf.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             completion();
                         }];
    } else {
        completion();
    }
}

- (void)hideTimer:(NSTimer *)timer {
    [self hideAnimated:YES];
}

+ (void)hideAllToast {
    ZXToastView *toastView = [[ZXToastView toastQueue] firstObject];
    for (ZXToastView *view in [ZXToastView toastQueue]) {
        if (view != toastView) {
            [view removeFromSuperview];
        }
    }
    [[ZXToastView toastQueue] removeAllObjects];
    if (toastView.isRunning && !toastView.isRunaway) {
        [toastView hideAnimated:YES];
    }
}

#pragma mark Touchs

- (IBAction)onBubble:(id)sender {
    [self hideAnimated:YES];
}

@end
