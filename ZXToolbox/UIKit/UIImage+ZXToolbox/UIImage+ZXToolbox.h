//
// UIImage+ZXToolbox.h
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
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>

/// 拼接
UIKIT_EXTERN UIImage * UIImageCombineToRect(UIImage *image1, UIImage *image2, CGRect rect);

/// 压缩
UIKIT_EXTERN NSData * UIImageCompressToData(UIImage *image, NSUInteger bytes);

/// 裁剪
UIKIT_EXTERN UIImage * UIImageCroppingToRect(UIImage *image, CGRect rect);

/// 根据颜色创建图像
UIKIT_EXTERN UIImage * UIImageFromColor(UIColor *color, CGSize size);

/// 高斯模糊
UIKIT_EXTERN UIImage * UIImageGaussianBlur(UIImage *image, CGFloat radius);

/// 正向图
UIKIT_EXTERN UIImage * UIImageOrientationToUp(UIImage *image);

/// 缩放
UIKIT_EXTERN UIImage * UIImageScaleToSize(UIImage *image, CGSize size);

/// 图像尺寸
UIKIT_EXTERN CGSize UIImageSizeOfScale(UIImage *image, CGFloat scale);
UIKIT_EXTERN CGSize UIImageSizeOfScreenScale(UIImage *image);
UIKIT_EXTERN CGSize UIImageSizeToScale(UIImage *image, CGFloat scale);

/// 灰度图
UIKIT_EXTERN UIImage * UIImageToGrayscale(UIImage *image);

/// 缩略图
UIKIT_EXTERN UIImage * UIImageToThumbnail(UIImage *image, CGSize size, BOOL scaleAspectFill);


/// UIImage (ZXToolbox)
@interface UIImage (ZXToolbox)

/// 根据颜色创建图像
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/// 高斯模糊
- (UIImage *)blurImage:(CGFloat)radius;

/// 合并
- (UIImage *)combineImage:(UIImage *)image toRect:(CGRect)rect;

/// 压缩
- (NSData *)compressToData:(NSUInteger)bytes;

/// 裁剪
- (UIImage *)croppingToRect:(CGRect)rect;

/// 灰度图
- (UIImage *)grayscaleImage;

/// 正向图
- (UIImage *)orientationToUp;

/// 缩放
- (UIImage *)scaleTo:(CGFloat)scale;
- (UIImage *)scaleToSize:(CGSize)size;

/// 尺寸
- (CGSize)sizeOfScale:(CGFloat)scale;
- (CGSize)sizeOfScreenScale;
- (CGSize)sizeToScale:(CGFloat)scale;

/// 缩略图
- (UIImage *)thumbnailImage:(CGSize)size aspect:(BOOL)fill;

@end

