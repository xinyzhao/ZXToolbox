//
// ZXBadgeLabel.h
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

/**
 ZXBadgeLabel
 */
@interface ZXBadgeLabel : UILabel

/**
 Audo-hide, calls -setHidden when number equal or less than mininum
 */
@property (nonatomic, assign) BOOL audoHide; // Default YES

/**
 Badge number
 */
@property (nonatomic, assign) NSInteger number; // Default 0

/**
 Mininum number
 */
@property (nonatomic, assign) NSInteger mininum; // Default 0

/**
 Maxinum, eg. number>99 and maxinum==99, display as "99+"
 */
@property (nonatomic, assign) NSInteger maxinum; // Default 99

@end

