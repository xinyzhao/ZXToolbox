头文件

    #import "NSString+Pinyin.h"

测试代码

    NSString *str = @"我是中国人";
    NSLog(@"str = %@", str);
    NSLog(@"py0 = %@", [str stringByPinyinStyle:NSStringPinyinStyleMandarinLatin]);
    NSLog(@"py1 = %@", [str stringByPinyinStyle:NSStringPinyinStyleStripDiacritics]);
    NSLog(@"py2 = %@", [str stringByPinyinAcronym]);
    NSLog(@"co0 = %@", [str containsChineseCharacters] ? @"YES" : @"NO");
    NSLog(@"co1 = %@", [str containsString:@"ZG" options:NSStringPinyinSearchNone] ? @"YES" : @"NO");
    NSLog(@"co2 = %@", [str containsString:@"ZG" options:NSStringPinyinSearchAcronym] ? @"YES" : @"NO");

输出结果

    str = 我是中国人
    py0 = wǒ shì zhōng guó rén
    py1 = wo shi zhong guo ren
    py2 = wszgr
    co0 = YES
    co1 = NO
    co2 = YES