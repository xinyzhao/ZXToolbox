//
// ZXBadgeLabel.m
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

#import "ZXBadgeLabel.h"

@implementation ZXBadgeLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.audoHide = YES;
    self.number = 0;
    self.mininum = 0;
    self.maxinum = 99;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    if (self.layer.masksToBounds || self.clipsToBounds) {
        self.layer.cornerRadius = self.frame.size.height / 2;
    }
    //
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    size.width += self.frame.size.height / 2;
    size.height = self.frame.size.height;
    if (size.width < size.height) {
        size.width = size.height;
    }
    // AutoLayout
    if (self.constraints.count > 0) {
        [self removeConstraints:self.constraints];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:size.width]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:size.height]];
    } else {
        CGRect rect = self.frame;
        rect.origin = self.center;
        rect.size = size;
        self.frame = rect;
        self.center = rect.origin;
    }
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    [self updateText];
}

- (void)setMininum:(NSInteger)mininum {
    _mininum = mininum;
    [self updateText];
}

- (void)setMaxinum:(NSInteger)maxinum {
    _maxinum = maxinum;
    [self updateText];
}

- (void)updateText {
    //
    if (self.audoHide) {
        self.hidden = _number <= _mininum;
    }
    //
    if (_number < _mininum) {
        self.text = [NSString stringWithFormat:@"%lld+", (int64_t)_mininum];
    } else if (_number > _maxinum) {
        self.text = [NSString stringWithFormat:@"%lld+", (int64_t)_maxinum];
    } else {
        self.text = [NSString stringWithFormat:@"%lld", (int64_t)_number];
    }
    //
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
