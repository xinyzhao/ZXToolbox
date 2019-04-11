//
// ZXCircularProgressView.h
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
 进度风格

 - ZXCircularProgressViewStylePie: 饼状图
 - ZXCircularProgressViewStyleRing: 环形图
 */
typedef NS_ENUM(NSUInteger, ZXCircularProgressViewStyle) {
    ZXCircularProgressViewStylePie,
    ZXCircularProgressViewStyleRing,
};

/// 进度图
@interface ZXCircularProgressView : UIView
/// 进度风格, 默认 ZXCircularProgressViewStylePie
@property (nonatomic, assign) ZXCircularProgressViewStyle progressViewStyle;
/// 顺时针方向, 默认 YES
@property (nonatomic, assign) BOOL clockwise;
/// 闭合完整度，范围 0.0 - 1.0，默认 1.0
@property (nonatomic, assign) float integrity;
/// 线宽，默认 0.f
@property (nonatomic, assign) float lineWidth;
/// 进度，范围 0.0 - 1.0, 默认 0.0
@property (nonatomic, assign) float progress;
/// 进度颜色，默认 [UIView tintColor]
@property (nonatomic, strong) UIColor *progressTintColor;
/// 轨道颜色，默认 nil
@property (nonatomic, strong) UIColor *trackTintColor;

@end
