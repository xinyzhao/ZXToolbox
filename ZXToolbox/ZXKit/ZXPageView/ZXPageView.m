//
// ZXPageView.m
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

#import "ZXPageView.h"
#import "ZXTimer.h"

@interface ZXPageView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *pageViews;
@property (nonatomic, strong) NSCache *pageCache;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) ZXTargetTimer *timer;

@end

@implementation ZXPageView

#pragma mark Initialization

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
    self.direction = ZXPageViewDirectionHorizontal;
    self.pagingMode = ZXPagingModeEndless;
    self.pageScaleFactor = CGPointMake(1.f, 1.f);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = YES;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self addSubview:self.scrollView];
    
    self.pageViews = [[NSMutableDictionary alloc] init];
    self.pageCache = [[NSCache alloc] init];
}

- (void)dealloc {
    [self stopPaging];
    NSLog(@"%s", __func__);
}

#pragma mark Setter

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:YES];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    CGPoint offset = [self contentOffsetForPage:currentPage];
    [self.scrollView setContentOffset:offset animated:animated];
    [self layoutPageView];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self setNeedsLayout];
}

- (void)setDirection:(ZXPageViewDirection)direction {
    _direction = direction;
    [self setNeedsLayout];
}

- (void)setPagingMode:(ZXPagingMode)pagingMode {
    _pagingMode = pagingMode;
    [self setNeedsLayout];
}

#pragma mark Getter

- (NSInteger)contentPage {
    NSInteger page = 0;
    if (_direction == ZXPageViewDirectionHorizontal) {
        CGFloat x = self.scrollView.contentOffset.x + self.bounds.size.width / 2;
        page = floorf(x / self.scaleBounds.size.width);
    } else {
        CGFloat y = self.scrollView.contentOffset.y + self.bounds.size.height / 2;
        page = floorf(y / self.scaleBounds.size.height);
    }
    return page;
}

- (NSInteger)correctPage:(NSInteger)page {
    if (_numberOfPages > 0) {
        if (page < 0) {
            page = ABS(page) % _numberOfPages;
            if (page != 0) {
                page = _numberOfPages - page;
            }
        } else if (page >= _numberOfPages) {
            page = page % _numberOfPages;
        }
    }
    return page;
}

- (NSInteger)correctIndex:(NSInteger)index {
    switch (_numberOfPages) {
        case 1:
        {
            static int indexes[3] = {0, 1, -1};
            if (index < 0) {
                index = -indexes[ABS(index) % 3];
            } else {
                index = indexes[ABS(index) % 3];
            }
            break;
        }
        case 2:
        {
            static int indexes[4] = {0, 1, 2, -1};
            if (index < 0) {
                index = -indexes[ABS(index) % 4];
            } else {
                index = indexes[ABS(index) % 4];
            }
            break;
        }
        default:
            index = [self correctPage:index];
            break;
    }
    return index;
}

- (NSInteger)currentPage {
    return [self correctPage:self.currentIndex];
}

#pragma mark Layout

/**
 CGFLOAT_MAX/FLT_MAX/MAXFLOAT
 CGFLOAT_MAX 在 iOS 10.3 中指向 DBL_MAX，会导致NaN错误
 */
- (void)resetEdgeInset {
    if (_direction == ZXPageViewDirectionHorizontal) {
        CGFloat width = self.scaleBounds.size.width;
        if (_pagingMode == ZXPagingModeEndless) {
            width *= floorf(FLT_MAX / width);
            self.scrollView.contentInset = UIEdgeInsetsMake(0, width, 0, width);
        } else if (_pagingMode == ZXPagingModeForward) {
            width *= _numberOfPages;
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, width);
//        } else if (_pagingMode == ZXPagingModeReverse) {
//            width *= _numberOfPages;
//            self.scrollView.contentInset = UIEdgeInsetsMake(0, width, 0, 0);
        }
    } else if (_direction == ZXPageViewDirectionVertical) {
        CGFloat height = self.scaleBounds.size.height;
        if (_pagingMode == ZXPagingModeEndless) {
            height *= floorf(FLT_MAX / height);
            self.scrollView.contentInset = UIEdgeInsetsMake(height, 0, height, 0);
        } else if (_pagingMode == ZXPagingModeForward) {
            height *= _numberOfPages;
            self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
//        } else if (_pagingMode == ZXPagingModeReverse) {
//            height *= _numberOfPages;
//            self.scrollView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    self.scrollView.frame = self.bounds;
    [self resetEdgeInset];
    [self layoutPageView];
}

- (void)layoutPageView {
    if (_numberOfPages > 0) {
        NSInteger contentPage = [self contentPage];
        [self setFrameForPage:contentPage];
        [self setFrameForPage:contentPage - 1];
        [self setFrameForPage:contentPage + 1];
    }
}

- (void)setFrameForPage:(NSInteger)page {
    if (_pagingMode == ZXPagingModeEndless || (page >= 0 && page < _numberOfPages)) {
        CGRect frame = self.scaleBounds;
        if (_direction == ZXPageViewDirectionHorizontal) {
            frame.origin.x = page * frame.size.width;
        } else {
            frame.origin.y = page * frame.size.height;
        }
        NSInteger index = [self correctIndex:page];
        UIView *view = [self subviewForPageAtIndex:index];
        if (!CGPointEqualToPoint(_pageScaleFactor, CGPointMake(1.f, 1.f))) {
            CGPoint scale = self.scrollView.contentOffset;
            scale.x += self.bounds.size.width / 2;
            scale.y += self.bounds.size.height / 2;
            scale.x -= frame.origin.x + frame.size.width / 2;
            scale.y -= frame.origin.y + frame.size.height / 2;
            scale.x /= self.bounds.size.width;
            scale.y /= self.bounds.size.height;
            scale.x = fabs(cos(scale.x * M_PI / 4));
            scale.y = fabs(cos(scale.y * M_PI / 4));
            //
            if (_direction == ZXPageViewDirectionHorizontal) {
                frame.size.height *= scale.x;
            } else {
                frame.size.width *= scale.y;
            }
            frame.origin.x += (self.scaleBounds.size.width - frame.size.width) / 2;
            frame.origin.y += (self.scaleBounds.size.height - frame.size.height) / 2;
        }
        //
        frame.origin.x += _pageInset.left;
        frame.origin.y += _pageInset.top;
        frame.size.width -= _pageInset.left + _pageInset.right;
        frame.size.height -= _pageInset.top + _pageInset.bottom;
        //
        view.frame = frame;
        //NSLog(@">>setPosition:%8 .2f\tforPage:% 2d\tatIndex:% 2d", (_direction ? frame.origin.y : frame.origin.x), (int)page, (int)index);
    }
}

- (CGRect)scaleBounds {
    CGRect rect = self.bounds;
    rect.size.width *= _pageScaleFactor.x;
    rect.size.height *= _pageScaleFactor.y;
    rect.origin.x = (self.bounds.size.width - rect.size.width) / 2;
    rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    return rect;
}

- (CGPoint)contentOffsetForPage:(NSInteger)page {
    CGPoint offset = CGPointZero;
    CGRect bounds = self.scaleBounds;
    if (_direction == ZXPageViewDirectionHorizontal) {
        offset.x = page * bounds.size.width - (self.bounds.size.width - bounds.size.width) / 2;
        if (_pagingMode == ZXPagingModeForward) {
            if (offset.x < 0) {
                offset.x = 0;
            }
        }
    } else {
        offset.y = page * bounds.size.height - (self.bounds.size.height - bounds.size.height) / 2;
        if (_pagingMode == ZXPagingModeForward) {
            if (offset.y < 0) {
                offset.y = 0;
            }
        }
    }
    return offset;
}

- (void)reloadData {
    for (UIView *view in [self.pageViews allValues]) {
        [view removeFromSuperview];
    }
    [self.pageViews removeAllObjects];
    [self.pageCache removeAllObjects];
    [self setCurrentPage:0 animated:NO];
}

#pragma mark Page View

- (UIView *)currentView {
    return [self subviewForPageAtIndex:self.currentIndex];
}

- (UIView *)subviewForPageAtIndex:(NSInteger)index {
    UIView *view = [self.pageViews objectForKey:@(index)];
    if (view == nil) {
        view = [self.pageCache objectForKey:@(index)];
        if (view) {
            [self.pageViews setObject:view forKey:@(index)];
            [self.pageCache removeObjectForKey:@(index)];
            [self.scrollView addSubview:view];
            //NSLog(@"%s %d", __func__, (int)index);
        }
    }
    if (view == nil) {
        NSInteger page = [self correctPage:index];
        if (self.subviewForPageAtIndex) {
            view = self.subviewForPageAtIndex(page);
        } else if ([self.delegate respondsToSelector:@selector(pageView:subviewForPageAtIndex:)]) {
            view = [self.delegate pageView:self subviewForPageAtIndex:page];
        }
        if (view) {
            [self.pageViews setObject:view forKey:@(index)];
            [self.scrollView addSubview:view];
        }
    }
    return view;
}

- (NSArray *)keysForVisiblePages {
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSInteger index = [self contentPage];
    [keys addObject:@([self correctIndex:index - 1])];
    [keys addObject:@([self correctIndex:index + 1])];
    [keys addObject:@([self correctIndex:index])];
    return [keys copy];
}

- (void)removePageViews {
    NSArray *keys = [self keysForVisiblePages];
    NSMutableArray *allKeys = [self.pageViews.allKeys mutableCopy];
    [allKeys removeObjectsInArray:keys];
    for (id key in allKeys) {
        //NSLog(@"%s %d", __func__, [key intValue]);
        UIView *view = [self.pageViews objectForKey:key];
        [self.pageCache setObject:view forKey:key];
        [self.pageViews removeObjectForKey:key];
        [view removeFromSuperview];
    }
}

#pragma mark Auto paging

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    self.pagingInterval = timeInterval;
}

- (NSTimeInterval)timeInterval {
    return self.pagingInterval;
}

- (void)setPagingInterval:(NSTimeInterval)pagingInterval {
    _pagingInterval = pagingInterval;
    [self startPaging];
}

- (void)startPaging {
    [self stopPaging];
    if (_pagingInterval >= 0.01 && _timer == nil) {
        _timer = [ZXTargetTimer scheduledTimerWithTimeInterval:_pagingInterval target:self selector:@selector(pagingTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopPaging {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)pagingTimer:(NSTimer *)timer {
    if (_numberOfPages > 0) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] - _timestamp;
        if (time > _pagingInterval) {
            if (!self.scrollView.isTracking && !self.scrollView.isDragging && !self.scrollView.isDecelerating) {
                self.currentPage = [self contentPage] + 1;
            }
        }
    }
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_numberOfPages > 0) {
        NSInteger page = [self contentPage];
        NSInteger index = [self correctIndex:page];
        if (_currentIndex != index) {
            _currentIndex = index;
            [self layoutPageView];
            //
            page = [self correctPage:index];
            if (self.willDisplaySubviewForPageAtIndex) {
                self.willDisplaySubviewForPageAtIndex(page);
            } else if ([self.delegate respondsToSelector:@selector(pageView:willDisplaySubview:forPageAtIndex:)]) {
                [self.delegate pageView:self willDisplaySubview:self.currentView forPageAtIndex:page];
            }
            //
            [self removePageViews];
            //
            _timestamp = [[NSDate date] timeIntervalSince1970];
        } else if (!CGPointEqualToPoint(_pageScaleFactor, CGPointMake(1.f, 1.f))) {
            [self layoutPageView];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.scrollView) {
        NSInteger page = [self contentPage];
        if (self.direction == ZXPageViewDirectionHorizontal) {
            if (velocity.x > 0.f) {
                page++;
            } else if (velocity.x < 0.f) {
                page--;
            }
        } else {
            if (velocity.y > 0.f) {
                page++;
            } else if (velocity.y < 0.f) {
                page--;
            }
        }
        CGPoint offset = [self contentOffsetForPage:page];
        targetContentOffset->x = offset.x;
        targetContentOffset->y = offset.y;
    }
}

@end
