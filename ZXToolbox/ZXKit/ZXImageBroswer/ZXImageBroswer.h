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

@protocol ZXImageBroswerDataSource;
@protocol ZXImageBroswerDelegate;

/**
 ZXImageBroswer
 */
@interface ZXImageBroswer : UIView
/**
 Data source, see ZXImageBroswerDataSource
 */
@property (nonatomic, weak) id <ZXImageBroswerDataSource> dataSource;
/**
 Delegate, see ZXImageBroswerDelegate
 */
@property (nonatomic, weak) id <ZXImageBroswerDelegate> delegate;
/**
 Item spacing, defalut 10.f
 */
@property (nonatomic, assign) CGFloat itemSpacing;

/**
 Register custom cell class

 @param cellClass Base on ZXImageBroswerCell subclass
 */
- (void)registerCellClass:(Class)cellClass;

/**
 Create or reuse a ZXImageBroswerCell

 @param index Index of item
 @return ZXImageBroswerCell
 */
- (ZXImageBroswerCell *)dequeueReusableCellForItemAtIndex:(NSInteger)index;

/**
 Get the cell for index

 @param index The index
 @return ZXImageBroswerCell
 */
- (ZXImageBroswerCell *)cellForItemAtIndex:(NSInteger)index;

/**
 Number of images

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
 ZXImageBroswerDataSource
 */
@protocol ZXImageBroswerDataSource <NSObject>
@required
/**
 Specified number of items

 @param imageBroswer The imageBroswer
 @return NSInteger
 */
- (NSInteger)numberOfItemsInBroswer:(ZXImageBroswer *)imageBroswer;

/**
 Make and config cell from dequeueReusableCellForItemAtIndex:

 @param imageBroswer The imageBroswer
 @param index The index of item
 @return ZXImageBroswerCell
 */
- (ZXImageBroswerCell *)imageBroswer:(ZXImageBroswer *)imageBroswer cellForItemAtIndex:(NSInteger)index;

@end

/**
 ZXImageBroswerDelegate
 */
@protocol ZXImageBroswerDelegate <NSObject>
@optional
/**
 The imageBroswer did select item

 @param imageBroswer The imageBroswer
 @param index The index of item
 */
- (void)imageBroswer:(ZXImageBroswer *)imageBroswer didSelectItemAtIndex:(NSInteger)index;

/**
 The imageBroswer did long press on item

 @param imageBroswer The imageBroswer
 @param index The index of item
 */
- (void)imageBroswer:(ZXImageBroswer *)imageBroswer longPressItemAtIndex:(NSInteger)index;

@end

