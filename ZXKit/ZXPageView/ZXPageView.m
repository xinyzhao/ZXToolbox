//
// ZXPageView.m
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

#import "ZXPageView.h"

@interface ZXPageView () <NSCacheDelegate>
@property (nonatomic, strong) NSCache *pageViews;
@property (nonatomic, assign) NSTimeInterval timestamp;

- (void)initView;

- (void)resetEdgeInset;

- (NSInteger)contentPage;
- (NSInteger)correctPage:(NSInteger)page;
- (NSInteger)prevPage;
- (NSInteger)nextPage;

- (UIView *)currentView;
- (UIView *)subviewForPageAtIndex:(NSInteger)index;

- (void)autoPaging:(NSTimeInterval)delay;
- (void)nextPaging;
- (void)stopPaging;

@end

@implementation ZXPageView
@synthesize delegate = _delegate;

#pragma mark Initialization

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    self.direction = ZXPageViewDirectionHorizontal;
    self.orientation = ZXPageViewOrientationEndless;
    self.pageViews = [[NSCache alloc] init];
    self.pageViews.delegate = self;
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}

- (void)dealloc
{
    [self stopPaging];
}

#pragma mark Direction

- (void)setDirection:(ZXPageViewDirection)direction {
    _direction = direction;
    [self setNeedsLayout];
}

#pragma mark Orientation

- (void)setOrientation:(ZXPageViewOrientation)orientation {
    _orientation = orientation;
    [self setNeedsLayout];
}

#pragma mark Inset

/**
 CGFLOAT_MAX/FLT_MAX/MAXFLOAT
 CGFLOAT_MAX 在 iOS 10.3 中指向 DBL_MAX，会导致NaN错误
 */
- (void)resetEdgeInset {
    if (_numberOfPages > 1) {
        if (_direction == ZXPageViewDirectionHorizontal) {
            CGFloat width = self.frame.size.width;
            if (_orientation == ZXPageViewOrientationEndless) {
                width *= floorf(FLT_MAX / width);
                self.contentInset = UIEdgeInsetsMake(0, width, 0, width);
            } else if (_orientation == ZXPageViewOrientationForward) {
                width *= _numberOfPages;
                self.contentInset = UIEdgeInsetsMake(0, 0, 0, width);
//            } else if (_orientation == ZXPageViewOrientationReverse) {
//                width *= _numberOfPages;
//                self.contentInset = UIEdgeInsetsMake(0, width, 0, 0);
            }
        } else if (_direction == ZXPageViewDirectionVertical) {
            CGFloat height = self.frame.size.height;
            if (_orientation == ZXPageViewOrientationEndless) {
                height *= floorf(FLT_MAX / height);
                self.contentInset = UIEdgeInsetsMake(height, 0, height, 0);
            } else if (_orientation == ZXPageViewOrientationForward) {
                height *= _numberOfPages;
                self.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
//            } else if (_orientation == ZXPageViewOrientationReverse) {
//                height *= _numberOfPages;
//                self.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
            }
        }
    } else {
        self.contentInset = UIEdgeInsetsZero;
    }
}

#pragma mark Reload data

- (void)reloadData {
    [self.pageViews removeAllObjects];
    [self setNeedsLayout];
}

#pragma mark Page Setter

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:YES];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    CGPoint offset = CGPointZero;
    if (_direction == ZXPageViewDirectionHorizontal) {
        offset.x = currentPage * self.frame.size.width;
    } else {
        offset.y = currentPage * self.frame.size.height;
    }
    [self setContentOffset:offset animated:animated];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self setNeedsLayout];
}

#pragma mark Page Getter

- (NSInteger)contentPage {
    NSInteger page = 0;
    if (_direction == ZXPageViewDirectionHorizontal) {
        page = roundf(self.contentOffset.x / self.frame.size.width);
    } else {
        page = roundf(self.contentOffset.y / self.frame.size.height);
    }
    return page;
}

- (NSInteger)correctPage:(NSInteger)page {
    if (page < 0) {
        page = ABS(page) % _numberOfPages;
        if (page != 0) {
            page = _numberOfPages - page;
        }
    } else if (page >= _numberOfPages) {
        page = page % _numberOfPages;
    }
    return page;
}

- (NSInteger)prevPage {
    NSInteger prevPage = _currentPage - 1;
    if (prevPage < 0 && _numberOfPages > 2) {
        prevPage = [self correctPage:prevPage];
    }
    return prevPage;
}

- (NSInteger)nextPage {
    NSInteger nextPage = _currentPage + 1;
    if (nextPage >= _numberOfPages && _numberOfPages > 2) {
        nextPage = [self correctPage:nextPage];
    }
    return nextPage;
}

#pragma mark Page View

- (UIView *)currentView {
    return [self subviewForPageAtIndex:self.currentPage];
}

- (UIView *)subviewForPageAtIndex:(NSInteger)index {
    UIView *view = [self.pageViews objectForKey:@(index)];
    if (view == nil && (_orientation == ZXPageViewOrientationEndless || (index >= 0 && index < _numberOfPages))) {
        if ([_delegate respondsToSelector:@selector(pageView:subviewForPageAtIndex:)]) {
            if (index >= 0 && index < _numberOfPages) {
                view = [_delegate pageView:self subviewForPageAtIndex:index];
            } else {
                NSInteger pageIndex = [self correctPage:index];
                view = [_delegate pageView:self subviewForPageAtIndex:pageIndex];
            }
            if (view) {
                view.tag = index;
                [self.pageViews setObject:view forKey:@(index)];
                [self addSubview:view];
            }
        }
    }
    return view;
}

#pragma mark Auto paging

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    if (_timeInterval >= 0.1) {
        [self autoPaging:_timeInterval];
    } else {
        [self stopPaging];
    }
}

- (void)autoPaging:(NSTimeInterval)delay {
    if (_numberOfPages > 1 && delay > 0.01) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(nextPaging) withObject:nil afterDelay:delay];
    }
}

- (void)nextPaging {
    if (_numberOfPages > 1) {
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970] - _timestamp;
        if (time > _timeInterval) {
            if (!self.isTracking && !self.isDragging && !self.isDecelerating) {
                self.currentPage = self.contentPage + 1;
            }
        }
        [self autoPaging:_timeInterval];
    }
}

- (void)stopPaging {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    [self resetEdgeInset];
    //
    if (_numberOfPages > 0) {
        NSInteger currentPage = [self contentPage];
        //
        [self setFrame:currentPage forPageAtIndex:self.currentPage];
        //
        if (_numberOfPages > 1) {
            NSInteger prevPage = currentPage - 1;
            NSInteger nextPage = currentPage + 1;
            //
            [self setFrame:prevPage forPageAtIndex:self.prevPage];
            [self setFrame:nextPage forPageAtIndex:self.nextPage];
            //
            if (_numberOfPages == 2) {
                NSInteger index = _currentPage == 0 ? 2 : -1;
                NSInteger page = index < 0 ? prevPage - 1 : nextPage + 1;
                [self setFrame:page forPageAtIndex:index];
            }
            //
            _timestamp = [[NSDate date] timeIntervalSince1970];
        }
    }
}

- (void)setFrame:(NSInteger)page forPageAtIndex:(NSInteger)index {
    if (_orientation == ZXPageViewOrientationEndless || (page >= 0 && page < _numberOfPages)) {
        CGRect frame = self.frame;
        if (_direction == ZXPageViewDirectionHorizontal) {
            frame.origin = CGPointMake(page * self.frame.size.width, 0);
        } else {
            frame.origin = CGPointMake(0, page * self.frame.size.height);
        }
        UIView *view = [self subviewForPageAtIndex:index];
        view.frame = frame;
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    super.contentOffset = contentOffset;
    //
    if (_numberOfPages > 0) {
        NSInteger contentPage = [self contentPage];
        NSInteger correctPage = [self correctPage:contentPage];
        if (_currentPage != correctPage) {
            _currentPage = correctPage;
            //
            if ([_delegate respondsToSelector:@selector(pageView:willDisplaySubview:forPageAtIndex:)]) {
                [_delegate pageView:self willDisplaySubview:self.currentView forPageAtIndex:_currentPage];
            }
        }
    }
}

#pragma mark <NSCacheDelegate>

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    UIView *pageView = obj;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pageView.superview) {
            [pageView removeFromSuperview];
        }
    });
}

@end

