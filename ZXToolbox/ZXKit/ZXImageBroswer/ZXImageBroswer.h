//
// ZXImageBroswer.h
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

NS_ASSUME_NONNULL_BEGIN

/// ZXImageBroswer
@interface ZXImageBroswer : UIView

/// The image sources, the elements could be UIImage/NSURL
@property (nonatomic, copy) NSArray *imageSources;

/// Image spacing, defalut 10.f
@property (nonatomic, assign) CGFloat imageSpacing;

/// Preferred minimum zoom scale, default is 1.0
@property (nonatomic, assign) CGFloat preferredMinimumZoomScale;

/// Preferred maximum zoom scale, default is 3.0
@property (nonatomic, assign) CGFloat preferredMaximumZoomScale;

/// Current index of displayed image
@property (nonatomic, assign) NSInteger currentIndex;

/// On single tap gesture recognizer action
@property (nonatomic, copy, nullable) void (^onSingleTap)(NSInteger index, id image);

/// On double tap gesture recognizer action, default is zoom scale the image
@property (nonatomic, copy, nullable) void (^onDoubleTap)(NSInteger index, id image);

/// On Long press gesture recognizer action
@property (nonatomic, copy, nullable) void (^onLongPress)(NSInteger index, id image);

/// Initialize
/// @param images The images sources
- (instancetype)initWithImages:(NSArray *)images;

/// Set current index of displayed image
/// @param index Index of image
/// @param animated animated or not
- (void)setCurrentIndex:(NSInteger)index animated:(BOOL)animated;

@end

/// ZXImageBroswer (ZXImageBroswerCell)
@interface ZXImageBroswer (ZXImageBroswerCell)

/// Register custom cell class
/// @param cellClass Base on ZXImageBroswerCell subclass
- (void)registerClass:(nullable Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof ZXImageBroswerCell *)dequeueReusableCellForImageAtIndex:(NSInteger)index;

/// Get the cell for index
/// @param index Index of image
- (nullable ZXImageBroswerCell *)cellForImageAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
