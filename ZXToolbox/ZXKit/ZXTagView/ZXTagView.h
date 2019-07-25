//
// ZXTagView.h
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

/// ZXTagView
@interface ZXTagView : UIScrollView

/**
 Multi-line for items, default is single line, if YES the tag view will be auto break to new line
 */
@property(nonatomic, assign) BOOL isMultiLine;

/**
 The spacing for items
 */
@property (nonatomic, assign) CGFloat spacingForItems;

/**
 The spacing for lines
 */
@property (nonatomic, assign) CGFloat spacingForLines;

/**
 Selected item at index
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 Selected index with animated
 @param index The tag index
 @param animated Animated for selection
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

/**
 The tag view selected block
 
 @param index The selected index
 @param view The selected view
 @param view The Previous selected view
 */
@property (nonatomic, copy) void (^selectedBlock)(NSInteger index, UIView *view, UIView *prevView);

/**
 Number of tags
 */
@property (nonatomic, readonly) NSInteger numberOfTags;

/**
 Add tag view with an action block

 @param view The tag view
 */
- (void)addTagView:(UIView *)view;

/**
 Insert tag at index

 @param view The tag view
 @param index The index of tag view
 */
- (void)insertTagView:(UIView *)view atIndex:(NSInteger)index;

/**
 Get tag view at index

 @param index The index of tag view
 @return The tag view
 */
- (UIView *)tagViewAtIndex:(NSInteger)index;

/**
 Remove tag view at index

 @param index The index of tag view
 */
- (void)removeTagAtIndex:(NSInteger)index;

/**
 Remove all tags
 */
- (void)removeAllTags;

@end
