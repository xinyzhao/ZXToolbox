//
// ZXToastView.h
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


/// ZXToastViewStyle
typedef NS_ENUM(NSInteger, ZXToastStyle) {
    ZXToastStyleUnspecified,
    ZXToastStyleLight,
    ZXToastStyleDark,
};

/// ZXToastPosition
typedef NS_ENUM(NSInteger, ZXToastPosition) {
    ZXToastPositionCenter,
    ZXToastPositionTop,
    ZXToastPositionBottom,
    ZXToastPositionLeft,
    ZXToastPositionRight,
    ZXToastPositionTopLeft,
    ZXToastPositionTopRight,
    ZXToastPositionBottomLeft,
    ZXToastPositionBottomRight,
};

/// ZXToastView
@interface ZXToastView : UIView

/// Preset style for toast view, default is ZXToastStyleUnspecified
@property (nonatomic, readwrite) ZXToastStyle style;

/// The bubble view
@property (nonatomic, readonly) UIView *bubbleView;

/// Blur effect style for bubbleView
@property (nonatomic, readwrite) UIBlurEffectStyle effectStyle NS_AVAILABLE_IOS(8_0);

/// The activity view
@property (nonatomic, readonly, nullable) UIActivityIndicatorView *activityView;

/// The text label
@property (nonatomic, readonly, nullable) UILabel *textLabel;

/// The image view
@property (nonatomic, readonly, nullable) UIImageView *imageView;

/// Toast safe area insets, default is {0, 0, 0, 0}
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

/// Toast content margin, default is {15, 15, 15, 20}
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// Toast content spacing, default is 8
@property (nonatomic, assign) CGFloat contentSpacing;

/// Toast corner radius, default is 10
@property (nonatomic, assign) CGFloat cornerRadius;

/// The toast duration, default is 3 sec.
@property (nonatomic, assign) NSTimeInterval duration;

/// The fade in/out animation duration. Default is 0.2.
@property (nonatomic, assign) NSTimeInterval fadeDuration;

/// The toast position, default is ZXToastViewPositionCenter
@property (nonatomic, assign) ZXToastPosition position;

/// Tap to dismiss on toast views, default is YES
@property (nonatomic, assign) BOOL dismissWhenTouchInside;

/// Capture all touchs when toast view presenting, default is YES
@property (nonatomic, assign) BOOL captureWhenTouchOutside;

/// Init toast activity view
/// @param text The text to be displayed
- (instancetype)initWithActivity:(NSString * _Nullable)text;

/// Creates a new toast view
/// @param text The text to be displayed
- (instancetype)initWithText:(NSString * _Nullable)text;

/// Creates a new toast view
/// @param text The text to be displayed
/// @param duration The toast duration
- (instancetype)initWithText:(NSString * _Nullable)text
                    duration:(NSTimeInterval)duration;

/// Creates a new toast view
/// @param image The image
/// @param text The text to be displayed
/// @param duration The toast duration
- (instancetype)initWithImage:(UIImage * _Nullable)image
                         text:(NSString * _Nullable)text
                     duration:(NSTimeInterval)duration;

/// Show toast in view
/// @param view The superview
- (instancetype)showInView:(UIView *)view;

/// Show the status text
/// @param text The text to be displayed
- (void)showStatus:(NSString * _Nullable)text;

/// Hide the toast
/// @param animated animated
- (void)hideAnimated:(BOOL)animated;

/// Hide all toast
+ (void)hideAllToast;

@end

NS_ASSUME_NONNULL_END
