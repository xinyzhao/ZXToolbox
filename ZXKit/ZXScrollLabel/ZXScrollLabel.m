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
@property (nonatomic, strong) NSMutableArray *textRects;
@property (nonatomic, strong) UILabel *currentLabel;
@property (nonatomic, strong) UILabel *nextLabel;
@property (nonatomic, strong) UILabel *prevLabel;

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL isResetting;

@end

@implementation ZXScrollLabel

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObservers];
    }
    return self;
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

- (void)dealloc {
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

- (NSMutableArray *)textArray {
    if (_textArray == nil) {
        _textArray = [[NSMutableArray alloc] init];
    }
    return _textArray;
}

- (NSMutableArray *)textRects {
    if (_textRects == nil) {
        _textRects = [[NSMutableArray alloc] init];
    }
    return _textRects;
}

- (NSTimeInterval)haltTime {
    if (_haltTime < 0.01f) {
        return 0.f;
    }
    return _haltTime;
}

- (double)scrollSpeed {
    if (_scrollSpeed < 0.01f) {
        return 30.f;
    }
    return _scrollSpeed;
}

- (UILabel *)newLabelAtIndex:(NSInteger)index {
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
        label.shadowColor = self.shadowColor;
        label.shadowOffset = self.shadowOffset;
        label.textAlignment = self.textAlignment;
        label.textColor = self.textColor;
        [self setTextForLabel:label atIndex:index];
        [self setFrameForLabel:label atIndex:index];
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
    } else {
        label.text = 0;
    }
}

- (void)setFrameForLabel:(UILabel *)label atIndex:(NSInteger)index {
    if (index < 0) {
        index = self.textRects.count + index;
    }
    if (index >= self.textRects.count) {
        index = 0;
    }
    if (index >= 0 && index < self.textRects.count) {
        label.frame = [self.textRects[index] CGRectValue];
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
    [self.scrollView.layer removeAllAnimations];
    [self removeLabels];
}

- (void)removeLabels {
    self.scrollView.contentOffset = CGPointZero;
    [self.currentLabel removeFromSuperview];
    [self.nextLabel removeFromSuperview];
    self.currentLabel = nil;
    self.nextLabel = nil;
    self.prevLabel = nil;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    //
    [self resetLabels];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    //
    [self resetLabels];
}

- (void)resetLabels {
    [self layoutLabels];
    [self.scrollView.layer removeAllAnimations];
    self.isResetting = YES;
}

- (void)layoutLabels {
    self.scrollView.frame = self.bounds;
    [self.textRects removeAllObjects];
    //
    CGFloat offset = self.bounds.size.width;
    for (NSString *text in self.textArray) {
        self.text = text;
        CGRect rect = self.bounds;
        rect.origin.x = offset;
        rect.size.width = FLT_MAX;
        rect.size.width = [self sizeThatFits:rect.size].width;
        rect.size.width = ceilf(rect.size.width / self.bounds.size.width) * self.bounds.size.width;
        [self.textRects addObject:@(rect)];
        offset += rect.size.width;
    }
    //
    self.text = nil;
}

- (void)scrollLabels {
    //
    if (self.isResetting) {
        [self removeLabels];
        self.isResetting = NO;
    }
    //
    if (self.currentLabel == nil) {
        self.currentLabel = [self newLabelAtIndex:0];
        self.nextLabel = [self newLabelAtIndex:1];
    } else {
        self.prevLabel = self.currentLabel;
        self.currentLabel = self.nextLabel;
        self.nextLabel = self.prevLabel;
    }
    //
    if (self.currentLabel && !self.isScrolling) {
        self.isScrolling = YES;
        //
        CGPoint offset = CGPointMake(self.currentLabel.frame.origin.x, 0);
        NSTimeInterval duration = ABS(offset.x - self.prevLabel.frame.origin.x) / self.scrollSpeed;
        NSTimeInterval delay = self.haltTime;
        //
        __weak typeof(self) weakSelf = self;
        __weak typeof(self.scrollView) scrollView = self.scrollView;
        __weak typeof(self.currentLabel) currentLabel = self.currentLabel;
        __weak typeof(self.nextLabel) nextLabel = self.nextLabel;
        [UIView animateWithDuration:duration delay:0.01 options:UIViewAnimationOptionCurveLinear animations:^{
            scrollView.contentOffset = offset;
        } completion:^(BOOL finished) {
            if (!finished) {
                [weakSelf setFrameForLabel:currentLabel atIndex:currentLabel.tag];
                [scrollView setContentOffset:CGPointMake(currentLabel.frame.origin.x, 0)];
            }
            [weakSelf setTextForLabel:nextLabel atIndex:currentLabel.tag + 1];
            [weakSelf setFrameForLabel:nextLabel atIndex:nextLabel.tag];
            if (nextLabel.frame.origin.x <= currentLabel.frame.origin.x) {
                CGRect frame = nextLabel.frame;
                frame.origin.x = currentLabel.frame.origin.x + currentLabel.frame.size.width;
                nextLabel.frame = frame;
            }
            weakSelf.isScrolling = NO;
            [weakSelf performSelector:_cmd withObject:weakSelf afterDelay:finished ? MIN(delay, duration) : MAX(delay, 0.3)];
        }];
    }
}

@end
