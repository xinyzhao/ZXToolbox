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

#define ZXToastAffineTransformScale     CGAffineTransformMakeScale(1.167, 1.167)
#define ZXToastAnimateShowDuration      0.33
#define ZXToastAnimateHideDuration      0.167

@interface ZXToastEffectView ()

@end

@implementation ZXToastEffectView
@synthesize loadingView = _loadingView;
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize contentSize = _contentSize;

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
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;
    //
    _contentInset = UIEdgeInsetsMake(16, 16, 16, 16);
    _itemSpacing = 8;
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
}

- (void)setEffectStyle:(UIBlurEffectStyle)effectStyle {
    _effectStyle = effectStyle;
    self.effect = [UIBlurEffect effectWithStyle:_effectStyle];
}

- (void)setTintColor:(UIColor *)tintColor {
    super.tintColor = tintColor;
    _textLabel.textColor = tintColor;
    _imageView.tintColor = tintColor;
    _loadingView.color = tintColor;
}

- (void)sizeToFit:(CGSize)size {
    _contentSize = CGSizeZero;
    size.width -= _contentInset.left + _contentInset.right;
    size.height -= _contentInset.top + _contentInset.bottom;
    //
    if (!_loadingView.isHidden) {
        if (!CGSizeEqualToSize(_loadingSize, CGSizeZero)) {
            _loadingView.frame = CGRectMake(0, 0, _loadingSize.width, _loadingSize.height);
        }
        _contentSize.width = MIN(_loadingView.bounds.size.width, size.width);
        _contentSize.height = MIN(_loadingView.bounds.size.height, size.height);
    } else if (!_imageView.isHidden) {
        if (CGSizeEqualToSize(_imageSize, CGSizeZero)) {
            [_imageView sizeToFit];
        } else {
            _imageView.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
        }
        _contentSize.width = MIN(_imageView.bounds.size.width, size.width);
        _contentSize.height = MIN(_imageView.bounds.size.height, size.height);
    }
    //
    if (!_textLabel.isHidden) {
        if (_contentSize.height > 0) {
            size.height -= _contentSize.height;
            size.height -= _itemSpacing;
        }
        //
        CGSize msgSize = [_textLabel sizeThatFits:size];
        msgSize.width = ceilf(msgSize.width);
        msgSize.height = ceilf(msgSize.height);
        // UILabel can return a size larger than the max size when the number of lines is 1
        msgSize.width = MIN(size.width, msgSize.width);
        msgSize.height = MIN(size.height, msgSize.height);
        //
        _textLabel.bounds = CGRectMake(0, 0, msgSize.width, msgSize.height);
        //
        _contentSize.width = MAX(_contentSize.width, msgSize.width);
        if (_contentSize.height > 0) {
            _contentSize.height += _itemSpacing;
        }
        _contentSize.height += msgSize.height;
    }
    //
    CGPoint offset = CGPointMake(_contentInset.left + _contentSize.width / 2, _contentInset.top);
    if (!_loadingView.isHidden) {
        _loadingView.center = CGPointMake(offset.x, offset.y + _loadingView.bounds.size.height / 2);
        offset.y += _loadingView.bounds.size.height;
        offset.y += _itemSpacing;
    } else if (!_imageView.isHidden) {
        _imageView.center = CGPointMake(offset.x, offset.y + _imageView.bounds.size.height / 2);
        offset.y += _imageView.bounds.size.height;
        offset.y += _itemSpacing;
    }
    if (!_textLabel.isHidden) {
        _textLabel.center = CGPointMake(offset.x, offset.y + _textLabel.bounds.size.height / 2);
    }
    //
    _contentSize.width += _contentInset.left + _contentInset.right;
    _contentSize.height += _contentInset.top + _contentInset.bottom;
    self.bounds = CGRectMake(0, 0, _contentSize.width, _contentSize.height);
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

- (void)setCustomView:(UIView *)customView {
    if (_customView != customView) {
        [_customView removeFromSuperview];
        _customView = customView;
    }
}

#pragma mark Showing

- (void)showText:(nullable NSString *)text {
    _effectView.textLabel.text = text;
    _effectView.imageView.image = nil;
    //
    _effectView.textLabel.hidden = NO;
    _effectView.imageView.hidden = YES;
    [_effectView.loadingView stopAnimating];
    //
    [self showAnimated:YES];
}

- (void)showImage:(UIImage *)image text:(nullable NSString *)text {
    _effectView.textLabel.text = text;
    _effectView.imageView.image = image;
    //
    _effectView.textLabel.hidden = text == nil || text.length <= 0;
    _effectView.imageView.hidden = NO;
    [_effectView.loadingView stopAnimating];
    //
    [self showAnimated:YES];
}

- (void)showLoading:(nullable NSString *)text {
    _effectView.textLabel.text = text;
    _effectView.imageView.image = nil;
    //
    _effectView.textLabel.hidden = text == nil || text.length <= 0;
    _effectView.imageView.hidden = YES;
    [_effectView.loadingView startAnimating];
    //
    [self showAnimated:YES];
}

- (void)showAnimated:(BOOL)animated {
    [self prepareForView:nil];
    [self showAnimation:animated ? _animation : ZXToastAnimationNone];
}

- (void)showAnimation:(ZXToastAnimation)animation {
    [self cancelHideAfter];
    //
    if (self.isRunning) {
        return;
    }
    self.running = YES;
    //
    id key = @(self.superview.hash);
    if (key) {
        ZXToastView *toastView = [[ZXToastView allToasts] objectForKey:key];
        if (toastView != self) {
            [toastView hideAnimated:NO];
        }
        [[ZXToastView allToasts] setObject:self forKey:key];
    }
    //
    [_customView.layer removeAllAnimations];
    [_effectView.layer removeAllAnimations];
    //
    switch (animation) {
        case ZXToastAnimationNone:
        {
            _customView.alpha = 1.f;
            _effectView.alpha = 1.f;
            _customView.transform = CGAffineTransformIdentity;
            _effectView.transform = CGAffineTransformIdentity;
            break;
        }
        case ZXToastAnimationFade:
        {
            _customView.alpha = 0.f;
            _effectView.alpha = 0.f;
            _customView.transform = CGAffineTransformIdentity;
            _effectView.transform = CGAffineTransformIdentity;
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:ZXToastAnimateShowDuration animations:^{
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
            _customView.alpha = 0.f;
            _effectView.alpha = 0.f;
            _customView.transform = ZXToastAffineTransformScale;
            _effectView.transform = ZXToastAffineTransformScale;
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:ZXToastAnimateShowDuration animations:^{
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

- (void)showInView:(nullable UIView *)view {
    [self prepareForView:view];
    [self showAnimation:_animation];
}

#pragma mark Hiding

- (NSString *)hashKey {
    return [NSString stringWithFormat:@"ZXToastView.hideAfter_%lu", (unsigned long)self.hash];
}

- (void)cancelHideAfter {
    [[ZXDispatchQueue main] cancelAfter:self.hashKey];
}

- (void)hideAfter:(NSTimeInterval)time {
    __weak typeof(self) weakSelf = self;
    [[ZXDispatchQueue main] asyncAfter:self.hashKey deadline:time execute:^(NSString * _Nonnull event) {
        [weakSelf hideAnimated:YES];
    }];
}

- (void)hideAnimated:(BOOL)animated {
    [self hideAnimation:animated ? _animation : ZXToastAnimationNone];
}

- (void)hideAnimation:(ZXToastAnimation)animation {
    [self cancelHideAfter];
    //
    if (!self.isRunning || self.isRunaway) {
        return;
    }
    self.runaway = YES;
    self.running = NO;
    //
    __weak typeof(self) weakSelf = self;
    void (^finish)(BOOL) = ^(BOOL finished) {
        id key = @(weakSelf.superview.hash);
        if (key) {
            [[ZXToastView allToasts] removeObjectForKey:key];
        }
        [weakSelf removeFromSuperview];
        weakSelf.runaway = NO;
    };
    //
    [_customView.layer removeAllAnimations];
    [_effectView.layer removeAllAnimations];
    //
    switch (animation) {
        case ZXToastAnimationNone:
        {
            finish(YES);
            break;
        }
        case ZXToastAnimationFade:
        {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:ZXToastAnimateHideDuration animations:^{
                weakSelf.customView.alpha = 0.f;
                weakSelf.effectView.alpha = 0.f;
                weakSelf.customView.transform = CGAffineTransformIdentity;
                weakSelf.effectView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                finish(finished);
            }];
            break;
        }
        case ZXToastAnimationScale:
        {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:ZXToastAnimateHideDuration animations:^{
                weakSelf.customView.alpha = 0.f;
                weakSelf.effectView.alpha = 0.f;
                weakSelf.customView.transform = ZXToastAffineTransformScale;
                weakSelf.effectView.transform = ZXToastAffineTransformScale;
            } completion:^(BOOL finished) {
                finish(finished);
            }];
            break;
        }
    }
}

#pragma mark Adaptiving

- (void)prepareForView:(nullable UIView *)view {
    if (view == nil) {
        view = self.superview ? self.superview : [UIApplication keyWindow];
    }
    [self setStyle:_style forView:view];
    [self sizeToFit:view.bounds.size];
    //
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
    _effectView.hidden = _customView != nil;
    //
    UIView *view = _customView ? _customView : _effectView;
    view.center = CGPointMake(size.width * _centerPoint.x, size.height * _centerPoint.y);
}

- (void)setStyle:(ZXToastStyle)style forView:(nullable UIView *)view {
    switch (style) {
        case ZXToastStyleDark:
            _effectView.effectStyle = UIBlurEffectStyleDark;
            _effectView.tintColor = [UIColor lightTextColor];
            break;
        case ZXToastStyleLight:
            _effectView.effectStyle = UIBlurEffectStyleLight;
            _effectView.tintColor = [UIColor darkTextColor];
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

+ (void)hideToasts {
    NSArray *keys = [[self allToasts] allKeys];
    for (id key in keys) {
        ZXToastView *view = [[self allToasts] objectForKey:key];
        [view hideAnimated:YES];
    }
    [[self allToasts] removeAllObjects];
}

@end
