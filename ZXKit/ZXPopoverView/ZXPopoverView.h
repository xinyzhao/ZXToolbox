//
// ZXPopoverView.h
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
 ZXPopoverView
 */
@interface ZXPopoverView : UIView
/**
 Presented View
 */
@property (nonatomic, strong) UIView *presentedView;

/**
 Presented background color, default [[UIColor blackColor] colorWithAlphaComponent:0.4]
 */
@property (nonatomic, strong) UIColor *presentedBackgroundColor;

/**
 Presenting View
 */
@property (nonatomic, weak) UIView *presentingView;

/**
 Presenting duration of animation, default 0.3 secend
 */
@property (nonatomic, assign) NSTimeInterval presentingDuration;

/**
 Dismissing duration of animation, default 0.2 secend
 */
@property (nonatomic, assign) NSTimeInterval dismissingDuration;

/**
 Action block when tap on background without presented view
 */
@property (nonatomic, copy) void (^touchedBackgroundBlock)(void);

@end


/**
 UIView (ZXPopoverView)
 */
@interface UIView (ZXPopoverView)

/**
 Get the popover view

 @return ZXPopoverView
 */
- (ZXPopoverView *)popoverView;

/**
 Present view

 @param view presention view
 @param animated animated
 @param completion completion block
 */
- (void)presentView:(UIView *)view animated:(BOOL)animated completion:(void (^)(void))completion;

/**
 Present view

 @param view presention view
 @param from from point
 @param to to point
 @param animated animated
 @param completion completion block
 */
- (void)presentView:(UIView *)view from:(CGRect)from to:(CGRect)to animated:(BOOL)animated completion:(void(^)(void))completion;

/**
 Dismiss view

 @param flag animated
 @param completion completion block
 */
- (void)dismissViewAnimated:(BOOL)flag completion:(void(^)(void))completion;

@end
