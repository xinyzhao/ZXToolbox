//
// ZXPopoverWindow.m
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

#import "ZXPopoverWindow.h"

@interface ZXPopoverWindow () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect toFrame;
@property (nonatomic, assign) BOOL isPresented;

@end

@implementation ZXPopoverWindow

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.presentedBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
        self.presentingDuration = .3;
        self.dismissingDuration = .2;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.presentedBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4];
        self.presentingDuration = .3;
        self.dismissingDuration = .2;
    }
    return self;
}

- (void)presentView:(UIView *)view {
    CGRect from = self.frame;
    from.origin.y = self.frame.size.height;
    from.size.height = view.frame.size.height;
    //
    CGRect to = from;
    to.origin.y = self.frame.size.height - view.frame.size.height;
    //
    [self presentView:view from:from to:to];
}

- (void)presentView:(UIView *)view from:(CGRect)from to:(CGRect)to {
    if (_presentedView) {
        [_presentedView removeFromSuperview];
    }
    _presentedView = view;
    _fromFrame = from;
    _toFrame = to;
    //
    if (_presentedView) {
        _isPresented = YES;
        [_presentedView setFrame:_fromFrame];
        [self addSubview:_presentedView];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setHidden:NO];
        //
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:_presentingDuration animations:^{
            weakSelf.backgroundColor = weakSelf.presentedBackgroundColor;
            weakSelf.presentedView.frame = self->_toFrame;
        } completion:^(BOOL finished) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(onTapBackground:)];
            tap.delegate = weakSelf;
            [weakSelf addGestureRecognizer:tap];
        }];
    }
}

- (void)dismiss {
    _isPresented = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_dismissingDuration animations:^{
        weakSelf.backgroundColor = [UIColor clearColor];
        weakSelf.presentedView.frame = self->_fromFrame;
    } completion:^(BOOL finished) {
        if (!self->_isPresented) {
            [weakSelf.presentedView removeFromSuperview];
            weakSelf.hidden = YES;
        }
    }];
}

#pragma mark <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.presentedView];
    if (!CGRectContainsPoint(self.presentedView.bounds, point)) {
        return YES;
    }
    return NO;
}

- (void)onTapBackground:(id)sender {
    if (_touchedBackgroundBlock) {
        _touchedBackgroundBlock();
    }
}

@end
