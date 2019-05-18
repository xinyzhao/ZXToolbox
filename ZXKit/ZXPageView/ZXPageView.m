//
// ZXPageView.m
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

#import "ZXPageView.h"
#import "NSObject+ZXToolbox.h"

@interface ZXPageView () <NSCacheDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSCache *pageViews;
@property (nonatomic, assign) NSTimeInterval timestamp;

@property (nonatomic, readonly) CGRect scales;

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

- (CGPoint)contentOffsetForPage:(NSInteger)page;

@end

@implementation ZXPageView
@dynamic delegate;

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
    self.clipsToBounds = YES;
    self.pagingEnabled = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.direction = ZXPageViewDirectionHorizontal;
    self.pagingMode = ZXPagingModeEndless;
    self.pageScaleFactor = CGPointMake(1.f, 1.f);
    self.pageViews = [[NSCache alloc] init];
    self.pageViews.countLimit = 3;
    self.pageViews.delegate = self;
}

- (void)dealloc {
    [self stopPaging];
}

#pragma mark Direction

- (void)setDirection:(ZXPageViewDirection)direction {
    _direction = direction;
    [self setNeedsLayout];
}

#pragma mark Paging mode

- (void)setPagingMode:(ZXPagingMode)pagingMode {
    _pagingMode = pagingMode;
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
            if (_pagingMode == ZXPagingModeEndless) {
                width *= floorf(FLT_MAX / width);
                self.contentInset = UIEdgeInsetsMake(0, width, 0, width);
            } else if (_pagingMode == ZXPagingModeForward) {
                width *= _numberOfPages;
                self.contentInset = UIEdgeInsetsMake(0, 0, 0, width);
//            } else if (_pagingMode == ZXPagingModeReverse) {
//                width *= _numberOfPages;
//                self.contentInset = UIEdgeInsetsMake(0, width, 0, 0);
            }
        } else if (_direction == ZXPageViewDirectionVertical) {
            CGFloat height = self.frame.size.height;
            if (_pagingMode == ZXPagingModeEndless) {
                height *= floorf(FLT_MAX / height);
                self.contentInset = UIEdgeInsetsMake(height, 0, height, 0);
            } else if (_pagingMode == ZXPagingModeForward) {
                height *= _numberOfPages;
                self.contentInset = UIEdgeInsetsMake(0, 0, height, 0);
//            } else if (_pagingMode == ZXPagingModeReverse) {
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
    [self layoutIfNeeded];
    [self setCurrentPage:_currentPage animated:NO];
}

#pragma mark Page Setter

- (void)setCurrentPage:(NSInteger)currentPage {
    [self setCurrentPage:currentPage animated:YES];
}

- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated {
    CGPoint offset = CGPointZero;
    if (_direction == ZXPageViewDirectionHorizontal) {
        offset.x = currentPage * self.scales.size.width - self.scales.origin.x;
    } else {
        offset.y = currentPage * self.scales.size.height - self.scales.origin.y;
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
        page = floorf((self.contentOffset.x + self.bounds.size.width / 2) / self.scales.size.width);
    } else {
        page = floorf((self.contentOffset.y + self.bounds.size.height / 2) / self.scales.size.height);
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
    if (view == nil && (_pagingMode == ZXPagingModeEndless || (index >= 0 && index < _numberOfPages))) {
        if ([self.delegate respondsToSelector:@selector(pageView:subviewForPageAtIndex:)]) {
            if (index >= 0 && index < _numberOfPages) {
                view = [self.delegate pageView:self subviewForPageAtIndex:index];
            } else {
                NSInteger pageIndex = [self correctPage:index];
                view = [self.delegate pageView:self subviewForPageAtIndex:pageIndex];
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

#pragma mark Scale

- (CGRect)scales {
    CGRect rect = self.bounds;
    rect.size.width *= _pageScaleFactor.x;
    rect.size.height *= _pageScaleFactor.y;
    rect.origin.x = (self.bounds.size.width - rect.size.width) / 2;
    rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    return rect;
}

#pragma mark Overrides

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(setDelegate:) with:@selector(setPageViewDelegate:)];
    });
}

- (void)setPageViewDelegate:(id<ZXPageViewDelegate>)delegate {
    [self setPageViewDelegate:delegate];
    //
    [self swizzleMethod:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:) with:@selector(pageViewWillEndDragging:withVelocity:targetContentOffset:) class:[delegate class]];
}

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
    if (_pagingMode == ZXPagingModeEndless || (page >= 0 && page < _numberOfPages)) {
        CGRect frame = self.scales;
        if (_direction == ZXPageViewDirectionHorizontal) {
            frame.origin.x = page * frame.size.width;
        } else {
            frame.origin.y = page * frame.size.height;
        }
        UIView *view = [self subviewForPageAtIndex:index];
        if (!CGPointEqualToPoint(_pageScaleFactor, CGPointMake(1.f, 1.f))) {
            CGPoint scale = self.contentOffset;
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
            frame.origin.x += (self.scales.size.width - frame.size.width) / 2;
            frame.origin.y += (self.scales.size.height - frame.size.height) / 2;
        }
        //
        frame.origin.x += _pageInset.left;
        frame.origin.y += _pageInset.top;
        frame.size.width -= _pageInset.left + _pageInset.right;
        frame.size.height -= _pageInset.top + _pageInset.bottom;
        //
        view.frame = frame;
    }
}

#pragma mark contentOffset

- (CGPoint)contentOffsetForPage:(NSInteger)page {
    CGPoint offset = CGPointZero;
    if (_direction == ZXPageViewDirectionHorizontal) {
        offset.x = page * self.scales.size.width - (self.bounds.size.width - self.scales.size.width) / 2;
    } else {
        offset.y = page * self.scales.size.height - (self.bounds.size.height - self.scales.size.height) / 2;
    }
    return offset;
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
            if ([self.delegate respondsToSelector:@selector(pageView:willDisplaySubview:forPageAtIndex:)]) {
                [self.delegate pageView:self willDisplaySubview:self.currentView forPageAtIndex:_currentPage];
            }
        }
    }
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([scrollView isKindOfClass:[ZXPageView class]]) {
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        ZXPageView *pageView = (ZXPageView *)scrollView;
        NSInteger page = [pageView contentPage];
        if (pageView.direction == ZXPageViewDirectionHorizontal) {
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
        CGPoint offset = [pageView contentOffsetForPage:page];
        targetContentOffset->x = offset.x;
        targetContentOffset->y = offset.y;
    }
}

- (void)pageViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([scrollView isKindOfClass:[ZXPageView class]]) {
        ZXPageView *pageView = (ZXPageView *)scrollView;
        [pageView scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
    [self pageViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}


#pragma mark <NSCacheDelegate>

- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSLog(@"cache:willEvictObject:%@", obj);
}

@end
