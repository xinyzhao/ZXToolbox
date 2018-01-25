//
// ZXAlertView.h
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

/**
 ZXAlertAction
 */
@interface ZXAlertAction : NSObject

/**
 Title for action
 */
@property (nonatomic, strong) NSString *title;

/**
 Make an action

 @param title Title for action
 @param handler Handler for action
 @return Instance
 */
+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(ZXAlertAction *action))handler;

/**
 Initialization

 @param title Title for action
 @param handler Handler for action
 @return Instance
 */
- (instancetype)initWithTitle:(NSString *)title handler:(void (^)(ZXAlertAction *action))handler;

@end

/**
 ZXAlertView
 */
@interface ZXAlertView : UIView
/**
 Title for alert view
 */
@property (nonatomic, strong) NSString *title;
/**
 Message for alert view
 */
@property (nonatomic, strong) NSString *message;

/**
 Like UIAlertView, compatible with iOS 7,8

 @param title Title for alert view
 @param message Message for alert view
 @param cancelAction Cancel action
 @param otherActions Other actions, end with nil
 @return Instance
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction otherActions:(ZXAlertAction *)otherActions, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Like UIActionSheet, compatible with iOS 7,8

 @param title Title for alert view
 @param message Message for alert view
 @param cancelAction Cancel action
 @param destructiveAction Destructive action
 @param otherActions Other actions, end with nil
 @return Instance
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction destructiveAction:(ZXAlertAction *)destructiveAction otherActions:(ZXAlertAction *)otherActions, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Add UITextField for alert view

 @param configurationHandler configuration handler
 */
- (void)addTextField:(void (^)(UITextField *textField))configurationHandler;

/**
 All text fields for alert view

 @return The text fields
 */
@property (nonatomic, readonly) NSArray<UITextField *> *textFields;

/**
 Show the alertView
 
 @param viewController The parent view controller
 */
- (void)showInViewController:(UIViewController *)viewController;

/**
 Show the alertView
 
 @param viewController The parent view controller
 @param sourceView The source view for iPad
 */
- (void)showInViewController:(UIViewController *)viewController sourceView:(UIView *)sourceView;

/**
 Show the alertView
 
 @param viewController The parent view controller
 @param sourceView The source view for iPad
 @param sourceRect The source rect for iPad
 */
- (void)showInViewController:(UIViewController *)viewController sourceView:(UIView *)sourceView sourceRect:(CGRect)sourceRect;

@end
