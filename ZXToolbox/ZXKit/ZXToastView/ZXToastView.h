//
// ZXToastView.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2018 Zhao Xin
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


/// ZXToastStyle
typedef NS_ENUM(NSInteger, ZXToastStyle) {
    ZXToastStyleDark,
    ZXToastStyleLight,
    ZXToastStyleSystem, // follow the system style
};

/// ZXToastAnimation
typedef NS_ENUM(NSInteger, ZXToastAnimation) {
    ZXToastAnimationNone,
    ZXToastAnimationFade,
    ZXToastAnimationScale,
};

/// ZXToastEffectView
@interface ZXToastEffectView : UIVisualEffectView

/// The effect style
@property (nonatomic, assign) UIBlurEffectStyle effectStyle;

/// The text label
@property (nonatomic, readonly) UILabel *textLabel;

/// The image view
@property (nonatomic, readonly) UIImageView *imageView;

/// The image view size
@property (nonatomic, assign) CGSize imageSize;

/// The loading view
@property (nonatomic, readonly) UIActivityIndicatorView *loadingView;

/// The loading view size
@property (nonatomic, assign) CGSize loadingSize;

/// Toast content margin, default is {16, 16, 16, 16}
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// Toast content size, include the contentInset size.
@property (nonatomic, readonly) CGSize contentSize;

/// Toast item spacing, default is 8
@property (nonatomic, assign) CGFloat itemSpacing;

@end

/// ZXToastView
/// @Discussion The touch events will be captured when displayed, stop captures by setting the userInteractionEnabled to false.
@interface ZXToastView : UIView

/// Preset style for toast view, default is ZXToastStyleSystem
@property (nonatomic, assign) ZXToastStyle style;

/// The animation type, default is ZXToastAnimationFade
@property (nonatomic, assign) ZXToastAnimation animation;

/// The effectView view, it's layer.cornerRadius is 16, layer.masksToBounds is true, you can set it by yourself if you needed.
/// You can change the foreground color by setting effectView.tintColor after ZXToastView.style was setting.
@property (nonatomic, readonly) ZXToastEffectView *effectView;

/// The custom view, replace the effectView if not nil.
@property (nonatomic, strong, nullable) UIView *customView;

/// Toast center point, default is {0.5, 0.5}
@property (nonatomic, assign) CGPoint centerPoint;

/// Toast safe area insets, default is equal to system safe area
@property (nonatomic, assign) UIEdgeInsets safeAreaInset;

/// Change the loading text
/// @param text The text to be displayed
- (instancetype)showText:(nullable NSString *)text;

/// Show the text and image
/// @param image The image
/// @param text The text
- (instancetype)showImage:(UIImage *)image text:(nullable NSString *)text;

/// Show the loading text
/// @param text The text to be displayed
- (instancetype)showLoading:(nullable NSString *)text;

/// Show the toast with animated
/// @param animated animated
/// @discussion If animated is YES and the animation is not ZXToastAnimationNone, the toast will be animation showing.
- (instancetype)showAnimated:(BOOL)animated;

/// Show the toast in view
/// @param view The superview
- (instancetype)showInView:(nullable UIView *)view;

/// Hide the toast after delay time
/// @param time The delay time
- (void)hideAfter:(NSTimeInterval)time;

/// Hide the toast with animated
/// @param animated animated
/// @discussion If animated is YES and the animation is not ZXToastAnimationNone, the toast will be animation hiding.
- (void)hideAnimated:(BOOL)animated;

/// Remove all toasts
+ (void)hideToasts;

@end

NS_ASSUME_NONNULL_END
