//
// ZXImageBroswerCell.m
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

#import "ZXImageBroswerCell.h"
#import "ZXImageBroswer.h"

@interface ZXImageBroswerCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    __weak ZXImageBroswer *internalImageView;
    __weak NSIndexPath *internalIndexPath;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation ZXImageBroswerCell

#pragma mark Getter

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

- (UIActivityIndicatorView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self.contentView addSubview:_loadingView];
    }
    return _loadingView;
}

- (UITapGestureRecognizer *)singleTap {
    if (_singleTap == nil) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
        _singleTap.enabled = NO;
        [self addGestureRecognizer:_singleTap];
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (_doubleTap == nil) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        _doubleTap.delegate = self;
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.enabled = NO;
        [self.imageView addGestureRecognizer:_doubleTap];
        [self.singleTap requireGestureRecognizerToFail:_doubleTap];
    }
    return _doubleTap;
}

- (UILongPressGestureRecognizer *)longPress {
    if (_longPress == nil) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        _longPress.enabled = NO;
        [self.imageView addGestureRecognizer:_longPress];
    }
    return _longPress;
}

#pragma mark Setter

- (void)setImage:(UIImage *)image {
    _image = image;
    //
    [self setNeedsDisplay];
}

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    //
    if (_imageURL) {
        __weak typeof(self) weakSelf = self;
        [self.loadingView startAnimating];
        [self.imageView zx_setImageWithURL:_imageURL placeholder:_image completion:^(UIImage *image, NSError *error, NSURL *imageURL) {
            [weakSelf.loadingView stopAnimating];
            if (error) {
                NSLog(@"%s %@", __func__, error.localizedDescription);
            } else if (image) {
                weakSelf.image = image;
            }
        }];
    }
    //
    [self setNeedsLayout];
}

#pragma mark Overwrite

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //
    self.singleTap.enabled = YES;
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
        self.imageView.userInteractionEnabled = YES;
        self.doubleTap.enabled = YES;
        self.longPress.enabled = YES;
        
    } else {
        self.imageView.image = nil;
        self.imageView.userInteractionEnabled = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    self.scrollView.frame = self.bounds;
    self.loadingView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.imageView.frame = self.bounds;
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

- (void)zoomInPoint:(CGPoint)point {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        CGRect rect = self.scrollView.frame;
        CGFloat scale = self.scrollView.maximumZoomScale;
        rect.size.width = self.scrollView.frame.size.width / scale;
        rect.size.height = self.scrollView.frame.size.height / scale;
        rect.origin.x = point.x - rect.size.width / 2;
        rect.origin.y = point.y - rect.size.height / 2;
        [self.scrollView zoomToRect:rect animated:YES];
    }
}

#pragma mark Target Actions

- (void)onSingleTap:(id)sender {
    if (_onSingleTap) {
        _onSingleTap();
    }
}

- (void)onDoubleTap:(id)sender {
    if (_onDoubleTap) {
        _onDoubleTap();
    } else {
        UITapGestureRecognizer *tap = sender;
        CGPoint point = [tap locationInView:tap.view];
        [self zoomInPoint:point];
    }
}

- (void)onLongPress:(id)sender {
    UILongPressGestureRecognizer *gr = sender;
    if (gr.state == UIGestureRecognizerStateBegan) {
        if (_onLongPress) {
            _onLongPress();
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
