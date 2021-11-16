//
// UIScrollView+ZXToolbox.m
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019-2020 Zhao Xin
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

#import "UIScrollView+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"
#import "ZXKeyValueObserver.h"

@interface UIScrollView ()
@property (nonatomic, strong, nullable) ZXKeyValueObserver *scrollFreezedObserver;

@end

@implementation UIScrollView (ZXToolbox)

#pragma mark isScrollFreezed

- (void)setIsScrollFreezed:(BOOL)isScrollFreezed {
    const void *key = @selector(isScrollFreezed);
    id value = [NSNumber numberWithBool:isScrollFreezed];
    [self setAssociatedObject:key value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (BOOL)isScrollFreezed {
    const void *key = @selector(isScrollFreezed);
    NSNumber *value = [self getAssociatedObject:key];
    if (value) {
        return [value boolValue];
    }
    return NO;
}

- (void)setFreezedContentOffset:(CGPoint)offset {
    const void *key = @selector(freezedContentOffset);
    id value = [NSValue valueWithCGPoint:offset];
    [self setAssociatedObject:key value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (CGPoint)freezedContentOffset {
    const void *key = @selector(freezedContentOffset);
    NSValue *value = [self getAssociatedObject:key];
    if (value) {
        return value.CGPointValue;
    }
    return CGPointZero;
}

- (void)setFreezedChildView:(UIScrollView *)freezedChildView {
    const void *key = @selector(freezedChildView);
    [self setAssociatedObject:key value:freezedChildView policy:OBJC_ASSOCIATION_ASSIGN];
    [self addScrollFreezedObserver];
}

- (UIScrollView *)freezedChildView {
    const void *key = @selector(freezedChildView);
    return [self getAssociatedObject:key];
}

- (void)setFreezedSuperView:(UIScrollView *)freezedSuperView {
    const void *key = @selector(freezedSuperView);
    [self setAssociatedObject:key value:freezedSuperView policy:OBJC_ASSOCIATION_ASSIGN];
    [self addScrollFreezedObserver];
}

- (UIScrollView *)freezedSuperView {
    const void *key = @selector(freezedSuperView);
    return [self getAssociatedObject:key];
}

#pragma mark UIGestureRecognizerDelegate
// 当一个手势识别器或其他手势识别器的识别被另一个手势识别器阻塞时调用
// 返回YES，允许两者同时识别。默认实现返回NO(默认情况下不能同时识别两个手势)
// 注意：返回YES保证允许同时识别。返回NO不能保证防止同时识别，因为其他手势的委托可能返回YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.freezedChildView) {
        return YES;
    }
    return NO;
}

#pragma mark Freezed Observer

- (void)addScrollFreezedObserver {
    if (self.freezedChildView == nil && self.freezedSuperView == nil) {
        [self removeScrollFreezedObserver];
        return;
    }
    ZXKeyValueObserver *observer = self.scrollFreezedObserver;
    if (observer == nil) {
        observer = [[ZXKeyValueObserver alloc] init];
        [observer observe:self keyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL changeHandler:^(NSDictionary<NSKeyValueChangeKey,id> * _Nullable change, void * _Nullable context) {
            CGPoint oldPoint = [change[NSKeyValueChangeOldKey] CGPointValue];
            CGPoint newPoint = [change[NSKeyValueChangeNewKey] CGPointValue];
            CGFloat x = ABS(newPoint.x - oldPoint.x);
            CGFloat y = ABS(newPoint.y - oldPoint.y);
            BOOL isHorizontal = x >= y;
            BOOL isVertical = x <= y;
            if (x == 0 && y == 0) {
                return;
            }
            //
            CGPoint contentOffset = newPoint;
            CGPoint freezedOffset = self.freezedContentOffset;
            BOOL isScrollFreezed = self.isScrollFreezed;
            //
            if (self.freezedChildView) {
                if (isScrollFreezed) {
                    self.contentOffset = freezedOffset;
                } else {
                    if ((isHorizontal && (contentOffset.x >= freezedOffset.x)) ||
                        (isVertical && (contentOffset.y >= freezedOffset.y))) {
                        self.contentOffset = freezedOffset;
                        self.isScrollFreezed = YES;
                        self.freezedChildView.isScrollFreezed = NO;
                    }
                }
            } else if (self.freezedSuperView) {
                if (isScrollFreezed) {
                    self.contentOffset = freezedOffset;
                } else {
                    if ((isHorizontal && (contentOffset.x <= freezedOffset.x)) ||
                        (isVertical && (contentOffset.y <= freezedOffset.y))) {
                        self.isScrollFreezed = YES;
                        self.freezedSuperView.isScrollFreezed = NO;
                    }
                }
            }
        }];
        self.scrollFreezedObserver = observer;
    }
}

- (void)removeScrollFreezedObserver {
    [self.scrollFreezedObserver invalidate];
    self.scrollFreezedObserver = nil;
}

- (void)setScrollFreezedObserver:(ZXKeyValueObserver *)observer {
    const void *key = @selector(scrollFreezedObserver);
    [self setAssociatedObject:key value:observer policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (ZXKeyValueObserver *)scrollFreezedObserver {
    const void *key = @selector(scrollFreezedObserver);
    return [self getAssociatedObject:key];
}

- (void)dealloc {
    [self removeScrollFreezedObserver];
}

#pragma mark Scroll to position

- (void)scrollToTop:(BOOL)animated {
    if ([self isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self;
        __weak typeof(tableView) weakSelf = tableView;
        dispatch_async(dispatch_get_main_queue(),^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [weakSelf scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
            if (weakSelf.tableHeaderView || weakSelf.contentInset.top > 0) {
                [weakSelf setContentOffset:CGPointZero animated:animated];
            }
        });
    } else if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        __weak typeof(collectionView) weakSelf = collectionView;
        dispatch_async(dispatch_get_main_queue(),^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            [weakSelf scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
            if (weakSelf.contentInset.top > 0) {
                [weakSelf setContentOffset:CGPointZero animated:animated];
            }
        });
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(),^{
            [weakSelf setContentOffset:CGPointZero animated:animated];
        });
    }
}

- (void)scrollToBottom:(BOOL)animated {
    [self layoutIfNeeded];
    //
    if ([self isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self;
        __weak typeof(tableView) weakSelf = tableView;
        dispatch_async(dispatch_get_main_queue(),^{
            NSInteger section = [weakSelf numberOfSections] - 1;
            NSInteger row = [weakSelf numberOfRowsInSection:section] - 1;
            if (section >= 0 && section != NSNotFound && row >= 0 && row != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [weakSelf scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
            if (weakSelf.tableFooterView || weakSelf.contentInset.bottom > 0) {
                CGFloat y = weakSelf.contentSize.height - weakSelf.bounds.size.height;
                if (y > 0.f) {
                    [weakSelf setContentOffset:CGPointMake(0, y) animated:animated];
                }
            }
        });
    } else if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        __weak typeof(collectionView) weakSelf = collectionView;
        dispatch_async(dispatch_get_main_queue(),^{
            NSInteger section = [weakSelf numberOfSections] - 1;
            NSInteger item = [weakSelf numberOfItemsInSection:section] - 1;
            if (section >= 0 && section != NSNotFound && item >= 0 && item != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                [weakSelf scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:animated];
            }
            if (weakSelf.contentInset.bottom > 0) {
                CGFloat y = weakSelf.contentSize.height - weakSelf.bounds.size.height;
                if (y > 0.f) {
                    [weakSelf setContentOffset:CGPointMake(0, y) animated:animated];
                }
            }
        });
    } else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(),^{
            CGFloat y = weakSelf.contentSize.height - weakSelf.bounds.size.height;
            if (y > 0.f) {
                [weakSelf setContentOffset:CGPointMake(0, y) animated:animated];
            }
        });
    }
}

@end
