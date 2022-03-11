//
// ZXTagView.m
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

#import "ZXTagView.h"

@interface ZXTagView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray<UIStackView *> *lines;
@property (nonatomic, strong) NSMutableArray<UIView *> *items;
@property (nonatomic, strong) NSMutableArray<NSLayoutConstraint *> *layoutConstraints;

@end

@implementation ZXTagView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _items = [[NSMutableArray alloc] init];
    _lines = [[NSMutableArray alloc] init];
    _lineHeight = 0;
    _lineSpacing = 0;
    _itemSpacing = 0;
    _layoutConstraints = [[NSMutableArray alloc] init];
    //
    _stackView = [[UIStackView alloc] initWithFrame:self.bounds];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionFill;
    [self addSubview:_stackView];
    self.contentInset = UIEdgeInsetsZero;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsUpdateConstraints];
}

- (void)setLineHeight:(CGFloat)lineHeight {
    _lineHeight = lineHeight;
    [self setNeedsLayout];
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
    _stackView.spacing = _lineSpacing;
    [self setNeedsUpdateConstraints];
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _itemSpacing = itemSpacing;
    for (UIStackView *line in _lines) {
        line.spacing = _itemSpacing;
    }
    [self setNeedsUpdateConstraints];
}

- (void)addItem:(UIView *)item {
    if (item) {
        [_items addObject:item];
        [self setNeedsLayout];
    }
}

- (void)insertItem:(UIView *)item atIndex:(NSUInteger)index {
    if (item) {
        [_items insertObject:item atIndex:index];
        [self setNeedsLayout];
    }
}

- (nullable UIView *)itemAtIndex:(NSUInteger)index {
    if (index < _items.count) {
        return _items[index];
    }
    return nil;
}

- (void)removeItemAtIndex:(NSUInteger)index {
    if (index < _items.count) {
        [_items removeObjectAtIndex:index];
        [self setNeedsLayout];
        UITableView *t;
        t.rowHeight = 1;
    }
}

- (void)removeItem:(UIView *)item {
    if ([_items containsObject:item]) {
        [_items removeObject:item];
        [self setNeedsLayout];
    }
}

- (void)removeAllLines {
    for (UIStackView *line in _lines) {
        for (UIView *view in line.arrangedSubviews) {
            [line removeArrangedSubview:view];
            [view removeFromSuperview];
        }
    }
    for (UIView *view in _stackView.arrangedSubviews) {
        [_stackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    [_lines removeAllObjects];
}

- (void)removeAllItems {
    [self removeAllLines];
    [_items removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    [self removeAllLines];
    //
    UIStackView *line = [self addLineView];
    UIView *tail = [self addTailView:line];
    //
    for (UIView *item in _items) {
        // add item
        [item removeFromSuperview];
        [line addArrangedSubview:item];
        // set item compression/hugging priority to high
        [item setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [item setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        [item setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [item setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        // add tail
        [line removeArrangedSubview:tail];
        [tail removeFromSuperview];
        [line addArrangedSubview:tail];
        //
        if (line.arrangedSubviews.count > 2) {
            [line layoutIfNeeded];
            // if tail width is equal to zero, add new line
            if (tail.frame.size.width <= 0) {
                // remove item
                [line removeArrangedSubview:item];
                [item removeFromSuperview];
                // add item to new line
                line = [self addLineView];
                tail = [self addTailView:line];
                [line addArrangedSubview:item];
            }
        }
    }
    //
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    //
    [self removeConstraints:_layoutConstraints];
    [_layoutConstraints removeAllObjects];
    //
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:_contentInset.left]];
    [_layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:_contentInset.right]];
    [_layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:_contentInset.top]];
    [_layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:_stackView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:_contentInset.bottom]];
    //
    if (_lineHeight > 0.1) {
        BOOL hasHeight = NO;
        for (NSLayoutConstraint *ls in self.constraints) {
            if (ls.firstAttribute == NSLayoutAttributeHeight) {
                hasHeight = YES;
                break;
            }
        }
        if (hasHeight) {
            //add placeholder line
            [self addTailView:_stackView];
        } else {
            //add height constraint
            NSInteger rows = self.numberOfLines;
            CGFloat height = rows * _lineHeight;
            height += (rows - 1) * _lineSpacing;
            height += _contentInset.top + _contentInset.bottom;
            self.translatesAutoresizingMaskIntoConstraints = NO;
            [_layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height]];
        }
    }
    //
    [self addConstraints:_layoutConstraints];
}

- (UIStackView *)addLineView {
    UIStackView *line = [[UIStackView alloc] init];
    line.axis = UILayoutConstraintAxisHorizontal;
    line.distribution = UIStackViewDistributionFill;
    line.spacing = _itemSpacing;
    [_lines addObject:line];
    [_stackView addArrangedSubview:line];
    if (_lineHeight > 0.1) {
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [line addConstraint:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:_lineHeight]];
    }
    return line;
}

- (UIView *)addTailView:(nonnull UIStackView *)line {
    UIView *tail = [[UIView alloc] init];
    [line addArrangedSubview:tail];
    [tail setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [tail setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [tail setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [tail setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    return tail;
}

@end

@implementation ZXTagView (Extension)

- (NSInteger)numberOfLines {
    return _lines.count;
}

- (NSInteger)numberOfItems {
    return _items.count;
}

- (nullable UIView *)firstItem {
    return _items.firstObject;
}

- (nullable UIView *)lastItem {
    return _items.lastObject;
}

@end
