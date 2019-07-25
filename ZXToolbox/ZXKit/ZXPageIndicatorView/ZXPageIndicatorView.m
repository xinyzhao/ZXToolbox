//
// ZXPageIndicatorView.m
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

#import "ZXPageIndicatorView.h"

@interface ZXPageIndicatorView ()
@property (nonatomic, strong) NSMutableArray *pageViews;

@end

@implementation ZXPageIndicatorView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pageIndicatorColor = [UIColor lightGrayColor];
        self.currentPageIndicatorColor = [UIColor whiteColor];
        self.pageIndicatorSize = CGSizeMake(7, 7);
        self.pageIndicatorSpacing = 8;
        self.pageIndicatorCornerRadius = 3.5;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pageIndicatorColor = [UIColor lightGrayColor];
        self.currentPageIndicatorColor = [UIColor whiteColor];
        self.pageIndicatorSize = CGSizeMake(7, 7);
        self.pageIndicatorSpacing = 8;
        self.pageIndicatorCornerRadius = 3.5;
    }
    return self;
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    self.hidden = _numberOfPages <= 1 && _hidesForSinglePage;
    [self setNeedsLayout];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self setNeedsDisplay];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;
    self.hidden = _numberOfPages <= 1 && _hidesForSinglePage;
}

- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor {
    _pageIndicatorColor = pageIndicatorColor;
    [self setNeedsLayout];
}

- (void)setCurrentPageIndicatorColor:(UIColor *)currentPageIndicatorColor {
    _currentPageIndicatorColor = currentPageIndicatorColor;
    [self setNeedsLayout];
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage {
    _pageIndicatorImage = pageIndicatorImage;
    [self setNeedsLayout];
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage {
    _currentPageIndicatorImage = currentPageIndicatorImage;
    [self setNeedsLayout];
}

- (void)setPageIndicatorSize:(CGSize)pageIndicatorSize {
    _pageIndicatorSize = pageIndicatorSize;
    [self setNeedsLayout];
}

- (void)setPageIndicatorSpacing:(CGFloat)pageIndicatorSpacing {
    _pageIndicatorSpacing = pageIndicatorSpacing;
    [self setNeedsLayout];
}

- (void)setPageIndicatorCornerRadius:(CGFloat)pageIndicatorCornerRadius {
    _pageIndicatorCornerRadius = pageIndicatorCornerRadius;
    [self setNeedsLayout];
}

#pragma mark Overrides

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    for (UIImageView *imageView in self.pageViews) {
        if (imageView.tag == _currentPage) {
            if (imageView.highlightedImage) {
                imageView.highlighted = YES;
            } else {
                imageView.backgroundColor = _currentPageIndicatorColor;
            }
        } else {
            if (imageView.image) {
                imageView.highlighted = NO;
            } else {
                imageView.backgroundColor = _pageIndicatorColor;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Layout code
    if (self.pageViews == nil) {
        self.pageViews = [[NSMutableArray alloc] init];
    }
    // Remove all page views
    for (UIImageView *imageView in self.pageViews) {
        [imageView removeFromSuperview];
    }
    [self.pageViews removeAllObjects];
    //
    if (_numberOfPages > 0) {
        // width
        CGRect rect = CGRectZero;
        rect.size = _pageIndicatorSize;
        if (_pageIndicatorImage && _currentPageIndicatorImage) {
            rect.size.width = MAX(_pageIndicatorImage.size.width, _currentPageIndicatorImage.size.width);
        } else if (_pageIndicatorImage) {
            rect.size.width = _pageIndicatorImage.size.width;
        } else if (_currentPageIndicatorImage) {
            rect.size.width = _currentPageIndicatorImage.size.width;
        }
        if (_pageIndicatorImage && _currentPageIndicatorImage) {
            rect.size.height = MAX(_pageIndicatorImage.size.height, _currentPageIndicatorImage.size.height);
        } else if (_pageIndicatorImage) {
            rect.size.height = _pageIndicatorImage.size.height;
        } else if (_currentPageIndicatorImage) {
            rect.size.height = _currentPageIndicatorImage.size.height;
        }
        //
        rect.origin.x = roundf(self.frame.size.width - rect.size.width * _numberOfPages - _pageIndicatorSpacing * (_numberOfPages - 1)) / 2;
        rect.origin.y = roundf(self.frame.size.height - rect.size.height) / 2;
        //
        for (NSInteger i = 0; i < _numberOfPages; ++i) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
            imageView.contentMode = self.contentMode;
            imageView.layer.cornerRadius = _pageIndicatorCornerRadius;
            imageView.layer.masksToBounds = !(_pageIndicatorImage || _currentPageIndicatorImage);
            imageView.image = _pageIndicatorImage;
            imageView.highlightedImage = _currentPageIndicatorImage;
            [imageView setTag:i];
            [self addSubview:imageView];
            [self.pageViews addObject:imageView];
            //
            rect.origin.x += rect.size.width + _pageIndicatorSpacing;
        }
    }
    //
    [self setNeedsDisplay];
}

@end
