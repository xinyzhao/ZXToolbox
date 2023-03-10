//
// CALayer+ZXToolbox.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2023 Zhao Xin
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

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, CALayerCornerMask) {
    CALayerCornerMaskTopLeft                = 1U << 0, // 左上 #0001
    CALayerCornerMaskTopRight               = 1U << 1, // 右上 #0010
    CALayerCornerMaskBottomLeft             = 1U << 2, // 左下 #0100
    CALayerCornerMaskBottomRight            = 1U << 3, // 右下 #1000
    CALayerCornerMaskTopCorners             = CALayerCornerMaskTopLeft|CALayerCornerMaskTopRight, // 上边 #0011
    CALayerCornerMaskBottomCorners          = CALayerCornerMaskBottomLeft|CALayerCornerMaskBottomRight, // 下边 #1100
    CALayerCornerMaskLeftCorners            = CALayerCornerMaskTopLeft|CALayerCornerMaskBottomLeft, // 左边 #0101
    CALayerCornerMaskRightCorners           = CALayerCornerMaskTopRight|CALayerCornerMaskBottomRight, // 右边 #1010
    CALayerCornerMaskTopLeft2BottomRight    = CALayerCornerMaskTopLeft|CALayerCornerMaskBottomRight, // 左上到右下 #1001
    CALayerCornerMaskBottomLeft2TopRight    = CALayerCornerMaskBottomLeft|CALayerCornerMaskTopRight, // 左下到右上 #0110
    CALayerCornerMaskAllCorners             = ~0UL // 全部 #1111
};

@interface CALayer (ZXToolbox)
/// The mask layer of corner if set cornerMasks.
@property (nonatomic, nullable, readonly) CAShapeLayer *cornerLayer;
/// The corner masks.
@property (nonatomic, assign) CALayerCornerMask cornerMasks;

@end

NS_ASSUME_NONNULL_END
