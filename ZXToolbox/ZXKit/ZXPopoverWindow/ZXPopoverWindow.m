//
// ZXPopoverWindow.m
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

#import "ZXPopoverWindow.h"

@interface ZXPopoverWindow () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect toFrame;
@property (nonatomic, assign) BOOL isPresented;

@end

@implementation ZXPopoverWindow

+ (instancetype)sharedWindow {
    static ZXPopoverWindow *window;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[ZXPopoverWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return window;
}

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

#pragma mark Present && Dismiss

- (void)presentView:(UIView *)view animated:(BOOL)flag completion:(void (^)(void))completion {
    CGRect from = self.frame;
    from.origin.y = self.frame.size.height;
    from.size.height = view.frame.size.height;
    //
    CGRect to = from;
    if (@available(iOS 11.0, *)) {
        to.origin.y = self.safeAreaLayoutGuide.layoutFrame.origin.y + self.safeAreaLayoutGuide.layoutFrame.size.height - view.frame.size.height;
    } else {
        to.origin.y = self.frame.size.height - view.frame.size.height;
    }
    //
    [self presentView:view from:from to:to animated:flag completion:completion];
}

- (void)presentView:(UIView *)view from:(CGRect)from to:(CGRect)to animated:(BOOL)animated completion:(void(^)(void))completion {
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
        if (animated) {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:_presentingDuration animations:^{
                weakSelf.backgroundColor = weakSelf.presentedBackgroundColor;
                weakSelf.presentedView.frame = self->_toFrame;
            } completion:^(BOOL finished) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(onTapBackground:)];
                tap.delegate = weakSelf;
                weakSelf.gestureRecognizers = @[tap];
                //
                if (completion) {
                    completion();
                }
            }];
        } else {
            self.backgroundColor = self.presentedBackgroundColor;
            self.presentedView.frame = _toFrame;
            //
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)];
            tap.delegate = self;
            self.gestureRecognizers = @[tap];
            //
            if (completion) {
                completion();
            }
        }
        
    }
}

- (void)dismissViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    _isPresented = NO;
    __weak typeof(self) weakSelf = self;
    if (animated) {
        [UIView animateWithDuration:_dismissingDuration animations:^{
            weakSelf.backgroundColor = [UIColor clearColor];
            weakSelf.presentedView.frame = self->_fromFrame;
        } completion:^(BOOL finished) {
            if (!self->_isPresented) {
                [weakSelf.presentedView removeFromSuperview];
                weakSelf.hidden = YES;
            }
            //
            if (completion) {
                completion();
            }
        }];
    } else {
        [self.presentedView removeFromSuperview];
        self.hidden = YES;
        //
        if (completion) {
            completion();
        }
    }
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
