//
// ZXStackView.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Alignment of stack view
 */
typedef NS_ENUM(NSInteger, ZXStackViewAlignment) {
    ZXStackViewAlignmentLeading,
    ZXStackViewAlignmentTrailing,
    ZXStackViewAlignmentTop,
    ZXStackViewAlignmentBottom,
};

/**
 ZXStackView
 */
@interface ZXStackView : UIView
/// Alignment of subviews, default is ZXStackViewAlignmentLeading
@property (nonatomic, assign) ZXStackViewAlignment alignment;
/// Number of subviews to display, default and minimum is 2.
@property (nonatomic, assign) NSUInteger numberOfStacks;
/// Number of subviews
@property (nonatomic, assign) NSUInteger numberOfSubviews;
/// The actual frame of subviews
@property (nonatomic, assign) UIEdgeInsets contentInset;
/// Scale factor for subviews, default is 0
@property (nonatomic, assign) CGFloat scaleFactor;
/// Tail spacing for subviews, default is 0
@property (nonatomic, assign) CGFloat tailSpacing;
/// Current index of subview, default is 0
@property (nonatomic, assign) NSInteger currentIndex;
/// Will display subview for index
@property (nonatomic, copy, nullable) UIView * (^willDisplaySubview)(NSInteger index);
/// The subview did display
@property (nonatomic, copy, nullable) void (^didDisplaySubview)(NSInteger index);

/**
 Set current page with animated
 
 @param index The current index
 @param animated animated or immediately
 */
- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;

/**
 Reload data
 */
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
