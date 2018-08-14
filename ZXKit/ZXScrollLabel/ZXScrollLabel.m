//
// ZXScrollLabel.m
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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
@property (nonatomic, strong) NSMutableArray *textArray;
@property (nonatomic, strong) NSMutableArray *textFrames;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *nextLabel;
@property (nonatomic, strong) UILabel *prevLabel;

@end

@implementation ZXScrollLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.text = nil;
        _haltTime = 3.f;
        _scrollSpeed = 30.f;
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = nil;
        _haltTime = 3.f;
        _scrollSpeed = 30.f;
        [self addObservers];
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSMutableArray *)textArray {
    if (_textArray == nil) {
        _textArray = [[NSMutableArray alloc] init];
    }
    return _textArray;
}

- (NSMutableArray *)textFrames {
    if (_textFrames == nil) {
        _textFrames = [[NSMutableArray alloc] init];
    }
    return _textFrames;
}

- (UILabel *)newLabelAtIndex:(NSInteger)index {
    UILabel *label = nil;
    if (index >= self.textArray.count) {
        index = 0;
    }
    if (index >= 0 && index < self.textArray.count) {
        label = [[UILabel alloc] initWithFrame:self.bounds];
        label.font = self.font;
        label.shadowColor = self.shadowColor;
        label.shadowOffset = self.shadowOffset;
        label.textAlignment = self.textAlignment;
        label.textColor = self.textColor;
        [self setLabel:label atIndex:index];
        [self.scrollView addSubview:label];
    }
    return label;
}

- (void)setLabel:(UILabel *)label atIndex:(NSInteger)index {
    if (index >= self.textArray.count) {
        index = 0;
    }
    if (index >= 0 && index < self.textArray.count) {
        label.tag = index;
        label.text = self.textArray[index];
    }
}

- (NSArray *)allTexts {
    return [self.textArray copy];
}

- (void)addTexts:(NSArray *)texts {
    if (texts.count > 0) {
        [self.textArray addObjectsFromArray:texts];
        //
        [self layoutLabels];
        [self scrollLabels];
    }
}

- (void)removeAllTexts {
    [self.textArray removeAllObjects];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //
    [self layoutLabels];
    [self scrollLabels];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    //
    [self layoutLabels];
    [self scrollLabels];
}

- (void)layoutLabels {
    self.scrollView.frame = self.bounds;
    [self.textFrames removeAllObjects];
    //
    CGFloat offset = self.bounds.size.width;
    for (NSString *text in self.textArray) {
        self.text = text;
        CGRect rect = self.bounds;
        rect.origin.x = offset;
        rect.size.width = FLT_MAX;
        rect.size.width = [self sizeThatFits:rect.size].width;
        rect.size.width = ceilf(rect.size.width / self.bounds.size.width) * self.bounds.size.width;
        [self.textFrames addObject:@(rect)];
        offset += rect.size.width;
    }
    //
    self.text = nil;
}

- (void)scrollLabels {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollLabels) object:nil];
    [self.scrollView.layer removeAllAnimations];
    //
    if (self.currentLabel == nil) {
        self.currentLabel = [self newLabelAtIndex:0];
        self.nextLabel = [self newLabelAtIndex:1];
        self.currentLabel.frame = [self.textFrames[self.currentLabel.tag] CGRectValue];
        self.nextLabel.frame = [self.textFrames[self.nextLabel.tag] CGRectValue];
    } else {
        self.prevLabel = self.currentLabel;
        self.currentLabel = self.nextLabel;
        self.nextLabel = self.prevLabel;
        self.prevLabel = nil;
        [self setLabel:self.nextLabel atIndex:self.currentLabel.tag + 1];
        self.nextLabel.frame = [self.textFrames[self.nextLabel.tag] CGRectValue];
    }
    if (self.nextLabel.frame.origin.x <= self.currentLabel.frame.origin.x) {
        CGRect frame = self.nextLabel.frame;
        frame.origin.x = self.currentLabel.frame.origin.x + self.currentLabel.frame.size.width;
        self.nextLabel.frame = frame;
    }
    //
    if (self.currentLabel) {
        CGPoint to = CGPointMake(self.currentLabel.frame.origin.x, 0);
        CGPoint end = CGPointMake(self.nextLabel.frame.origin.x, 0);
        CGFloat speed = _scrollSpeed > 0.f ? _scrollSpeed : 30.f;
        NSTimeInterval duration = self.currentLabel.frame.size.width / speed;
        NSTimeInterval delay = self.haltTime;
        //
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:self.bounds.size.width / speed delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            weakSelf.scrollView.contentOffset = to;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
                    weakSelf.scrollView.contentOffset = end;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self performSelector:@selector(scrollLabels) withObject:nil];
                    }
                }];
            }
        }];
    }
}

@end
