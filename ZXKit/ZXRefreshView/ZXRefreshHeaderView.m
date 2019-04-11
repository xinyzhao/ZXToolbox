//
// ZXRefreshHeaderView.m
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

#import "ZXRefreshHeaderView.h"
#import <objc/runtime.h>

@interface ZXRefreshHeaderView ()
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets parentInset;
@property (nonatomic, assign) ZXRefreshState refreshState;
@property (nonatomic, assign) CGFloat pullingProgress;
@property (nonatomic, copy) ZXRefreshingBlock refreshingBlock;

@end

@implementation ZXRefreshHeaderView

+ (instancetype)headerWithRefreshingBlock:(void(^)(void))refreshingBlock {
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
    ZXRefreshHeaderView *headerView = [[[self class] alloc] initWithFrame:frame];
    headerView.refreshingBlock = refreshingBlock;
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentHeight = 40;
        self.contentInset = 0;
        self.contentOffset = 0;
        self.refreshState = ZXRefreshStateIdle;
        self.pullingProgress = 0.0;
    }
    return self;
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark Functions

- (BOOL)attachToView:(UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView *)view;
        self.scrollView.alwaysBounceVertical = YES;
        self.parentInset = self.scrollView.contentInset;
        [self.scrollView addSubview:self];
        return YES;
    }
    return NO;
}

- (BOOL)detach {
    if (self.scrollView) {
        self.scrollView = nil;
        self.parentInset = UIEdgeInsetsZero;
        [self removeFromSuperview];
        return YES;
    }
    return NO;
}

#pragma mark Getter & Setter

- (void)setContentHeight:(CGFloat)contentHeight {
    _contentHeight = contentHeight;
    [self updateContentSize];
}

- (void)setContentInset:(CGFloat)contentInset {
    _contentInset = contentInset;
    [self updateContentSize];
}

- (void)setRefreshState:(ZXRefreshState)refreshState {
    if (_refreshState != refreshState) {
        _refreshState = refreshState;
    }
}

- (void)setPullingProgress:(CGFloat)pullingProgress {
    if (pullingProgress < 0.0) {
        pullingProgress = 0.0;
    } else if (pullingProgress > 1.0) {
        pullingProgress = 1.0;
    }
    //
    if (ABS(_pullingProgress - pullingProgress) > 0.01) {
        _pullingProgress = pullingProgress;
    }
}

- (void)updateContentSize {
    CGRect frame = self.frame;
    frame.origin.y = -_contentHeight + _contentInset;
    frame.size.height = _contentHeight;
    self.frame = frame;
}

#pragma mark Overrides

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    //
    if (newSuperview) {
        [self removeObservers];
        [self addObservers];
    } else {
        [self removeObservers];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGRect frame = self.frame;
    frame.size.width = self.superview.bounds.size.width;
    self.frame = frame;
}

#pragma mark Refreshing

- (BOOL)beginRefreshing {
    if (self.refreshState == ZXRefreshStateIdle || self.refreshState == ZXRefreshStateWillRefreshing) {
        self.refreshState = ZXRefreshStateRefreshing;
        //
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top += self.frame.size.height;
        CGPoint offset = CGPointMake(0, -inset.top);
        [UIView animateWithDuration:.25 animations:^{
            self->_scrollView.contentInset = inset;
            self->_scrollView.contentOffset = offset;
        } completion:^(BOOL finished) {
            if (self->_refreshingBlock) {
                self->_refreshingBlock();
            }
        }];
        //
        return YES;
    }
    return NO;
}

- (BOOL)endRefreshing {
    if (self.refreshState == ZXRefreshStateRefreshing) {
        self.refreshState = ZXRefreshStateIdle;
        //
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top -= self.frame.size.height;
        [UIView animateWithDuration:.25 animations:^{
            self->_scrollView.contentInset = inset;
        }];
        //
        return YES;
    }
    return NO;
}

- (BOOL)isRefreshing {
    return self.refreshState == ZXRefreshStateRefreshing;
}

#pragma mark NSKeyValueObserving

- (void)addObservers {
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}

- (void)removeObservers {
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.parentInset = self.scrollView.contentInset;
        [self scrollViewDidScroll:self.scrollView];
    }
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = self.scrollView.contentOffset.y + self.contentOffset;
    CGFloat insetTop = -self.parentInset.top;
    CGFloat height = self.frame.size.height;
    CGFloat progress = (insetTop - offsetY) / height;
    if (self.refreshState != ZXRefreshStateRefreshing) {
        if (self.scrollView.isDragging) {
            self.pullingProgress = progress;
            if (offsetY < insetTop) {
                if (offsetY > insetTop - height) {
                    self.refreshState = ZXRefreshStatePulling;
                } else {
                    self.refreshState = ZXRefreshStateWillRefreshing;
                }
            } else {
                self.refreshState = ZXRefreshStateIdle;
            }
        } else if (self.refreshState == ZXRefreshStateWillRefreshing) {
            [self beginRefreshing];
        } else {
            self.refreshState = ZXRefreshStateIdle;
        }
    }
    //NSLog(@"%d %d", (int)self.refreshState, (int)(self.pullingProgress * 100));
}

@end

@implementation UIView (ZXRefreshHeaderView)

- (ZXRefreshHeaderView *)refreshHeaderView {
    return objc_getAssociatedObject(self, @selector(refreshHeaderView));
}

- (void)setRefreshHeaderView:(ZXRefreshHeaderView *)refreshHeaderView {
    [self.refreshHeaderView detach];
    //
    if (refreshHeaderView) {
        [refreshHeaderView attachToView:self];
    }
    //
    objc_setAssociatedObject(self, @selector(refreshHeaderView), refreshHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
