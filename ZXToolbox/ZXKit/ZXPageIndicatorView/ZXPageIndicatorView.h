//
// ZXPageIndicatorView.h
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

@interface ZXPageIndicatorView : UIView
/// default is 0
@property(nonatomic, assign) NSInteger numberOfPages;
/// default is 0. value pinned to 0..numberOfPages-1
@property(nonatomic, assign) NSInteger currentPage;

/// hide the the indicator if there is only one page. default is NO
@property(nonatomic) BOOL hidesForSinglePage;

/// default is light gray color
@property(nonatomic, strong, nullable) UIColor *pageIndicatorColor;
/// default is white color
@property(nonatomic, strong, nullable) UIColor *currentPageIndicatorColor;

/// default is nil
@property(nonatomic, strong, nullable) UIImage *pageIndicatorImage;
/// default is nil
@property(nonatomic, strong, nullable) UIImage *currentPageIndicatorImage;

/// default is {7 x 7}
@property(nonatomic, assign) CGSize pageIndicatorSize;
/// default is 8
@property(nonatomic, assign) CGFloat pageIndicatorSpacing;
/// default is 3.5
@property(nonatomic, assign) CGFloat pageIndicatorCornerRadius;

@end

NS_ASSUME_NONNULL_END
