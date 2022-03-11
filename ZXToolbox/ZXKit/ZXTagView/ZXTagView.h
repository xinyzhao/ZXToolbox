//
// ZXTagView.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
UIKIT_EXTERN API_AVAILABLE(ios(9.0))
@interface ZXTagView : UIView

/// The content inset.
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// The line height, default is automatic dimension.
@property (nonatomic, assign) CGFloat lineHeight;

/// The spacing of between lines, default is 0.
@property (nonatomic, assign) CGFloat lineSpacing;

/// The spacing of between items, default is 0.
@property (nonatomic, assign) CGFloat itemSpacing;

/// Add an item
/// @param item The item view
- (void)addItem:(UIView *)item;

/// Insert an item at index
/// @param item The item view
/// @param index The index of item
- (void)insertItem:(UIView *)item atIndex:(NSUInteger)index;

/// Get tag view at index
/// @param index The index of item
/// @return The item view
- (nullable UIView *)itemAtIndex:(NSUInteger)index;

/// Remove the item at index
/// @param index The index of item
- (void)removeItemAtIndex:(NSUInteger)index;

/// Removes all occurrences in the array of a given item.
/// @param item The item
- (void)removeItem:(UIView *)item;

/// Remove all items
- (void)removeAllItems;

@end

@interface ZXTagView (Extension)
/// Number of lines, default is single line
@property (nonatomic, readonly) NSInteger numberOfLines;
/// Number of items
@property (nonatomic, readonly) NSInteger numberOfItems;
/// The first item view
@property (nonatomic, readonly, nullable) UIView *firstItem;
/// The last item view
@property (nonatomic, readonly, nullable) UIView *lastItem;

@end

NS_ASSUME_NONNULL_END
