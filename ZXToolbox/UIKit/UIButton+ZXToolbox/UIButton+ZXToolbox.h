//
// UIButton+ZXToolbox.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UIButtonTitleImageLayout) {
    UIButtonTitleImageLayoutRightToLeft = 0, // The title is on the right and the image is on the left
    UIButtonTitleImageLayoutLeftToRight = 1, // The title is on the left and the image is on the right
    UIButtonTitleImageLayoutBottomToTop = 2, // The title is on the bottom and the image is on the top
    UIButtonTitleImageLayoutTopToBottom = 3, // The title is on the top and the image is on the bottom
    UIButtonTitleImageLayoutLeft __attribute__ ((deprecated)) = UIButtonTitleImageLayoutRightToLeft,
    UIButtonTitleImageLayoutRight __attribute__ ((deprecated)) = UIButtonTitleImageLayoutLeftToRight,
    UIButtonTitleImageLayoutTop __attribute__ ((deprecated)) = UIButtonTitleImageLayoutBottomToTop,
    UIButtonTitleImageLayoutBottom __attribute__ ((deprecated)) = UIButtonTitleImageLayoutTopToBottom,
    UIButtonTitleImageLayoutDefault __attribute__ ((deprecated)) = UIButtonTitleImageLayoutRightToLeft,
};

@interface UIButton (ZXToolbox)

/** Default is UIButtonTitleImageLayoutRightToLeft */
@property (nonatomic, assign) UIButtonTitleImageLayout titleImageLayout;

/** Default is 0 */
@property (nonatomic, assign) CGFloat titleImageSpacing;

@end

NS_ASSUME_NONNULL_END
