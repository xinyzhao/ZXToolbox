//
// NSString+Pinyin.h
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

#pragma mark - NSString 拼音样式

/**
 * NSStringPinyinStyle 拼音样式
 */
typedef NS_ENUM(NSUInteger, NSStringPinyinStyle) {
    /// 带声调（拼音间用空格分隔，小写）
    NSStringPinyinMandarinLatin,
    /// 去声调（拼音间用空格分隔，小写）
    NSStringPinyinStripDiacritics,
};

#pragma mark - NSString 拼音搜索选项

/**
 * NSStringPinyinOptions 拼音选项
 */
typedef NS_ENUM(NSUInteger, NSStringPinyinOptions) {
    /// 不搜索拼音
    NSStringPinyinSearchNone    = 0x00,
    /// 搜索拼音首字母
    NSStringPinyinSearchAcronym = 0x01,
    /// 搜索拼音全拼
    NSStringPinyinSearchFully   = 0x02,
    /// 搜索拼音
    NSStringPinyinSearchAll     = 0xff,
};

#pragma mark - NSString 拼音转换

/**
 * @brief 字符串中是否包含汉字
 * @return 包含返回真，否则返回假
 */
extern BOOL NSStringContainsChineseCharacters(NSString *string);

/**
 * @brief 是否包含子字符串内容
 * @param string 源字符串
 * @param substring 子字符串
 * @param options 拼音搜索选项
 * @return 包含返回真，否则返回假
 * @see NSStringPinyinOptions
 */
extern BOOL NSStringContainsSubstring(NSString *string, NSString *substring, NSStringPinyinOptions options);

/**
 * @brief 把字符串中的汉字转换为拼音
 * @param string 待转换的字符串
 * @param style 拼音样式
 * @return 拼音字符串
 * @see NSStringPinyinStyle
 */
extern NSString* NSStringPinyinTransform(NSString *string, NSStringPinyinStyle style);

/**
 * @brief 得到字符串的拼音首字母缩写
 * @param string 源字符串
 * @return 拼音首字母缩写字符串
 */
extern NSString* NSStringPinyinAcronym(NSString *string);

/**
 * @brief 得到第一个字符的拼音首字母
 * @param string 源字符串
 * @return 第一个字符的拼音首字母
 */
extern NSString* NSStringPinyinFirstLetter(NSString *string);

#pragma mark - NSString 拼音分类

/**
 * NSString 拼音分类
 */
@interface NSString (Pinyin)

/**
 * @brief 是否包含汉字
 * @return 包含返回真，否则返回假
 */
- (BOOL)containsChineseCharacters;

/**
 * @brief 是否包含字符串内容
 * @param options 拼音搜索选项
 * @return 包含返回真，否则返回假
 * @see NSStringPinyinOptions
 */
- (BOOL)containsString:(NSString *)string options:(NSStringPinyinOptions)options;

/**
 * @brief 把字符串中的汉字转换为拼音
 * @param style 拼音样式
 * @return 拼音字符串
 * @see NSStringPinyinStyle
 */
- (NSString *)stringByPinyinStyle:(NSStringPinyinStyle)style;

/**
 * @brief 得到字符串的拼音首字母缩写
 * @return 拼音首字母缩写字符串
 */
- (NSString *)stringByPinyinAcronym;

/**
 * @brief 得到第一个字符的拼音首字母
 * @return 第一个字符的拼音首字母
 */
- (NSString *)stringByPinyinFirstLetter;

@end
