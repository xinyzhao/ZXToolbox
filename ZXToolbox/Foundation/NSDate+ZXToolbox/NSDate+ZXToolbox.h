//
// NSDate+ZXToolbox.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// yyyy-MM-dd'T'HH:mm:ss.SSSZ
extern NSString *const kZXDateTimeStringFormatRFC3339;
// yyyy-MM-dd HH:mm:ss
extern NSString *const kZXDateTimeStringFormatDefault;
// yyyy-MM-dd
extern NSString *const kZXDateTimeStringFormatDate;
// HH:mm:ss
extern NSString *const kZXDateTimeStringFormatTime;

/// NSDate (ZXToolbox)
@interface NSDate (ZXToolbox)
/// Default is [NSLocale currentLocale]
@property (class, copy, nullable) NSLocale *locale;
/// Default is [NSTimeZone localTimeZone]
@property (class, copy, nullable) NSTimeZone *timeZone;
/// Default is [NSCalendar currentCalendar]
@property (class, copy, nullable) NSCalendar *calendar;

/// Returns a NSDate from date time string with format
/// @param string The date time string
/// @param format The date time string format, default is kZXDateTimeStringFormatDefault if pass in nil.
+ (nullable NSDate *)dateWithString:(NSString *)string format:(nullable NSString  *)format;

/// Returns a date representing the absolute time calculated by adding given components to a given date.
/// @param year The year will be adding, it could be positive, negative and 0
/// @param month The month will be adding, it could be positive, negative and 0
/// @param day The day will be adding, it could be positive, negative and 0
- (NSDate *)dateByAddingYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

/// Get date time format string for defaultDateFormatter.
/// @param format The date format string, default is kZXDateTimeStringFormatDefault if pass in nil.
- (NSString *)stringWithFormat:(nullable NSString *)format;

/// Returns the date components representing a given date.
@property (nonatomic, readonly) NSDateComponents *allComponents;
/// Returns the date components: year/month/day/hour/minute/second/nonosecond
@property (nonatomic, readonly) NSDateComponents *dateComponents;
/// 今天
@property (nonatomic, readonly) BOOL isToday;
/// 明天
@property (nonatomic, readonly) BOOL isTomorrow;
/// 昨天
@property (nonatomic, readonly) BOOL isYesterday;
/// 后天
@property (nonatomic, readonly) BOOL isDayAfterTomorrow;
/// 前天
@property (nonatomic, readonly) BOOL isDayBeforeYesterday;
/// 本月最后一天
@property (nonatomic, readonly) BOOL isLastDayOfMonth;
/// 本月天数
@property (nonatomic, readonly) NSUInteger numberOfDaysInMonth;

@end

NS_ASSUME_NONNULL_END
