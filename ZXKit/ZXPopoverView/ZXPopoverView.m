//
// ZXPopoverView.m
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

#import "ZXPopoverView.h"
#import <objc/runtime.h>

@interface ZXPopoverView () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGRect fromFrame;
@property (nonatomic, assign) CGRect toFrame;
@property (nonatomic, assign) BOOL isPresented;

@end

@implementation ZXPopoverView

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

@implementation UIView (ZXPopoverView)

- (ZXPopoverView *)popoverView {
    ZXPopoverView *popoverView = objc_getAssociatedObject(self, @selector(popoverView));
    if (popoverView == nil) {
        popoverView = [[ZXPopoverView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        objc_setAssociatedObject(self, @selector(popoverView), popoverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return popoverView;
}

- (void)presentView:(UIView *)view animated:(BOOL)flag completion:(void (^)(void))completion {
    self.popoverView.frame = self.bounds;
    //
    CGRect from = self.popoverView.frame;
    from.origin.y = self.popoverView.frame.size.height;
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
    if (self.popoverView.presentedView) {
        [self.popoverView.presentedView removeFromSuperview];
    }
    self.popoverView.presentingView = self;
    self.popoverView.presentedView = view;
    self.popoverView.fromFrame = from;
    self.popoverView.toFrame = to;
    //
    if (self.popoverView.presentedView) {
        self.popoverView.frame = self.bounds;
        self.popoverView.isPresented = YES;
        [self.popoverView.presentedView setFrame:self.popoverView.fromFrame];
        [self.popoverView setBackgroundColor:[UIColor clearColor]];
        [self.popoverView addSubview:self.popoverView.presentedView];
        [self addSubview:self.popoverView];
        //
        if (animated) {
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:self.popoverView.presentingDuration animations:^{
                weakSelf.popoverView.backgroundColor = weakSelf.popoverView.presentedBackgroundColor;
                weakSelf.popoverView.presentedView.frame = weakSelf.popoverView.toFrame;
            } completion:^(BOOL finished) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf.popoverView action:@selector(onTapBackground:)];
                tap.delegate = weakSelf.popoverView;
                weakSelf.popoverView.gestureRecognizers = @[tap];
                //
                if (completion) {
                    completion();
                }
            }];
        } else {
            self.popoverView.backgroundColor = self.popoverView.presentedBackgroundColor;
            self.popoverView.presentedView.frame = self.popoverView.toFrame;
            //
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.popoverView action:@selector(onTapBackground:)];
            tap.delegate = self.popoverView;
            self.popoverView.gestureRecognizers = @[tap];
            //
            if (completion) {
                completion();
            }
        }
    }
}

- (void)dismissViewAnimated:(BOOL)animated completion:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    self.popoverView.isPresented = NO;
    if (animated) {
        [UIView animateWithDuration:self.popoverView.dismissingDuration animations:^{
            weakSelf.popoverView.backgroundColor = [UIColor clearColor];
            weakSelf.popoverView.presentedView.frame = weakSelf.popoverView.fromFrame;
        } completion:^(BOOL finished) {
            if (!weakSelf.popoverView.isPresented) {
                [weakSelf.popoverView.presentedView removeFromSuperview];
                [weakSelf.popoverView removeFromSuperview];
                weakSelf.popoverView.presentingView = nil;
            }
            //
            if (completion) {
                completion();
            }
        }];
    } else {
        [self.popoverView.presentedView removeFromSuperview];
        [self.popoverView removeFromSuperview];
        self.popoverView.presentingView = nil;
        //
        if (completion) {
            completion();
        }
    }
}

@end

