//
// ZXStackView.m
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

#import "ZXStackView.h"

@interface ZXStackView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *stackView;
@property (nonatomic, strong) NSMutableDictionary *stackViews;
@property (nonatomic, strong) NSCache *stackCache;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *currentView;

@end

@implementation ZXStackView

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
    self.stackView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.stackView];
    //
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self addSubview:self.scrollView];
    //
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    //
    self.alignment = ZXStackViewAlignmentLeading;
    self.numberOfStacks = 2;
    self.stackViews = [[NSMutableDictionary alloc] init];
    self.stackCache = [[NSCache alloc] init];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark Setter

- (void)setAlignment:(ZXStackViewAlignment)alignment {
    _alignment = alignment;
    //
    switch (_alignment) {
        case ZXStackViewAlignmentLeading:
        case ZXStackViewAlignmentTrailing:
            self.scrollView.contentInset = UIEdgeInsetsMake(0, FLT_MAX, 0, FLT_MAX);
            break;
        case ZXStackViewAlignmentTop:
        case ZXStackViewAlignmentBottom:
            self.scrollView.contentInset = UIEdgeInsetsMake(FLT_MAX, 0, FLT_MAX, 0);
            break;
    }
    [self setNeedsLayout];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    [self setCurrentIndex:currentIndex animated:YES];
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    NSInteger index = self.contentIndex + (currentIndex - _currentIndex);
    CGPoint offset = CGPointZero;
    switch (_alignment) {
        case ZXStackViewAlignmentLeading:
            offset = CGPointMake(index * self.bounds.size.width, 0);
            break;
        case ZXStackViewAlignmentTrailing:
            offset = CGPointMake(-index * self.bounds.size.width, 0);
            break;
        case ZXStackViewAlignmentTop:
            offset = CGPointMake(0, index * self.bounds.size.height);
            break;
        case ZXStackViewAlignmentBottom:
            offset = CGPointMake(0, -index * self.bounds.size.height);
            break;
    }
    [self.scrollView setContentOffset:offset animated:animated];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)setNumberOfStacks:(NSUInteger)numberOfStacks {
    if (numberOfStacks < 2) {
        _numberOfStacks = 2;
    } else {
        _numberOfStacks = numberOfStacks;
    }
    [self setNeedsLayout];
}

- (void)setNumberOfSubviews:(NSUInteger)numberOfSubviews {
    _numberOfSubviews = numberOfSubviews;
    if (_numberOfSubviews > 1) {
        self.alignment = _alignment;
    } else {
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)setScaleFactor:(CGFloat)scaleFactor {
    _scaleFactor = scaleFactor;
    [self setNeedsLayout];
}

- (void)setTailSpacing:(CGFloat)tailSpacing {
    _tailSpacing = tailSpacing;
    [self setNeedsLayout];
}

#pragma mark Getter

- (NSInteger)contentIndex {
    NSInteger index = 0;
    switch (_alignment) {
        case ZXStackViewAlignmentLeading:
        {
            CGFloat x = self.scrollView.contentOffset.x;
            index = floorf(x / self.bounds.size.width);
            break;
        }
        case ZXStackViewAlignmentTrailing:
        {
            CGFloat x = -self.scrollView.contentOffset.x;
            index = floorf(x / self.bounds.size.width);
            break;
        }
        case ZXStackViewAlignmentTop:
        {
            CGFloat y = self.scrollView.contentOffset.y;
            index = floorf(y / self.bounds.size.height);
            break;
        }
        case ZXStackViewAlignmentBottom:
        {
            CGFloat y = -self.scrollView.contentOffset.y;
            index = floorf(y / self.bounds.size.height);
            break;
        }
    }
    return index;
}

- (NSInteger)correctIndex:(NSInteger)index {
    if (_numberOfSubviews > 0) {
        if (index < 0) {
            index = ABS(index) % _numberOfSubviews;
            if (index != 0) {
                index = _numberOfSubviews - index;
            }
        } else if (index >= _numberOfSubviews) {
            index = index % _numberOfSubviews;
        }
    }
    return index;
}

#pragma mark Subviews

- (UIView *)subviewForIndex:(NSInteger)index {
    UIView *view = nil;
    index = [self correctIndex:index];
    if (index == self.currentIndex) {
        view = self.currentView;
    }
    if (view == nil) {
        view = [self.stackViews objectForKey:@(index)];
    }
    if (view == nil) {
        view = [self.stackCache objectForKey:@(index)];
    }
    if (view == nil) {
        if (_willDisplaySubview) {
            view = _willDisplaySubview(index);
            if (view) {
                if (index == _currentIndex) {
                    self.currentView = view;
                } else {
                    [self.stackViews setObject:view forKey:@(index)];
                }
            }
        }
    }
    return view;
}

- (CGRect)subviewFrameForIndex:(NSInteger)index {
    CGRect rect = self.bounds;
    switch (_alignment) {
        case ZXStackViewAlignmentLeading:
            rect.origin.x = rect.size.width * index;
            break;
        case ZXStackViewAlignmentTrailing:
            rect.origin.x = rect.size.width * (-index);
            break;
        case ZXStackViewAlignmentTop:
            rect.origin.y = rect.size.height * index;
            break;
        case ZXStackViewAlignmentBottom:
            rect.origin.y = rect.size.height * (-index);
            break;
    }
    rect.origin.x += self.contentInset.left;
    rect.origin.y += self.contentInset.top;
    rect.size.width -= self.contentInset.left + self.contentInset.right;
    rect.size.height -= self.contentInset.top + self.contentInset.bottom;
    return rect;
}

#pragma mark Load & Layout

- (void)reloadData {
    if (self.currentView) {
        [self.currentView removeFromSuperview];
        self.currentView = nil;
    }
    for (UIView *view in [self.stackViews allValues]) {
        [view removeFromSuperview];
    }
    [self.stackViews removeAllObjects];
    [self.stackCache removeAllObjects];
    //
    _currentIndex = 0;
    [self loadSubviews];
    [self setCurrentIndex:_currentIndex animated:NO];
}

- (void)loadSubviews {
    CGRect frame = [self subviewFrameForIndex:0];
    NSInteger count = MIN(_numberOfStacks, _numberOfSubviews);
    for (NSInteger i = 0; i < count; i++) {
        NSInteger index = [self correctIndex:_currentIndex + i];
        UIView *view = [self subviewForIndex:index];
        view.transform = CGAffineTransformIdentity;
        view.frame = frame;
        if (i == _currentIndex) {
            [self.scrollView addSubview:view];
        } else {
            [self.stackView insertSubview:view atIndex:0];
        }
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    self.stackView.frame = self.bounds;
    self.scrollView.frame = self.bounds;
    self.currentView.frame = [self subviewFrameForIndex:self.contentIndex];
    [self layoutSubviews:self.scrollView.contentOffset];
}

- (void)layoutSubviews:(CGPoint)offset {
    NSInteger count = MIN(_numberOfStacks, _numberOfSubviews);
    CGRect frame = [self subviewFrameForIndex:0];
    CGFloat scale = 0.f;
    CGFloat spacing = 0.f;
    //
    switch (_alignment) {
        case ZXStackViewAlignmentLeading:
        case ZXStackViewAlignmentTrailing:
            offset.x -= self.currentView.frame.origin.x - self.contentInset.left;
            break;
        case ZXStackViewAlignmentTop:
        case ZXStackViewAlignmentBottom:
            offset.y -= self.currentView.frame.origin.y - self.contentInset.top;
            break;
    }
    //
    for (NSInteger i = 1; i < count; i++) {
        UIView *view = [self subviewForIndex:_currentIndex + i];
        view.transform = CGAffineTransformIdentity;
        view.frame = frame;
        //
        switch (_alignment) {
            case ZXStackViewAlignmentLeading:
            {
                scale = (((self.bounds.size.width - offset.x) / self.bounds.size.width) + i - 1);
                view.transform = CGAffineTransformMakeScale(1 - _scaleFactor * scale, 1 - _scaleFactor * scale);
                spacing = (view.frame.origin.x - frame.origin.x + _tailSpacing * scale);
                view.transform = CGAffineTransformTranslate(view.transform, spacing / (1 - _scaleFactor * scale), 0);
                break;
            }
            case ZXStackViewAlignmentTrailing:
            {
                scale = (((self.bounds.size.width + offset.x) / self.bounds.size.width) + i - 1);
                view.transform = CGAffineTransformMakeScale(1 - _scaleFactor * scale, 1 - _scaleFactor * scale);
                spacing = (frame.origin.x - view.frame.origin.x - _tailSpacing * scale);
                view.transform = CGAffineTransformTranslate(view.transform, spacing / (1 - _scaleFactor * scale), 0);
                break;
            }
            case ZXStackViewAlignmentTop:
            {
                scale = (((self.bounds.size.height - offset.y) / self.bounds.size.height) + i - 1);
                view.transform = CGAffineTransformMakeScale(1 - _scaleFactor * scale, 1 - _scaleFactor * scale);
                spacing = (view.frame.origin.y - frame.origin.y + _tailSpacing * scale);
                view.transform = CGAffineTransformTranslate(view.transform, 0, spacing / (1 - _scaleFactor * scale));
                break;
            }
            case ZXStackViewAlignmentBottom:
            {
                scale = (((self.bounds.size.height + offset.y) / self.bounds.size.height) + i - 1);
                view.transform = CGAffineTransformMakeScale(1 - _scaleFactor * scale, 1 - _scaleFactor * scale);
                spacing = (frame.origin.y - view.frame.origin.y - _tailSpacing * scale);
                view.transform = CGAffineTransformTranslate(view.transform, 0, spacing / (1 - _scaleFactor * scale));
                break;
            }
        }
    }
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger contentIndex = [self contentIndex];
    NSInteger correctIndex = [self correctIndex:contentIndex];
    NSInteger count = MIN(_numberOfStacks, _numberOfSubviews);
    //
    if (count > 0 && _currentIndex != correctIndex) {
        BOOL isAhead = NO;
        switch (_alignment) {
            case ZXStackViewAlignmentLeading:
                isAhead = scrollView.contentOffset.x > self.currentView.frame.origin.x;
                break;
            case ZXStackViewAlignmentTrailing:
                isAhead = scrollView.contentOffset.x + scrollView.bounds.size.width < self.currentView.frame.origin.x;
                break;
            case ZXStackViewAlignmentTop:
                isAhead = scrollView.contentOffset.y > self.currentView.frame.origin.y;
                break;
            case ZXStackViewAlignmentBottom:
                isAhead = scrollView.contentOffset.y + scrollView.bounds.size.height < self.currentView.frame.origin.y;
                break;
        }
        if (isAhead) { // 正向移动
            // 把顶层视图从滚动视图上移除并加入到cache
            [self.currentView removeFromSuperview];
            [self.stackCache setObject:self.currentView forKey:@(_currentIndex)];
            // 移除堆叠视图的顶层并加入到滚动视图，成为顶层视图
            self.currentView = [self subviewForIndex:correctIndex];
            self.currentView.transform = CGAffineTransformIdentity;
            self.currentView.frame = [self subviewFrameForIndex:contentIndex];
            [self.stackViews removeObjectForKey:@(correctIndex)];
            [self.scrollView addSubview:self.currentView];
            _currentIndex = correctIndex;
            // 补充堆叠视图的底层
            contentIndex = _currentIndex + count - 1;
            correctIndex = [self correctIndex:contentIndex];
            UIView *view = [self subviewForIndex:correctIndex];
            [self.stackCache removeObjectForKey:@(correctIndex)];
            [self.stackViews setObject:view forKey:@(correctIndex)];
            [self.stackView insertSubview:view atIndex:0];
        } else { // 反向移动
            // 把顶层视图从滚动视图上移除并加入到堆叠视图顶层
            [self.currentView removeFromSuperview];
            [self.stackView addSubview:self.currentView];
            [self.stackViews setObject:self.currentView forKey:@(_currentIndex)];
            // 把最后1个视图加入到滚动视图，成为顶层视图
            self.currentView = [self subviewForIndex:correctIndex];
            self.currentView.transform = CGAffineTransformIdentity;
            self.currentView.frame = [self subviewFrameForIndex:contentIndex];
            [self.scrollView addSubview:self.currentView];
            [self.stackViews removeObjectForKey:@(correctIndex)];
            [self.stackCache removeObjectForKey:@(correctIndex)];
            _currentIndex = correctIndex;
            // 如果堆叠视图底层不是最后1个视图，移除并加入到cache
            contentIndex = _currentIndex + count;
            correctIndex = [self correctIndex:contentIndex];
            if (correctIndex != _currentIndex) {
                UIView *view = [self subviewForIndex:correctIndex];
                [self.stackViews removeObjectForKey:@(correctIndex)];
                [self.stackCache setObject:view forKey:@(correctIndex)];
                [view removeFromSuperview];
            }
        }
        if (_didDisplaySubview) {
            _didDisplaySubview(_currentIndex);
        }
    }
    //
    [self layoutSubviews:scrollView.contentOffset];
}

@end
