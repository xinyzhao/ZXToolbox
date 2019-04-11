//
// ZXImageViewCell.m
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

#import "ZXImageViewCell.h"
#import "ZXImageView.h"
#import "UIImageView+ZXWebCache.h"

@interface ZXImageViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    __weak ZXImageView *internalImageView;
    __weak NSIndexPath *internalIndexPath;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation ZXImageViewCell

#pragma mark Setter

- (void)setImage:(UIImage *)image {
    _image = [image copy];
    [self setNeedsDisplay];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = [imageURL copy];
    [self setNeedsLayout];
}

#pragma mark Overwrite

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    if (self.image) {
        UIImage *image = self.image;
        CGSize imageSize = [self imageSizeForScreenScale:image];
        CGRect imageRect = CGRectZero;
        CGSize contentSize = self.scrollView.frame.size;
        CGPoint contentOffset = CGPointZero;
        CGFloat minimumZoomScale = 1.f;
        CGFloat maximumZoomScale = 3.f;
        //
        if (imageSize.width < contentSize.width) {
            image = [self imageForScreenWidth:image];
            imageSize = [self imageSizeForScreenScale:image];
        }
        // Issue fixes by xyz on 20161029
        imageSize.width *= self.scrollView.zoomScale;
        imageSize.height *= self.scrollView.zoomScale;
        contentSize.width *= self.scrollView.zoomScale;
        contentSize.height *= self.scrollView.zoomScale;
        //
        if (imageSize.width > contentSize.width || imageSize.height > contentSize.height) {
            imageRect.size = contentSize;
            //
            CGFloat w = imageSize.width / contentSize.width;
            CGFloat h = imageSize.height / contentSize.height;
            if (w < h) {
                imageRect.size.width = imageSize.width / h;
            } else {
                imageRect.size.height = imageSize.height / w;
            }
            //
            maximumZoomScale = MAX(maximumZoomScale, MAX(w, h));
        } else {
            imageRect.origin.x = (contentSize.width - imageSize.width) / 2;
            imageRect.origin.y = (contentSize.height - imageSize.height) / 2;
            imageRect.size = imageSize;
        }
        //
        self.imageView.frame = imageRect;
        self.imageView.image = image;
        //
        self.scrollView.contentSize = imageRect.size;
        self.scrollView.contentOffset = contentOffset;
        self.scrollView.minimumZoomScale = minimumZoomScale;
        self.scrollView.maximumZoomScale = maximumZoomScale;
        //
//        CGSize scaleSize = [self imageSizeForScreenWidth:image];
//        if (scaleSize.height > contentSize.height) {
//            self.scrollView.zoomScale = scaleSize.height / contentSize.height;
//        } else {
//            [self centerImageView];
//        }
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        [self centerImageView];
        //
        self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        self.doubleTap.delegate = self;
        self.doubleTap.numberOfTapsRequired = 2;
        [self.imageView addGestureRecognizer:self.doubleTap];
        [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
        //
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [self.imageView addGestureRecognizer:self.longPress];
        //
        [self.imageView setUserInteractionEnabled:YES];
        
    } else {
        self.imageView.image = self.image;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGRect rect = self.bounds;
    if (self.scrollView == nil) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:rect];
        self.scrollView.delegate = self;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:self.scrollView];
    } else {
        self.scrollView.frame = rect;
    }
    //
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self.contentView addSubview:self.activityIndicatorView];
    } else {
        self.activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    }
    //
    rect = self.bounds;
    if (self.imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:rect];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_imageView];
    } else {
        self.imageView.frame = rect;
    }
    //
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        [self addGestureRecognizer:self.singleTap];
    }
    //
    if (self.imageURL) {
        __weak typeof(self) weakSelf = self;
        [self.activityIndicatorView startAnimating];
        [self.imageView setUserInteractionEnabled:NO];
        [self.imageView zx_setImageWithURL:self.imageURL placeholder:self.image completion:^(UIImage *image, NSError *error, NSURL *imageURL) {
            [weakSelf.activityIndicatorView stopAnimating];
            if (error) {
                NSLog(@"%s %@", __func__, error.localizedDescription);
            } else if (image) {
                weakSelf.image = image;
            }
        }];
    }
}

#pragma mark Functions

- (void)centerImageView {
    CGRect rect = self.imageView.frame;
    CGSize size = self.scrollView.frame.size;
    if (rect.size.width < size.width) {
        rect.origin.x = (size.width - rect.size.width) / 2.0f;
    } else {
        rect.origin.x = 0.0f;
    }
    if (rect.size.height < size.height) {
        rect.origin.y = (size.height - rect.size.height) / 2.0f;
    } else {
        rect.origin.y = 0.0f;
    }
    self.imageView.frame = rect;
}

- (UIImage *)imageForScreenWidth:(UIImage *)image {
    CGSize size = [self imageSizeForScreenScale:image];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = width / size.width;
    size.width = width;
    size.height *= scale;
    //
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //
    return image;
}

- (CGSize)imageSizeForScreenScale:(UIImage *)image {
    CGSize size = image.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    if (image.scale != scale) {
        size.width *= image.scale / scale;
        size.height *= image.scale / scale;
    }
    return size;
}

- (CGSize)imageSizeForScreenWidth:(UIImage *)image {
    CGSize size = [self imageSizeForScreenScale:image];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = width / size.width;
    size.width = width;
    size.height *= scale;
    return size;
}

#pragma mark Target Actions

- (void)onSingleTap:(id)sender {
    __weak typeof(internalImageView) weakImageView = internalImageView;
    __weak typeof(internalIndexPath) weakIndexPath = internalIndexPath;
    if ([internalImageView.delegate respondsToSelector:@selector(imageView:didSelectItemAtIndex:)]) {
        [weakImageView.delegate imageView:weakImageView didSelectItemAtIndex:weakIndexPath.item];
    }
}

- (void)onDoubleTap:(id)sender {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        UITapGestureRecognizer *tap = sender;
        CGRect rect = self.scrollView.frame;
        CGPoint point = [tap locationInView:self.imageView];
        CGFloat scale = self.scrollView.maximumZoomScale;
        rect.size.width = self.scrollView.frame.size.width / scale;
        rect.size.height = self.scrollView.frame.size.height / scale;
        rect.origin.x = point.x - rect.size.width / 2;
        rect.origin.y = point.y - rect.size.height / 2;
        [self.scrollView zoomToRect:rect animated:YES];
    }
}

- (void)onLongPress:(id)sender {
    UILongPressGestureRecognizer *lp = sender;
    if (lp.state == UIGestureRecognizerStateBegan) {
        __weak typeof(internalImageView) weakImageView = internalImageView;
        __weak typeof(internalIndexPath) weakIndexPath = internalIndexPath;
        if ([internalImageView.delegate respondsToSelector:@selector(imageView:longPressItemAtIndex:)]) {
            [weakImageView.delegate imageView:weakImageView longPressItemAtIndex:weakIndexPath.item];
        }
    }
}

#pragma mark <UIScrollViewDelegate>

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerImageView];
}

@end
