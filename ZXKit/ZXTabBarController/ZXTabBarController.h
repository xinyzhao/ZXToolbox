//
// ZXTabBarController.h
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

IB_DESIGNABLE
@interface ZXTabBarController : UITabBarController
@property (nonatomic, assign) IBInspectable BOOL originalItemImage; // Always draw the original image of item
@property (nonatomic, strong) IBInspectable UIColor *selectedItemColor;

@end

IB_DESIGNABLE
@interface ZXTabBarItemController : UIViewController
@property (nonatomic, strong) IBInspectable NSString *storyboardID;
@property (nonatomic, strong) IBInspectable NSString *storyboardName;

@end

@interface UITabBarController (SetSelectedAnimated)

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)setSelectedIndex:(NSUInteger)selectedIndex duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion;

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options completion:(void (^)(BOOL finished))completion;

@end

