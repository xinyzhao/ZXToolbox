//
// UIImage+ZXToolbox.m
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

#import "UIImage+ZXToolbox.h"

#pragma mark UIImage category

UIImage * UIImageCombineToRect(UIImage *image1, UIImage *image2, CGRect rect) {
    CGSize size = image1.size;
    CGFloat w = MAX(size.width, rect.origin.x + rect.size.width);
    CGFloat h = MAX(size.height, rect.origin.y + rect.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), NO, image1.scale);
    [image1 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [image2 drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

NSData * UIImageCompressToData(UIImage *image, NSUInteger bytes) {
    if (bytes < 1024) {
        bytes = 1024;
        NSLog(@">[COMPRESS] Not less than %d bytes", (int)bytes);
    }
    NSData *data = UIImageJPEGRepresentation(image, 1.f);
    NSLog(@">[IMAGE] size:%@ bytes:%d", NSStringFromCGSize(image.size), (int)data.length);
    int retry = 0;
    while (data.length > bytes) {
        CGFloat quality = (float)bytes / data.length;
        if (quality < 0.1f) {
            quality = 0.1f;
        }
        data = UIImageJPEGRepresentation(image, quality);
        if (data.length > bytes) {
            float scale = (float)bytes / data.length;
            if (scale < 0.1f) {
                scale = 0.1f;
            }
            CGSize size = UIImageSizeToScale(image, scale);
            image = UIImageScaleToSize(image, size);
            data = UIImageJPEGRepresentation(image, 1.f);
        }
        retry++;
    }
    NSLog(@">[COMPRESSED] size:%@ bytes:%d retry:%d",
          NSStringFromCGSize(image.size), (int)data.length, retry);
    return data;
}

UIImage * UIImageCroppingToRect(UIImage *image, CGRect rect) {
    rect.origin.x = roundf(rect.origin.x * image.scale);
    rect.origin.y = roundf(rect.origin.y * image.scale);
    rect.size.width = roundf(rect.size.width * image.scale);
    rect.size.height = roundf(rect.size.height * image.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    return croppedImage;
}

UIImage * UIImageFromColor(UIColor *color, CGSize size) {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//https://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIGaussianBlur
UIImage * UIImageGaussianBlur(UIImage *image, CGFloat radius) {
    if (image) {
        //
        CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [filter setValue:inputImage forKey:@"inputImage"];
        [filter setValue:@(radius) forKey:@"inputRadius"];
        //
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = [filter valueForKey:@"outputImage"];
        CGRect outputRect = CGRectZero;
        outputRect.size = UIImageSizeOfScale(image, 1.0);
        CGImageRef imageRef = [context createCGImage:outputImage
                                            fromRect:outputRect];
        image = [[UIImage alloc] initWithCGImage:imageRef scale:image.scale orientation:image.imageOrientation];
        CGImageRelease(imageRef);
    }
    //
    return image;
}

UIImage * UIImageOrientationToUp(UIImage *image) {
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *imgup = [UIImage imageWithCGImage:cgimg scale:image.scale orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    //
    return imgup;
}

UIImage * UIImageScaleToSize(UIImage *image, CGSize size) {
    UIImage *resized = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

CGSize UIImageSizeOfScale(UIImage *image, CGFloat scale) {
    CGSize size = image.size;
    if (scale > 0) {
        size.width *= image.scale / scale;
        size.height *= image.scale / scale;
    }
    return size;
}

CGSize UIImageSizeOfScreenScale(UIImage *image) {
    return UIImageSizeOfScale(image, [UIScreen mainScreen].scale);
}

CGSize UIImageSizeToScale(UIImage *image, CGFloat scale) {
    CGSize size = image.size;
    if (scale > 0) {
        size.width *= scale;
        size.height *= scale;
    }
    return size;
}

UIImage * UIImageToGrayscale(UIImage *image) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    //
    if (context) {
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        UIImage *grayImage = [UIImage imageWithCGImage:cgImage];
        CGContextRelease(context);
        CGImageRelease(cgImage);
        return grayImage;
    }
    //
    return image;
}

// convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
//UIImage * UIImageToGrayscale(UIImage *image) {
//    typedef enum {
//        A = 0,
//        B = 1,
//        G = 2,
//        R = 3,
//    };
//    //
//    uint32_t width = image.size.width;
//    uint32_t height = image.size.height;
//    uint32_t *pixels = (uint32_t *)malloc(width * height * sizeof(uint32_t));
//    memset(pixels, 0, width * height * sizeof(uint32_t));
//    //
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
//    CGColorSpaceRelease(colorSpace);
//    //
//    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
//    //
//    for(int y = 0; y < height; y++) {
//        for(int x = 0; x < width; x++) {
//            uint8_t *pixel = (uint8_t *)&pixels[y * width + x];
//            uint8_t gray = 0.299 * pixel[R] + 0.587 * pixel[G] + 0.114 * pixel[B];
//            // set the pixels to gray
//            pixel[R] = gray;
//            pixel[G] = gray;
//            pixel[B] = gray;
//        }
//    }
//    //
//    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
//    CGContextRelease(context);
//    return grayImage;
//}

UIImage * UIImageToThumbnail(UIImage *image, CGSize size, BOOL scaleAspectFill) {
    UIImage *thumbnail = nil;
    //
    CGSize imageSize = image.size;
    imageSize.width *= image.scale;
    imageSize.height *= image.scale;
    //
    CGSize thumbSize = size;
    thumbSize.width *= [UIScreen mainScreen].scale;
    thumbSize.height *= [UIScreen mainScreen].scale;
    //
    if (scaleAspectFill) {
        CGFloat x = thumbSize.width / imageSize.width;
        CGFloat y = thumbSize.height / imageSize.height;
        if (x < y) {
            thumbSize.width = imageSize.width * y;
        } else {
            thumbSize.height = imageSize.height * x;
        }
    }
    //
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData) {
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
        if (sourceRef) {
            CGFloat maxPixelSize = MAX(thumbSize.width, thumbSize.height);
            NSDictionary *options = @{(id)kCGImageSourceCreateThumbnailFromImageAlways:(id)kCFBooleanTrue,
                                      (id)kCGImageSourceThumbnailMaxPixelSize:@(maxPixelSize)
                                      };
            CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (CFDictionaryRef)options);
            thumbnail = [[UIImage alloc] initWithCGImage:imageRef
                                                   scale:[UIScreen mainScreen].scale
                                             orientation:image.imageOrientation];
            CGImageRelease(imageRef);
            CFRelease(sourceRef);
        }
    }
    //
    return thumbnail;
}

#pragma mark UIImage (ZXToolbox)

@implementation UIImage (ZXToolbox)

+ (UIImage *)imageWithColor:(UIColor *)color {
    return UIImageFromColor(color, CGSizeMake(1, 1));
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    return UIImageFromColor(color, size);
}

- (UIImage *)blurImage:(CGFloat)radius {
    return UIImageGaussianBlur(self, radius);
}

- (UIImage *)combineImage:(UIImage *)image toRect:(CGRect)rect {
    return UIImageCombineToRect(self, image, rect);
}

- (NSData *)compressToData:(NSUInteger)bytes {
    return UIImageCompressToData(self, bytes);
}

- (UIImage *)croppingToRect:(CGRect)rect {
    return UIImageCroppingToRect(self, rect);
}

- (UIImage *)grayscaleImage {
    return UIImageToGrayscale(self);
}

- (UIImage *)orientationToUp {
    return UIImageOrientationToUp(self);
}

- (UIImage *)scaleTo:(CGFloat)scale {
    CGSize size = [self sizeToScale:scale];
    return UIImageScaleToSize(self, size);
}

- (UIImage *)scaleToSize:(CGSize)size {
    return UIImageScaleToSize(self, size);
}

- (CGSize)sizeOfScale:(CGFloat)scale {
    return UIImageSizeOfScale(self, scale);
}

- (CGSize)sizeOfScreenScale {
    return UIImageSizeOfScreenScale(self);
}

- (CGSize)sizeToScale:(CGFloat)scale {
    return UIImageSizeToScale(self, scale);
}

- (UIImage *)thumbnailImage:(CGSize)size aspect:(BOOL)fill {
    return UIImageToThumbnail(self, size, fill);
}

@end

