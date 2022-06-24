//
// NSDate+ZXToolbox.m
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

#import "NSDate+ZXToolbox.h"
#import "ZXToolbox+Macros.h"

NSString *const kZXDateTimeStringFormatRFC3339  = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
NSString *const kZXDateTimeStringFormatDefault  = @"yyyy-MM-dd HH:mm:ss";
NSString *const kZXDateTimeStringFormatDate     = @"yyyy-MM-dd";
NSString *const kZXDateTimeStringFormatTime     = @"HH:mm:ss";

@implementation NSDate (ZXToolbox)

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
    });
    return dateFormatter;
}

+ (nullable NSLocale *)locale {
    return [NSDate dateFormatter].locale ?: [NSLocale currentLocale];
}

+ (void)setLocale:(nullable NSLocale *)locale {
    [NSDate dateFormatter].locale = locale;
}

+ (nullable NSTimeZone *)timeZone {
    return [NSDate dateFormatter].timeZone ?: [NSTimeZone localTimeZone];
}

+ (void)setTimeZone:(nullable NSTimeZone *)timeZone {
    [NSDate dateFormatter].timeZone = timeZone;
}

+ (nullable NSCalendar *)calendar {
    return [NSDate dateFormatter].calendar ?: [NSCalendar currentCalendar];
}

+ (void)setCalendar:(NSCalendar *)calendar {
    [NSDate dateFormatter].calendar = calendar;
}

+ (nullable NSDate *)dateWithString:(NSString *)string format:(nullable NSString  *)format {
    NSDateFormatter *date = [NSDate dateFormatter];
    date.dateFormat = format ?: kZXDateTimeStringFormatDefault;
    return [date dateFromString:string];
}

- (NSString *)stringWithFormat:(nullable NSString *)format {
    NSDateFormatter *date = [NSDate dateFormatter];
    date.dateFormat = format ?: kZXDateTimeStringFormatDefault;
    return [date stringFromDate:self];
}

- (NSDateComponents *)allComponents {
    NSCalendarUnit units = (NSCalendarUnitEra |
                            NSCalendarUnitYear |
                            NSCalendarUnitMonth |
                            NSCalendarUnitDay |
                            NSCalendarUnitHour |
                            NSCalendarUnitMinute |
                            NSCalendarUnitSecond |
                            NSCalendarUnitWeekday |
                            NSCalendarUnitWeekdayOrdinal |
                            NSCalendarUnitQuarter |
                            NSCalendarUnitWeekOfMonth |
                            NSCalendarUnitWeekOfYear |
                            NSCalendarUnitYearForWeekOfYear |
                            NSCalendarUnitNanosecond |
                            NSCalendarUnitCalendar |
                            NSCalendarUnitTimeZone);
    return [[NSDate calendar] components:units fromDate:self];
}

- (NSDateComponents *)dateComponents {
    NSCalendarUnit units = (NSCalendarUnitYear |
                            NSCalendarUnitMonth |
                            NSCalendarUnitDay |
                            NSCalendarUnitHour |
                            NSCalendarUnitMinute |
                            NSCalendarUnitSecond |
                            NSCalendarUnitNanosecond);
    return [[NSDate calendar] components:units fromDate:self];
}

- (NSDate *)dateByAddingYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *comp = self.dateComponents;
    comp.year += year + month / 12;
    comp.month += month % 12;
    if (self.isLastDayOfMonth) {
        comp.day = 1;
        comp.day = [[calendar dateFromComponents:comp] numberOfDaysInMonth];
    }
    NSDate *date = [calendar dateFromComponents:comp];
    return [date dateByAddingTimeInterval:(3600 * 24 * day)];
}

- (BOOL)isToday {
    NSDateComponents *this = [self dateComponents];
    NSDateComponents *date = [[NSDate date] dateComponents];
    return this.year == date.year && this.month == date.month && this.day == date.day;
}

- (BOOL)isTomorrow {
    NSDateComponents *this = [self dateComponents];
    NSDateComponents *date = [[[NSDate date] dateByAddingYear:0 month:0 day:1] dateComponents];
    return this.year == date.year && this.month == date.month && this.day == date.day;
}

- (BOOL)isYesterday {
    NSDateComponents *this = [self dateComponents];
    NSDateComponents *date = [[[NSDate date] dateByAddingYear:0 month:0 day:-1] dateComponents];
    return this.year == date.year && this.month == date.month && this.day == date.day;
}

- (BOOL)isDayAfterTomorrow {
    NSDateComponents *this = [self dateComponents];
    NSDateComponents *date = [[[NSDate date] dateByAddingYear:0 month:0 day:2] dateComponents];
    return this.year == date.year && this.month == date.month && this.day == date.day;
}

- (BOOL)isDayBeforeYesterday {
    NSDateComponents *this = [self dateComponents];
    NSDateComponents *date = [[[NSDate date] dateByAddingYear:0 month:0 day:-2] dateComponents];
    return this.year == date.year && this.month == date.month && this.day == date.day;
}

- (BOOL)isLastDayOfMonth {
    NSDateComponents *date = [self dateComponents];
    NSUInteger days = [self numberOfDaysInMonth];
    return date.day == days;
}

- (NSUInteger)numberOfDaysInMonth {
    return [[NSDate calendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

@end
