//
// ZXTagView.m
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

#import "ZXTagView.h"

@interface ZXTagView ()
@property (nonatomic, strong) NSMutableArray<UIView *> *tagViews;

@end

@implementation ZXTagView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    _isMultiLine = NO;
    _spacingForItems = 0;
    _spacingForLines = 0;
    _selectedIndex = -1;
}

- (void)setSpacingForItems:(CGFloat)spacingForItems {
    _spacingForItems = spacingForItems;
    [self setNeedsLayout];
}

- (void)setSpacingForLines:(CGFloat)spacingForLines {
    _spacingForLines = spacingForLines;
    [self setNeedsLayout];
}

- (NSMutableArray<UIView *> *)tagViews {
    if (_tagViews == nil) {
        _tagViews = [[NSMutableArray alloc] init];
    }
    return _tagViews;
}

- (NSInteger)numberOfTags {
    return self.tagViews.count;
}

- (void)addTagView:(UIView *)view {
    if (view) {
        [self.tagViews addObject:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onTagView:)];
        [view addGestureRecognizer:tap];
        [self addSubview:view];
        [self setNeedsLayout];
    }
}

- (void)insertTagView:(UIView *)view atIndex:(NSInteger)index {
    if (view) {
        [self.tagViews insertObject:view atIndex:index];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onTagView:)];
        [view addGestureRecognizer:tap];
        [self addSubview:view];
        [self setNeedsLayout];
    }
}

- (UIView *)tagViewAtIndex:(NSInteger)index {
    UIView *view = nil;
    if (index >= 0 && index < self.tagViews.count) {
        view = [self.tagViews objectAtIndex:index];
    }
    return view;
}

- (void)removeTagAtIndex:(NSInteger)index {
    UIView *view = [self tagViewAtIndex:index];
    if (view) {
        [view removeFromSuperview];
        [self.tagViews removeObject:view];
        [self setNeedsLayout];
    }
}

- (void)removeAllTags {
    [self.tagViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.tagViews removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    __block CGRect rect = CGRectZero;
    [self.tagViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        rect.size = obj.bounds.size;
        if (self->_isMultiLine) {
            if (rect.origin.x + rect.size.width + self->_spacingForItems + self.contentInset.left + self.contentInset.right > self.frame.size.width) {
                rect.origin.x = 0;
                rect.origin.y += rect.size.height + self->_spacingForLines;
            }
        }
        obj.frame = rect;
        rect.origin.x += rect.size.width + self->_spacingForItems;
    }];
    //
    if (_isMultiLine) {
        rect.size.width = 0;
        rect.size.height = rect.origin.y + rect.size.height;
    } else {
        rect.size.width = rect.origin.x - _spacingForItems;
        rect.size.height = 0;
    }
    BOOL reselect = self.contentSize.width != rect.size.width;
    self.contentSize = rect.size;
    //
    if (reselect) {
        self.selectedIndex = _selectedIndex;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated {
    UIView *view = [self tagViewAtIndex:selectedIndex];
    if (view) {
        if (!_isMultiLine) {
            CGPoint offset = CGPointZero;
            offset.x = view.frame.origin.x + view.bounds.size.width / 2 - self.bounds.size.width / 2;
            CGFloat left = -self.contentInset.left;
            CGFloat right = self.contentSize.width + self.contentInset.right - self.bounds.size.width;
            if (offset.x < left) {
                offset.x = left;
            } else if (right > 0) {
                if (offset.x > right) {
                    offset.x = right;
                }
            } else {
                offset.x = left;
            }
            [self setContentOffset:offset animated:animated];
        }
        //
        UIView *prevView = [self tagViewAtIndex:_selectedIndex];
        if (_selectedIndex != selectedIndex) {
            _selectedIndex = selectedIndex;
        }
        if (_selectedBlock) {
            _selectedBlock(_selectedIndex, view, prevView);
        }
    }
}

- (void)onTagView:(id)sender {
    UITapGestureRecognizer *tap = sender;
    NSInteger index = [self.tagViews indexOfObject:tap.view];
    [self setSelectedIndex:index animated:YES];
}

@end
