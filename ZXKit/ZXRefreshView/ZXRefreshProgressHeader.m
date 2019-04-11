//
// ZXRefreshProgressHeader.m
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

#import "ZXRefreshProgressHeader.h"
#import "ZXCircularProgressView.h"

@implementation ZXRefreshProgressHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.circularRadius = 16;
        self.animationDuration = 0.8;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark Setter & Getter

- (void)setCircularRadius:(CGFloat)radius {
    _circularRadius = radius;
    //
    CGRect rect  = self.frame;
    rect.origin.x = rect.size.width / 2 - radius;
    rect.origin.y = rect.size.height / 2 - radius;
    rect.size = CGSizeMake(radius * 2, radius * 2);
    //
    if (self.progressView == nil) {
        self.progressView = [[ZXCircularProgressView alloc] initWithFrame:rect];
        self.progressView.progressViewStyle = ZXCircularProgressViewStyleRing;
        self.progressView.integrity = 0.8;
        self.progressView.lineWidth = 1.5;
        [self addSubview:self.progressView];
    } else {
        self.progressView.frame = rect;
    }
    //
    [self updateContentSize];
}

#pragma mark Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.progressView.center = center;
}

#pragma mark Animating

- (void)startAnimating {
    if (self.progressView.tag == 0) {
        self.progressView.tag = 1;
        [self.progressView.layer removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = [NSNumber numberWithDouble:M_PI * 2];
        animation.duration = _animationDuration;
        animation.cumulative = YES;
        animation.repeatCount = INT_MAX;
        animation.removedOnCompletion = NO;
        [self.progressView.layer addAnimation:animation forKey:@"transform.rotation.z"];
    }
}

- (void)stopAnimating {
    if (self.progressView.tag == 1) {
        [self.progressView.layer removeAllAnimations];
        self.progressView.tag = 0;
    }
}

#pragma mark <ZXRefreshProtocol>

- (void)setPullingProgress:(CGFloat)progress {
    [super setPullingProgress:progress];
    self.progressView.progress = progress;
}

- (BOOL)beginRefreshing {
    if ([super beginRefreshing]) {
        self.pullingProgress = 1.f;
        [self startAnimating];
        return YES;
    }
    return NO;
}

- (BOOL)endRefreshing {
    if ([super endRefreshing]) {
        [self stopAnimating];
        return YES;
    }
    return NO;
}

- (void)updateContentSize {
    [super updateContentSize];
    //
    self.contentOffset = (self.contentHeight + _circularRadius * 2) / 2;
}

@end
