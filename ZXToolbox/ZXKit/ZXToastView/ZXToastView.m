//
// ZXToastView.m
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

#import "ZXToastView.h"
#import "ZXDispatchQueue.h"
#import "UIApplication+ZXToolbox.h"

#define ZXToastBackColorDark    [UIColor colorWithWhite:0 alpha:0.6]
#define ZXToastBackColorLight   [UIColor colorWithWhite:1 alpha:0.6]
#define ZXToastForeColorDark    [UIColor colorWithWhite:1 alpha:0.8]
#define ZXToastForeColorLight   [UIColor colorWithWhite:0 alpha:0.8]
#define ZXToastTransformScale   CGAffineTransformMakeScale(1.167, 1.167)
#define ZXToastAnimatedShow     0.33
#define ZXToastAnimatedHide     0.167

@interface ZXToastEffectView ()

@end

@implementation ZXToastEffectView
@synthesize loadingView = _loadingView;
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setupView];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupView];
    return self;
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect {
    self = [super initWithEffect:effect];
    [self setupView];
    return self;
}

- (void)setupView {
    _contentInset = UIEdgeInsetsMake(12, 12, 12, 12);
    _itemSpacing = 3;
    _imageSize = CGSizeZero;
    //
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.numberOfLines = 0;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_textLabel];
    //
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
    //
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.contentView addSubview:_loadingView];
    //
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
}

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle {
    _effectStyle = effectStyle;
    self.effect = [UIBlurEffect effectWithStyle:_effectStyle];
}

- (void)sizeToFit:(CGSize)size {
    CGRect rect = CGRectZero;
    rect.size.width = _contentInset.left + _contentInset.right;
    rect.size.height = _contentInset.top + _contentInset.bottom;
    if (!_loadingView.isHidden) {
        if (!CGSizeEqualToSize(_loadingSize, CGSizeZero)) {
            _loadingView.frame = CGRectMake(0, 0, _loadingSize.width, _loadingSize.height);
        }
        rect.size.width += _loadingView.bounds.size.width;
        rect.size.height += _loadingView.bounds.size.height;
    } else if (!_imageView.isHidden) {
        if (CGSizeEqualToSize(_imageSize, CGSizeZero)) {
            [_imageView sizeToFit];
        } else {
            _imageView.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
        }
        rect.size.width += _imageView.bounds.size.width;
        rect.size.height += _imageView.bounds.size.height;
    }
    if (!_textLabel.isHidden) {
        CGSize maxSize = CGSizeMake(size.width - _contentInset.left - _contentInset.right,
                                    size.height - rect.size.height);
        if (!_loadingView.isHidden || !_imageView.isHidden) {
            size.height -= _itemSpacing;
        }
        CGSize msgSize = [_textLabel sizeThatFits:maxSize];
        msgSize.width = ceilf(msgSize.width);
        msgSize.height = ceilf(msgSize.height);
        // UILabel can return a size larger than the max size when the number of lines is 1
        msgSize = CGSizeMake(MIN(maxSize.width, msgSize.width),
                             MIN(maxSize.height, msgSize.height));
        _textLabel.frame = CGRectMake(0, 0, msgSize.width, msgSize.height);
        //
        CGFloat width = _contentInset.left + _contentInset.right + self.textLabel.bounds.size.width;
        rect.size.width = MAX(rect.size.width, width);
        if (!_loadingView.isHidden || !_imageView.isHidden) {
            rect.size.height += _itemSpacing;
        }
        rect.size.height += _textLabel.bounds.size.height;
    }
    if (!_loadingView.isHidden) {
        CGSize size = _loadingView.bounds.size;
        size.width = rect.size.width / 2;
        size.height = _contentInset.top + size.height / 2;
        _loadingView.center = CGPointMake(size.width, size.height);
    }
    if (!_imageView.isHidden) {
        CGRect frame = _imageView.bounds;
        frame.origin.x = (rect.size.width - frame.size.width) / 2;
        frame.origin.y = _contentInset.top;
        _imageView.frame = frame;
    }
    if (!_textLabel.isHidden) {
        CGRect frame = _textLabel.bounds;
        frame.origin.x = (rect.size.width - frame.size.width) / 2;
        frame.origin.y = rect.size.height - frame.size.height - _contentInset.bottom;
        _textLabel.frame = frame;
    }
    self.frame = rect;
}

@end

@interface ZXToastView ()
@property (class, nonatomic, readonly) NSMutableDictionary *allToasts;
@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isRunaway) BOOL runaway;

@end

@implementation ZXToastView
@synthesize effectView = _effectView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _animation = ZXToastAnimationFade;
        _centerPoint = CGPointMake(0.5, 0.5);
        _safeAreaInset = [UIApplication safeAreaInsets];
        //
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[ZXToastEffectView alloc] initWithEffect:blur];
        [self addSubview:_effectView];
        //
        self.style = ZXToastStyleSystem;
    }
    return self;
}

#pragma mark Showing

- (void)showText:(nullable NSString *)text {
    _effectView.textLabel.text = text;
    //
    _effectView.textLabel.hidden = NO;
    _effectView.imageView.hidden = YES;
    [_effectView.loadingView stopAnimating];
    //
    if (self.isRunning) {
        [self prepareForView:nil];
        self.hidden = NO;
    } else {
        [self showAnimated:YES];
    }
}

- (void)showImage:(UIImage *)image text:(nullable NSString *)text {
    _effectView.textLabel.text = text;
    _effectView.imageView.image = image;
    //
    _effectView.textLabel.hidden = NO;
    _effectView.imageView.hidden = NO;
    [_effectView.loadingView stopAnimating];
    //
    if (self.isRunning) {
        [self prepareForView:nil];
        self.hidden = NO;
    } else {
        [self showAnimated:YES];
    }
}

- (void)showLoading:(nullable NSString *)text {
    _effectView.textLabel.text = text;
    //
    _effectView.textLabel.hidden = text == nil;
    _effectView.imageView.hidden = YES;
    [_effectView.loadingView startAnimating];
    //
    if (self.isRunning) {
        [self prepareForView:nil];
        self.hidden = NO;
    } else {
        [self showAnimated:YES];
    }
}

- (void)showAnimated:(BOOL)animated {
    if (self.isRunning) {
        return;
    }
    self.running = YES;
    //
    if (self.superview == nil) {
        [self prepareForView:nil];
    }
    //
    id key = @(self.superview.hash);
    if (key) {
        ZXToastView *toastView = [[ZXToastView allToasts] objectForKey:key];
        if (toastView) {
            [toastView hideAnimated:NO];
        }
        [[ZXToastView allToasts] setObject:self forKey:key];
    }
    //
    self.hidden = NO;
    self.effectView.hidden = _customView != nil;
    //
    if (animated) {
        __weak typeof(self) weakSelf = self;
        switch (_animation) {
            case ZXToastAnimationFade:
            {
                self.customView.alpha = 0.f;
                self.effectView.alpha = 0.f;
                [UIView animateWithDuration:ZXToastAnimatedShow animations:^{
                    weakSelf.customView.alpha = 1.f;
                    weakSelf.effectView.alpha = 1.f;
                } completion:^(BOOL finished) {
                    if (finished) {
                        weakSelf.customView.alpha = 1.f;
                        weakSelf.effectView.alpha = 1.f;
                    }
                }];
                break;
            }
            case ZXToastAnimationScale:
            {
                self.customView.alpha = 0.f;
                self.effectView.alpha = 0.f;
                self.customView.transform = ZXToastTransformScale;
                self.effectView.transform = ZXToastTransformScale;
                [UIView animateWithDuration:ZXToastAnimatedShow animations:^{
                    weakSelf.customView.alpha = 1.f;
                    weakSelf.effectView.alpha = 1.f;
                    weakSelf.customView.transform = CGAffineTransformIdentity;
                    weakSelf.effectView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    if (finished) {
                        weakSelf.customView.alpha = 1.f;
                        weakSelf.effectView.alpha = 1.f;
                        weakSelf.customView.transform = CGAffineTransformIdentity;
                        weakSelf.effectView.transform = CGAffineTransformIdentity;
                    }
                }];
                break;
            }
        }
    }
}

- (void)showInView:(nullable UIView *)view {
    [self prepareForView:view];
    [self showAnimated:YES];
}

#pragma mark Hiding

- (void)hideAfter:(NSTimeInterval)time {
    __weak typeof(self) weakSelf = self;
    NSString *key = [NSString stringWithFormat:@"ZXToastView.hideAfter_%lu", (unsigned long)self.hash];
    [[ZXDispatchQueue main] asyncAfter:key deadline:time execute:^(NSString * _Nonnull event) {
        [weakSelf hideAnimated:YES];
    }];
}

- (void)hideAnimated:(BOOL)animated {
    if (!self.isRunning || self.isRunaway) {
        return;
    }
    self.runaway = YES;
    self.running = NO;
    //
    __weak typeof(self) weakSelf = self;
    void (^completion)(void) = ^{
        id key = @(weakSelf.superview.hash);
        if (key) {
            [[ZXToastView allToasts] removeObjectForKey:key];
        }
        [weakSelf removeFromSuperview];
        weakSelf.runaway = NO;
    };
    //
    if (animated) {
        __weak typeof(self) weakSelf = self;
        switch (_animation) {
            case ZXToastAnimationFade:
            {
                [UIView animateWithDuration:ZXToastAnimatedHide animations:^{
                    weakSelf.customView.alpha = 0.f;
                    weakSelf.effectView.alpha = 0.f;
                } completion:^(BOOL finished) {
                    if (finished) {
                        weakSelf.customView.alpha = 0.f;
                        weakSelf.effectView.alpha = 0.f;
                    }
                    completion();
                }];
                break;
            }
            case ZXToastAnimationScale:
            {
                [UIView animateWithDuration:ZXToastAnimatedHide animations:^{
                    weakSelf.customView.alpha = 0.f;
                    weakSelf.effectView.alpha = 0.f;
                    weakSelf.customView.transform = ZXToastTransformScale;
                    weakSelf.effectView.transform = ZXToastTransformScale;
                } completion:^(BOOL finished) {
                    completion();
                }];
                break;
            }
        }
    } else {
        completion();
    }
}

#pragma mark Adaptiving

- (void)prepareForView:(nullable UIView *)view {
    if (view == nil) {
        view = [UIApplication keyWindow];
    }
    [self setStyle:_style forView:view];
    [self sizeToFit:view.bounds.size];
    //
    self.hidden = YES;
    [view addSubview:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    if (self.isRunning && !self.isRunaway) {
        if (self.superview) {
            self.frame = self.superview.bounds;
        }
        [self sizeToFit:self.bounds.size];
    }
}

- (void)sizeToFit:(CGSize)size {
    if (_customView != nil) {
        [self addSubview:_customView];
    } else {
        CGSize s = size;
        if (@available(iOS 11.0, *)) {
            s.width -= _safeAreaInset.left + _safeAreaInset.right;
            s.height -= _safeAreaInset.top + _safeAreaInset.bottom;
        }
        [_effectView sizeToFit:s];
    }
    //
    UIView *view = _customView ? _customView : _effectView;
    view.center = CGPointMake(size.width * _centerPoint.x, size.height * _centerPoint.y);
}

- (void)setStyle:(ZXToastStyle)style forView:(nullable UIView *)view {
    switch (style) {
        case ZXToastStyleDark:
            _effectView.effectStyle = UIBlurEffectStyleDark;
            _effectView.textLabel.textColor = ZXToastForeColorDark;
            _effectView.loadingView.color = ZXToastForeColorDark;
            break;
        case ZXToastStyleLight:
            _effectView.effectStyle = UIBlurEffectStyleLight;
            _effectView.textLabel.textColor = ZXToastForeColorLight;
            _effectView.loadingView.color = ZXToastForeColorLight;
            break;
        case ZXToastStyleSystem:
            if (@available(iOS 13.0, *)) {
                if (view.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    [self setStyle:ZXToastStyleLight forView:nil];
                } else {
                    [self setStyle:ZXToastStyleDark forView:nil];
                }
            } else {
                [self setStyle:ZXToastStyleDark forView:nil];
            }
            break;
        default:
            break;
    }
}

#pragma makr - All toasts

+ (NSMutableDictionary *)allToasts {
    static NSMutableDictionary *dict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dict = [[NSMutableDictionary alloc] init];
    });
    return dict;
}

+ (void)hideAllToasts {
    NSArray *keys = [[self allToasts] allKeys];
    for (id key in keys) {
        ZXToastView *view = [[self allToasts] objectForKey:key];
        [view hideAnimated:NO];
    }
    [[self allToasts] removeAllObjects];
}

@end
