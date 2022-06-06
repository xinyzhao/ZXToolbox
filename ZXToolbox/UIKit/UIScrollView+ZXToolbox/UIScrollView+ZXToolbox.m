//
// UIScrollView+ZXToolbox.m
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

#import "UIScrollView+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"
#import "ZXKeyValueObserver.h"

#define ZXToolboxSubclass @"_ZXToolbox_Subclass"

static char isScrollFreezedKey;
static char freezedViewsKey;
static char shouldRecognizeSimultaneouslyKey;

@implementation UIScrollView (ZXToolbox)

#pragma mark isScrollFreezed

- (void)setIsScrollFreezed:(BOOL)isScrollFreezed {
    id value = [NSNumber numberWithBool:isScrollFreezed];
    [self setAssociatedObject:&isScrollFreezedKey value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    //
    if (isScrollFreezed) {
        for (UIScrollView *view in self.freezedViews.objectEnumerator) {
            view.isScrollFreezed = NO;
        }
    }
}

- (BOOL)isScrollFreezed {
    NSNumber *value = [self getAssociatedObject:&isScrollFreezedKey];
    if (value) {
        return [value boolValue];
    }
    return NO;
}

- (void)setFreezedViews:(NSHashTable<UIScrollView *> * _Nonnull)freezedViews {
    [self setAssociatedObject:&freezedViewsKey value:freezedViews policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSHashTable<UIScrollView *> *)freezedViews {
    NSHashTable *obj = [self getAssociatedObject:&freezedViewsKey];
    if (obj == nil) {
        obj = [NSHashTable weakObjectsHashTable];
        [self setFreezedViews:obj];
    }
    return obj;
}

- (void)setShouldRecognizeSimultaneously:(BOOL)shouldRecognizeSimultaneously {
    Class clsA = [self class];
    NSString *strA = NSStringFromClass(clsA);
    if (![strA hasSuffix:ZXToolboxSubclass]) {
        NSString *strB = [strA stringByAppendingString:ZXToolboxSubclass];
        Class clsB = NSClassFromString(strB);
        if (clsB == nil) {
            clsB = objc_allocateClassPair(clsA, strB.UTF8String, 0);
            objc_registerClassPair(clsB);
            //
            [clsB swizzleMethod:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) with:@selector(zx_gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
        }
        object_setClass(self, clsB);
    }
    //
    NSNumber *value = [NSNumber numberWithBool:shouldRecognizeSimultaneously];
    [self setAssociatedObject:&shouldRecognizeSimultaneouslyKey value:value policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (BOOL)shouldRecognizeSimultaneously {
    NSNumber *number = [self getAssociatedObject:&shouldRecognizeSimultaneouslyKey];
    if (number) {
        return [number boolValue];
    }
    return NO;
}

#pragma mark UIGestureRecognizerDelegate
// 当一个手势识别器或其他手势识别器的识别被另一个手势识别器阻塞时调用
// 返回YES，允许两者同时识别。默认实现返回NO(默认情况下不能同时识别两个手势)
// 注意：返回YES保证允许同时识别。返回NO不能保证防止同时识别，因为其他手势的委托可能返回YES
- (BOOL)zx_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (self.shouldRecognizeSimultaneously) {
        return YES;
    }
    return [self zx_gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
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
