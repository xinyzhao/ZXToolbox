//
// ZXScrollLabel.m
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

#import "ZXScrollLabel.h"

@interface ZXScrollLabel ()
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *nextLabel;
@property (nonatomic, strong) UILabel *prevLabel;

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isStop;

@end

@implementation ZXScrollLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.fadeLength = 8;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.fadeLength = 8;
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
}

- (void)didMoveToSuperview {
    if (self.superview) {
        if (_isStop) {
            [self removeObservers];
        } else {
            [self addObservers];
        }
    }
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollLabels)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollLabels)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (double)haltTime {
    if (_haltTime < 0.01f) {
        return 0.f;
    }
    return _haltTime;
}

- (double)scrollingSpeed {
    if (_scrollingSpeed < 0.01f) {
        return self.bounds.size.width / 6;
    }
    return _scrollingSpeed;
}

- (UILabel *)labelAtIndex:(NSInteger)index {
    UILabel *label = nil;
    if (index < 0) {
        index = self.textArray.count + index;
    }
    if (index >= self.textArray.count) {
        index = 0;
    }
    if (index >= 0 && index < self.textArray.count) {
        label = [[UILabel alloc] initWithFrame:self.bounds];
        label.font = self.font;
        label.textColor = self.textColor;
        label.textAlignment = self.textAlignment;
        label.shadowColor = self.shadowColor;
        label.shadowOffset = self.shadowOffset;
        label.lineBreakMode = self.lineBreakMode;
        label.numberOfLines = self.numberOfLines;
        [self setTextForLabel:label atIndex:index];
        [self.scrollView addSubview:label];
    }
    return label;
}

- (void)setTextForLabel:(UILabel *)label atIndex:(NSInteger)index {
    if (index < 0) {
        index = self.textArray.count + index;
    }
    if (index >= self.textArray.count) {
        index = 0;
    }
    if (index >= 0 && index < self.textArray.count) {
        label.tag = index;
        label.text = self.textArray[index];
        CGRect rect = self.bounds;
        if (self.isVerticalScrolling) {
            if (self.numberOfLines > 1) {
                rect.size.height = FLT_MAX;
                rect.size.height = ceilf([label sizeThatFits:rect.size].height);
            }
        } else if (self.bounds.size.width > 0) {
            rect.size.width = FLT_MAX;
            rect.size.width = [label sizeThatFits:rect.size].width;
            rect.size.width = ceilf(rect.size.width / self.bounds.size.width) * self.bounds.size.width;
        }
        label.bounds = rect;
    } else {
        label.text = nil;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //
    self.scrollView.frame = self.bounds;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    //
    self.scrollView.frame = self.bounds;
}

- (void)startScrolling {
    self.isStop = NO;
    [self scrollLabels];
    [self addObservers];
}

- (void)stopScrolling {
    self.isStop = YES;
    [self removeObservers];
}

- (void)scrollLabels {
    if (self.isScrolling || self.isStop) {
        return;
    }
    //
    if (self.currentLabel == nil) {
        self.currentLabel = [self labelAtIndex:0];
        {
            CGRect frame = self.currentLabel.frame;
            if (self.isVerticalScrolling) {
                frame.origin.x = 0.f;
                frame.origin.y = self.frame.size.height;
            } else {
                frame.origin.x = self.frame.size.width;
                frame.origin.y = 0.f;
            }
            self.currentLabel.frame = frame;
        }
        self.nextLabel = [self labelAtIndex:1];
        {
            CGRect frame = self.nextLabel.frame;
            if (self.isVerticalScrolling) {
                frame.origin.x = 0.f;
                frame.origin.y = self.currentLabel.frame.origin.y + self.currentLabel.frame.size.height;
            } else {
                frame.origin.x = self.currentLabel.frame.origin.x + self.currentLabel.frame.size.width;
                frame.origin.y = 0.f;
            }
            self.nextLabel.frame = frame;
        }
    } else {
        self.prevLabel = self.currentLabel;
        self.currentLabel = self.nextLabel;
        self.nextLabel = self.prevLabel;
    }
    //
    if (self.currentLabel) {
        self.isScrolling = YES;
        //
        CGPoint offset = self.currentLabel.frame.origin;
        NSTimeInterval duration = 0.f;
        NSTimeInterval delay = self.haltTime;
        if (self.isVerticalScrolling) {
            offset.x = 0.f;
            duration = ABS(offset.y - self.prevLabel.frame.origin.y) / self.scrollingSpeed;
        } else {
            offset.y = 0.f;
            duration = ABS(offset.x - self.prevLabel.frame.origin.x) / self.scrollingSpeed;
        }
        //
        __weak typeof(self) weakSelf = self;
        __weak typeof(self.scrollView) scrollView = self.scrollView;
        __weak typeof(self.currentLabel) currentLabel = self.currentLabel;
        __weak typeof(self.nextLabel) nextLabel = self.nextLabel;
        [UIView animateWithDuration:duration delay:0.01 options:UIViewAnimationOptionCurveLinear animations:^{
            scrollView.contentOffset = offset;
        } completion:^(BOOL finished) {
            [weakSelf setTextForLabel:nextLabel atIndex:currentLabel.tag + 1];
            {
                CGRect frame = nextLabel.frame;
                if (weakSelf.isVerticalScrolling) {
                    frame.origin.x = 0.f;
                    frame.origin.y = currentLabel.frame.origin.y + currentLabel.frame.size.height;
                } else {
                    frame.origin.x = currentLabel.frame.origin.x + currentLabel.frame.size.width;
                    frame.origin.y = 0.f;
                }
                nextLabel.frame = frame;
            }
            weakSelf.isScrolling = NO;
            [weakSelf performSelector:_cmd withObject:weakSelf afterDelay:finished ? MIN(delay, duration) : MAX(delay, 0.3)];
        }];
    }
}

// ref: https://github.com/cbpowell/MarqueeLabel
- (void)setFadeLength:(CGFloat)fadeLength {
    _fadeLength = fadeLength;
    
    CGFloat labelWidth = CGRectGetWidth(self.bounds);

//    if (labelWidth <= CGRectGetWidth(self.bounds))
//        fadeLength = 0;

    if (fadeLength) {
        // Recreate gradient mask with new fade length
        CAGradientLayer *gradientMask = [CAGradientLayer layer];

        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;

        gradientMask.startPoint = CGPointMake(0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1, CGRectGetMidY(self.frame));

        // setup fade mask colors and location
        id transparent = (id)[UIColor clearColor].CGColor;
        id opaque = (id)[UIColor blackColor].CGColor;
        gradientMask.colors = @[transparent, opaque, opaque, transparent];

        // calcluate fade
        CGFloat fadePoint = fadeLength / CGRectGetWidth(self.bounds);
        NSNumber *leftFadePoint = @(fadePoint);
        NSNumber *rightFadePoint = @(1 - fadePoint);
        leftFadePoint = @0;
//        leftFadePoint = @0;
//        rightFadePoint = @1;

        // apply calculations to mask
        gradientMask.locations = @[@0, leftFadePoint, rightFadePoint, @1];

        // don't animate the mask change
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
//        self.layer.mask = gradientMask;
//        [CATransaction commit];
    } else {
        // Remove gradient mask for 0.0f length fade length
        self.layer.mask = nil;
    }
}

@end
