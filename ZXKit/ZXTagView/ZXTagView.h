//
// ZXTagView.h
//
// Copyright (c) 2018 Zhao Xin (https://github.com/xinyzhao/ZXToolbox)
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

@class ZXTagLabel;

/**
 Tag aciton handler

 @param label The sender
 */
typedef void(^ZXTagAction)(ZXTagLabel *label);

/**
 ZXTagLabel
 */
@interface ZXTagLabel : UILabel
/**
 Tag action, see ZXTagAction
 */
@property (nonatomic, copy) ZXTagAction action;
/**
 Content inset, margins for label
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;
/**
 Content size, include insets
 */
@property (nonatomic, readonly) CGSize contentSize;

/**
 Initialzes with text string

 @param text content text
 @return Instance
 */
- (instancetype)initWithText:(NSString *)text;

@end

/**
 Tag option handler

 @param label ZXTagLabel
 */
typedef void(^ZXTagOption)(ZXTagLabel *label);

/// ZXTagView
@interface ZXTagView : UIView
/**
 Content inset, margins for tagView
 */
@property (nonatomic, assign) UIEdgeInsets contentInset;
/**
 Padding inset, space for line and item
 */
@property (nonatomic, assign) UIEdgeInsets paddingInset;
/**
 Content height
 */
@property (nonatomic, readonly) CGFloat contentHeight;

/**
 Add tag at last

 @param tag Tag text
 @param option option handler
 @param action action handler
 */
- (void)addTag:(NSString *)tag option:(ZXTagOption)option action:(ZXTagAction)action;

/**
 Insert tag at index

 @param tag Tag text
 @param index Index of tag
 @param option option handler
 @param action action handler
 */
- (void)insertTag:(NSString *)tag atIndex:(NSUInteger)index option:(ZXTagOption)option action:(ZXTagAction)action;

/**
 Get tag text at index

 @param index Index of tag
 @return Tag text
 */
- (NSString *)tagAtIndex:(NSUInteger)index;

/**
 Get tag label at index

 @param index Index of tag
 @return ZXTagLabel
 */
- (ZXTagLabel *)tagLabelAtIndex:(NSUInteger)index;

/**
 Remove tag with tag text

 @param tag Tag text
 */
- (void)removeTag:(NSString *)tag;

/**
 Remove tag at index

 @param index Index of tag
 */
- (void)removeTagAtIndex:(NSUInteger)index;

/**
 Remove all tags
 */
- (void)removeAllTags;

@end
