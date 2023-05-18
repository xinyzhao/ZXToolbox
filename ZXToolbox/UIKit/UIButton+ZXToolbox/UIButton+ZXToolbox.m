//
// UIButton+ZXToolbox.m
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

#import "UIButton+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"

static char titleImageLayoutKey;
static char titleImageSpacingKey;

@implementation UIButton (ZXToolbox)

+ (void)load {
    [self swizzleMethod:@selector(setTitle:forState:) with:@selector(zx_setTitle:forState:)];
    [self swizzleMethod:@selector(setImage:forState:) with:@selector(zx_setImage:forState:)];
    [self swizzleMethod:@selector(setEnabled:) with:@selector(zx_setEnabled:)];
    [self swizzleMethod:@selector(setHighlighted:) with:@selector(zx_setHighlighted:)];
    [self swizzleMethod:@selector(setSelected:) with:@selector(zx_setSelected:)];
    [self swizzleMethod:@selector(setBounds:) with:@selector(zx_setBounds:)];
}

- (void)zx_setTitle:(NSString *)title forState:(UIControlState)state {
    [self zx_setTitle:title forState:state];
    [self layoutTitleImage];
}

- (void)zx_setImage:(UIImage *)image forState:(UIControlState)state {
    [self zx_setImage:image forState:state];
    [self layoutTitleImage];
}

- (void)zx_setEnabled:(BOOL)enabled {
    [self zx_setEnabled:enabled];
    [self layoutTitleImage];
}

- (void)zx_setHighlighted:(BOOL)highlighted {
    [self zx_setHighlighted:highlighted];
    [self layoutTitleImage];
}

- (void)zx_setSelected:(BOOL)selected {
    [self zx_setSelected:selected];
    [self layoutTitleImage];
}

- (void)zx_setBounds:(CGRect)rect {
    CGRect bounds = self.bounds;
    [self zx_setBounds:rect];
    if (!CGRectEqualToRect(bounds, rect)) { // Bugs fixes for Xcode 13
        [self layoutTitleImage];
    }
}

- (void)setTitleImageLayout:(UIButtonTitleImageLayout)titleImageLayout {
    [self setAssociatedObject:&titleImageLayoutKey value:@(titleImageLayout) policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    [self layoutTitleImage];
}

- (UIButtonTitleImageLayout)titleImageLayout {
    NSNumber *number = [self getAssociatedObject:&titleImageLayoutKey];
    return [number integerValue];
}

- (void)setTitleImageSpacing:(CGFloat)titleImageSpacing {
    [self setAssociatedObject:&titleImageSpacingKey value:@(titleImageSpacing) policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
    [self layoutTitleImage];
}

- (CGFloat)titleImageSpacing {
    NSNumber *number = [self getAssociatedObject:&titleImageSpacingKey];
    return [number floatValue];
}

- (void)layoutTitleImage {
    // reset
    [self setTitleEdgeInsets:UIEdgeInsetsZero];
    [self setImageEdgeInsets:UIEdgeInsetsZero];
    [self layoutIfNeeded];
    // title
    CGRect title = [self titleRectForContentRect:self.bounds];
    if (self.currentTitle.length > 0 && title.size.height <= 0) {
        // Fixed bugs in iOS <= 13
        title.size.height = [self.titleLabel sizeThatFits:self.bounds.size].height;
    }
    // image
    CGRect image = [self imageRectForContentRect:self.bounds];
    // layout
    CGFloat space = self.titleImageSpacing / 2;
    CGPoint point = CGPointZero;
    switch (self.titleImageLayout) {
        case UIButtonTitleImageLayoutRightToLeft:
        {
            [self setTitleEdgeInsets:UIEdgeInsetsMake(0, space, 0, 0)];
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, space)];
            break;
        }
        case UIButtonTitleImageLayoutLeftToRight:
        {
            point.x = title.origin.x - image.origin.x + space;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -point.x, 0, point.x)];
            point.x = title.size.width + space;
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, point.x, 0, -point.x)];
            break;
        }
        case UIButtonTitleImageLayoutBottomToTop:
        {
            point.x = image.size.width;
            point.y = image.size.height + space;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(point.y, -point.x, 0, 0)];
            point.x = title.size.width;
            point.y = title.size.height + space;
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, point.y, -point.x)];
            break;
        }
        case UIButtonTitleImageLayoutTopToBottom:
        {
            point.x = image.size.width;
            point.y = image.size.height + space;
            [self setTitleEdgeInsets:UIEdgeInsetsMake(-point.y, -point.x, 0, 0)];
            point.x = title.size.width;
            point.y = title.size.height + space;
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -point.y, -point.x)];
            break;
        }
    }
}

@end
