//
// NSDate+ZXToolbox.m
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

#import "NSDate+ZXToolbox.h"

NSString *const NSDateToolboxFormatDateTime   = @"yyyy-MM-dd HH:mm:ss";
NSString *const NSDateToolboxFormatDate       = @"yyyy-MM-dd";
NSString *const NSDateToolboxFormatTime       = @"HH:mm:ss";

@implementation NSDate (ZXToolbox)

+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format {
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultFormatter];
    [dateFormatter setDateFormat:format ? format : NSDateToolboxFormatDateTime];
    return [dateFormatter dateFromString:string];
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultFormatter];
    [dateFormatter setDateFormat:format ? format : NSDateToolboxFormatDateTime];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateString {
    return [self stringWithFormat:NSDateToolboxFormatDate];
}

- (NSString *)dateTimeString {
    return [self stringWithFormat:NSDateToolboxFormatDateTime];
}

- (NSString *)timeString {
    return [self stringWithFormat:NSDateToolboxFormatTime];
}

- (NSDate *)prevDayDate {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate] - 24 * 3600];
}

- (NSDate *)nextDayDate {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate] + 24 * 3600];
}

- (NSDate *)prevMonthDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    if (components.month > 1) {
        [components setYear:0];
    } else {
        [components setYear:-1];
    }
    [components setMonth:-1];
    [components setDay:0];
    return [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                         toDate:self
                                                        options:NSCalendarWrapComponents];
}

- (NSDate *)nextMonthDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    if (components.month < 12) {
        [components setYear:0];
    } else {
        [components setYear:1];
    }
    [components setMonth:1];
    [components setDay:0];
    return [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                         toDate:self
                                                        options:NSCalendarWrapComponents];
}

- (BOOL)isToday {
    NSString *date = [[NSDate date] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isTomorrow {
    NSString *date = [[[NSDate date] nextDayDate] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isYesterday {
    NSString *date = [[[NSDate date] prevDayDate] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isDayAfterTomorrow {
    NSString *date = [[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceReferenceDate] + 48 * 3600] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isDayBeforeYesterday {
    NSString *date = [[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceReferenceDate] - 48 * 3600] dateString];
    return [date isEqualToString:[self dateString]];
}

- (NSDateComponents *)componets {
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
    return [[NSCalendar currentCalendar] components:units fromDate:self];
}

- (NSDate *)firstDayOfMonthDate {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day = 1;
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSInteger)numberOfDaysInMonth {
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

@end

@implementation NSDateFormatter (ZXToolbox)

+ (instancetype)defaultFormatter {
    static NSDateFormatter *defaultFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultFormatter = [[NSDateFormatter alloc] init];
    });
    return defaultFormatter;
}

@end
