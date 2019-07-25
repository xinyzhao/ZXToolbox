//
// ZXDrawingView.h
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

/**
 ZXDrawingView
 */
@interface ZXDrawingView : UIView
/**
 The line color of drawing, default [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *lineColor;
/**
 The line width of drawing, default 1
 */
@property (nonatomic, assign) CGFloat lineWidth;
/**
 Eraser enabled/disabled, default NO
 */
@property (nonatomic, assign) BOOL eraserEnabled;

/**
 Add a point to line

 @param point The line point
 @param newLine Whether or not a new line
 */
- (void)addPoint:(CGPoint)point toNewLine:(BOOL)newLine;

/**
 Add points to line

 @param points The line points
 @param newLine Whether or not a new line
 */
- (void)addPoints:(NSArray *)points toNewLine:(BOOL)newLine;

/**
 Remove all lines
 */
- (void)removeAllLines;

/**
 Remove the last line
 */
- (void)removeLastLine;

@end
