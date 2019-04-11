//
// ZXImageView.h
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

@protocol ZXImageViewDataSource;
@protocol ZXImageViewDelegate;

/**
 ZXImageView
 */
@interface ZXImageView : UIView
/**
 Data source, see ZXImageViewDataSource
 */
@property (nonatomic, weak) id <ZXImageViewDataSource> dataSource;
/**
 Delegate, see ZXImageViewDelegate
 */
@property (nonatomic, weak) id <ZXImageViewDelegate> delegate;
/**
 Item spacing, defalut 10.f
 */
@property (nonatomic, assign) CGFloat itemSpacing;

/**
 Register custom cell class

 @param cellClass Base on ZXImageViewCell subclass
 */
- (void)registerCellClass:(Class)cellClass;

/**
 Create or reuse a ZXImageViewCell

 @param index Index of item
 @return ZXImageViewCell
 */
- (ZXImageViewCell *)dequeueReusableCellForItemAtIndex:(NSInteger)index;

/**
 Get the cell for index

 @param index The index
 @return ZXImageViewCell
 */
- (ZXImageViewCell *)cellForItemAtIndex:(NSInteger)index;

/**
 Number of items

 @return NSInteger
 */
- (NSInteger)numberOfItems;

/**
 Reload data
 */
- (void)reloadData;

/**
 Get the index for visible item
 @return The index
 */
- (NSInteger)indexForVisibleItem;

/**
 Scroll to specified item

 @param index Index of item
 @param animated animated or immediately
 */
- (void)scrollToItemAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end

/**
 ZXImageViewDataSource
 */
@protocol ZXImageViewDataSource <NSObject>
@required
/**
 Specified number of items

 @param imageView The imageView
 @return NSInteger
 */
- (NSInteger)numberOfItemsInImageView:(ZXImageView *)imageView;

/**
 Make and config cell from dequeueReusableCellForItemAtIndex:

 @param imageView The imageView
 @param index The index of item
 @return ZXImageViewCell
 */
- (ZXImageViewCell *)imageView:(ZXImageView *)imageView cellForItemAtIndex:(NSInteger)index;

@end

/**
 ZXImageViewDelegate
 */
@protocol ZXImageViewDelegate <NSObject>
@optional
/**
 The imageView did select item

 @param imageView The imageView
 @param index The index of item
 */
- (void)imageView:(ZXImageView *)imageView didSelectItemAtIndex:(NSInteger)index;

/**
 The imageView did long press on item

 @param imageView The imageView
 @param index The index of item
 */
- (void)imageView:(ZXImageView *)imageView longPressItemAtIndex:(NSInteger)index;

@end

