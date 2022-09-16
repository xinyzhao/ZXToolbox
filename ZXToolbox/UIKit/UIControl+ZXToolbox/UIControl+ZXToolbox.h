//
// UIControl+ZXToolbox.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, UIControlTimeIntervalMode) {
    /// pass property `enabled` of UIControl
    UIControlTimeIntervalModeState,
    /// pass property `userInteractionEnabled` of UIControl
    UIControlTimeIntervalModeEvent,
};

#define UIControlTimeIntervalMinimum 0.01

/// UIControl (ZXToolbox)
@interface UIControl (ZXToolbox)

/// If true, through UIControl.userInteractionEnabled property to activate the timeInterval,
/// otherwise, through UIControl.enabled property to activate the timeInterval.
/// Default is NO
@property (nonatomic, assign) BOOL timeIntervalByUserInteractionEnabled __attribute__((deprecated("Replaced by timeIntervalMode!")));

/// The time interval mode, default is UIControlTimeIntervalModeState.
@property (nonatomic, assign) UIControlTimeIntervalMode timeIntervalMode;

/// Set time interval for particular event, set a less than 0.01 value to remove time interval
/// @param timeInterval time interval, must great than 0.01
/// @param controlEvents UIControlEvents
- (void)setTimeInteval:(NSTimeInterval)timeInterval forControlEvents:(UIControlEvents)controlEvents;

/// Remove time interval for particular event
/// @param controlEvents UIControlEvents
- (void)removeTimeIntevalForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
