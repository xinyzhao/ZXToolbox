//
// NSDate+ZXToolbox.h
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

#import <Foundation/Foundation.h>

// yyyy-MM-dd HH:mm:ss
extern NSString *const NSDateToolboxFormatDateTime;
// yyyy-MM-dd
extern NSString *const NSDateToolboxFormatDate;
// HH:mm:ss
extern NSString *const NSDateToolboxFormatTime;

/// NSDate (ZXToolbox)
@interface NSDate (ZXToolbox)

+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format;

- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)dateString; //NSDateToolboxFormatDate
- (NSString *)dateTimeString; //NSDateToolboxFormatDateTime
- (NSString *)timeString; //NSDateToolboxFormatTime

- (NSDate *)prevDayDate; // 前一天
- (NSDate *)nextDayDate; // 后一天

- (NSDate *)prevMonthDate; // 上个月
- (NSDate *)nextMonthDate; // 下个月

- (BOOL)isToday; // 今天
- (BOOL)isTomorrow; // 明天
- (BOOL)isYesterday; // 昨天
- (BOOL)isDayAfterTomorrow; // 后天
- (BOOL)isDayBeforeYesterday; // 前天

- (NSDateComponents *)componets;

- (NSDate *)firstDayOfMonthDate; // 当月第一天
- (NSInteger)numberOfDaysInMonth; // 当月天数

@end

@interface NSDateFormatter (ZXToolbox)

+ (instancetype)defaultFormatter;

@end
