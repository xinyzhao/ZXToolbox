//
// ZXBrightnessView.m
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

#import "ZXBrightnessView.h"
#import "UIColor+ZXToolbox.h"

@interface ZXBrightnessView ()
@property (nonatomic, strong) UIView *levelView;
@property (nonatomic, strong) NSTimer *disappearTimer;
@property (nonatomic, assign) BOOL willDisappear;

@end

@implementation ZXBrightnessView

#define ZXBrightnessBounds  CGRectMake(0.0, 0.0, 155.0, 155.0)
#define ZXBrightnessColor   [UIColor colorWithString:@"#484848"]

+ (instancetype)brightnessView {
    static ZXBrightnessView *brightnessView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brightnessView = [[ZXBrightnessView alloc] initWithFrame:ZXBrightnessBounds];
    });
    return brightnessView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = nil;
        self.layer.cornerRadius  = 8;
        self.layer.masksToBounds = YES;
        //
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolBar.alpha = 0.99;
        [self addSubview:toolBar];
        //
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        label.font = [UIFont boldSystemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = ZXBrightnessColor;
        label.text = @"亮度";
        [self addSubview:label];
        //
        NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
        NSString *bundlePath = [mainBundle pathForResource:@"ZXBrightnessView" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *file = [bundle pathForResource:@"brightness@2x" ofType:@"png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        imageView.image = [UIImage imageWithContentsOfFile:file];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.clipsToBounds = YES;
        imageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        [self addSubview:imageView];
        //
        self.levelView = [[UIView alloc] initWithFrame:CGRectMake(13, self.bounds.size.height - 16 - 7, self.bounds.size.width - 13 * 2, 7)];
        self.levelView.backgroundColor = ZXBrightnessColor;
        [self addSubview:self.levelView];
        //
        CGFloat width = (self.levelView.bounds.size.width - 17) / 16;
        CGFloat height = self.levelView.bounds.size.height - 2;
        CGRect frame = CGRectMake(1, 1, width, height);
        for (NSInteger i = 0; i < 16; ++i) {
            frame.origin.x = i * (width + 1) + 1;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.tag = i;
            [self.levelView addSubview:imageView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    self.bounds = ZXBrightnessBounds;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.center = CGPointMake(self.window.bounds.size.width / 2, (self.window.bounds.size.height - 10) / 2);
            break;
        default:
            self.center = CGPointMake(self.window.bounds.size.width / 2, self.window.bounds.size.height / 2);
            break;
    }
}

#pragma mark Brightness

- (CGFloat)brightness {
    return [UIScreen mainScreen].brightness;
}

- (void)setBrightness:(CGFloat)brightness {
    [UIScreen mainScreen].brightness = brightness;
}

#pragma mark Observer

- (void)addObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)removeObserver {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CGFloat level = [change[@"new"] floatValue];
    [self presentViewAnimated];
    [self updateBrightnessLevel:level];
}

- (void)applicationDidChangeStatusBarOrientationNotification:(id)sender {
    [self setNeedsLayout];
}

#pragma mark Present

- (void)presentViewAnimated {
    if (self.superview != self.window) {
        [self presentView];
        self.disappearTimer = [NSTimer timerWithTimeInterval:2.0
                                                      target:self
                                                    selector:@selector(dismissViewAnimated)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.disappearTimer forMode:NSDefaultRunLoopMode];
    } else {
        self.alpha = 1.0;
        self.willDisappear = NO;
    }
}

- (void)presentView {
    self.alpha = 1.0;
    [self.window addSubview:self];
    self.willDisappear = YES;
}

#pragma mark Dismiss

- (void)dismissViewAnimated {
    if (self.willDisappear) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (self.willDisappear) {
                [self dismissView];
            }
        }];
    } else {
        self.willDisappear = YES;
    }
}

- (void)dismissView {
    [self removeFromSuperview];
    if (self.disappearTimer) {
        [self.disappearTimer invalidate];
        self.disappearTimer = nil;
    }
    self.willDisappear = NO;
}

#pragma mark Update

- (void)updateBrightnessLevel:(CGFloat)brightness {
    CGFloat stage = 1 / 15.0;
    NSInteger level = brightness / stage;
    for (UIView *view in self.levelView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = view.tag > level;
        }
    }
}

#pragma mark Window

- (UIWindow *)window {
    return [[UIApplication sharedApplication] keyWindow];
}

@end
