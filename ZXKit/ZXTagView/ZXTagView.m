//
// ZXTagView.m
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

#import "ZXTagView.h"

@interface ZXTagView ()
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *tagLabels;

@end

@implementation ZXTagLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textAlignment = NSTextAlignmentCenter;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.text = text;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    {
        CGRect rect = self.frame;
        rect.size = _contentSize;
        self.frame = rect;
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        //
        [self updateContentSize];
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    //
    [self updateContentSize];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    //
    [self updateContentSize];
}

- (void)updateContentSize {
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    _contentSize.width = ceilf(size.width) + self.contentInset.left + self.contentInset.right;
    _contentSize.height = ceilf(size.height) + self.contentInset.top + self.contentInset.bottom;
    [self setNeedsDisplay];
}

@end

@implementation ZXTagView

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)setPaddingInset:(UIEdgeInsets)paddingInset {
    _paddingInset = paddingInset;
    [self setNeedsLayout];
}

- (CGFloat)contentHeight {
    __block CGRect rect = CGRectZero;
    rect.origin.x = self.contentInset.left;
    rect.origin.y = self.contentInset.top;
    __weak typeof(self) weakSelf = self;
    [self.tagLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZXTagLabel *label = obj;
        rect.size = label.contentSize;
        if (rect.origin.x + rect.size.width + weakSelf.paddingInset.right + weakSelf.contentInset.right > weakSelf.frame.size.width) {
            rect.origin.x = weakSelf.contentInset.left;
            rect.origin.y += rect.size.height + weakSelf.paddingInset.top + weakSelf.paddingInset.bottom;
        }
        rect.origin.x += rect.size.width + weakSelf.paddingInset.left + weakSelf.paddingInset.right;
    }];
    return rect.origin.y + rect.size.height + weakSelf.paddingInset.bottom;
}

- (void)addTag:(NSString *)tag option:(ZXTagOption)option action:(ZXTagAction)action {
    if (self.tags == nil) {
        self.tags = [NSMutableArray array];
    }
    if (self.tagLabels == nil) {
        self.tagLabels = [NSMutableArray array];
    }
    if ([tag isKindOfClass:[NSString class]]) {
        ZXTagLabel *label = [[ZXTagLabel alloc] initWithText:tag];
        if (option) {
            option(label);
        }
        label.action = action;
        [self addSubview:label];
        [self.tags addObject:tag];
        [self.tagLabels addObject:label];
        [self setNeedsLayout];
        //
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onLabel:)];
        [label addGestureRecognizer:tap];
    }
}

- (void)insertTag:(NSString *)tag atIndex:(NSUInteger)index option:(ZXTagOption)option action:(ZXTagAction)action {
    if ([tag isKindOfClass:[NSString class]]) {
        ZXTagLabel *label = [[ZXTagLabel alloc] initWithText:tag];
        if (option) {
            option(label);
        }
        label.action = action;
        [self addSubview:label];
        [self.tags insertObject:tag atIndex:index];
        [self.tagLabels insertObject:label atIndex:index];
        [self setNeedsLayout];
        //
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onLabel:)];
        [label addGestureRecognizer:tap];
    }
}

- (NSString *)tagAtIndex:(NSUInteger)index {
    return [self.tags objectAtIndex:index];
}

- (ZXTagLabel *)tagLabelAtIndex:(NSUInteger)index {
    return [self.tagLabels objectAtIndex:index];
}

- (void)removeTag:(NSString *)tag {
    NSUInteger index = [self.tags indexOfObject:tag];
    [self removeTagAtIndex:index];
}

- (void)removeTagAtIndex:(NSUInteger)index {
    if (index != NSNotFound && index < self.tags.count) {
        ZXTagLabel *label = self.tagLabels[index];
        [label removeFromSuperview];
        [self.tags removeObjectAtIndex:index];
        [self.tagLabels removeObjectAtIndex:index];
        [self setNeedsLayout];
    }
}

- (void)removeAllTags {
    [self.tagLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZXTagLabel *label = obj;
        [label removeFromSuperview];
    }];
    [self.tags removeAllObjects];
    [self.tagLabels removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    __block CGRect rect = CGRectZero;
    rect.origin.x = self.contentInset.left;
    rect.origin.y = self.contentInset.top;
    __weak typeof(self) weakSelf = self;
    [self.tagLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ZXTagLabel *label = obj;
        rect.size = label.contentSize;
        if (rect.origin.x + rect.size.width + weakSelf.paddingInset.right + weakSelf.contentInset.right > weakSelf.frame.size.width) {
            rect.origin.x = weakSelf.contentInset.left;
            rect.origin.y += rect.size.height + weakSelf.paddingInset.top + weakSelf.paddingInset.bottom;
        }
        label.frame = rect;
        rect.origin.x += rect.size.width + weakSelf.paddingInset.left + weakSelf.paddingInset.right;
    }];
}

- (void)onLabel:(id)sender {
    UITapGestureRecognizer *tap = sender;
    ZXTagLabel *label = (ZXTagLabel *)tap.view;
    if (label.action) {
        label.action(label);
    }
}

@end
