//
// UITextField+ZXToolbox.m
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

#import "UITextField+ZXToolbox.h"
#import "NSObject+ZXToolbox.h"
#import <objc/runtime.h>

@implementation UITextField (ZXToolbox)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(setPlaceholder:) with:@selector(setPlaceholderText:)];
    });
}

- (void)setMobileNumberFormat:(NSString *)mobileNumberFormat {
    objc_setAssociatedObject(self, @selector(mobileNumberFormat), mobileNumberFormat, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //
    NSMutableDictionary *separator = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < mobileNumberFormat.length; i++) {
        NSString *str = [mobileNumberFormat substringWithRange:NSMakeRange(i, 1)];
        if (![str isEqualToString:@"#"]) {
            [separator setObject:str forKey:@(i + 1)];
        }
    }
    [self setMobileNumberSeparator:[separator copy]];
    //
    if (separator.count > 0) {
        [self addTarget:self action:@selector(mobileNumberDidChanged:) forControlEvents:UIControlEventEditingChanged];
    } else {
        [self removeTarget:self action:@selector(mobileNumberDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }
}

- (NSString *)mobileNumberFormat {
    return objc_getAssociatedObject(self, @selector(mobileNumberFormat));
}

- (void)setMobileNumberSeparator:(NSDictionary *)mobileNumberSeparator {
    objc_setAssociatedObject(self, @selector(mobileNumberSeparator), mobileNumberSeparator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)mobileNumberSeparator {
    return objc_getAssociatedObject(self, @selector(mobileNumberSeparator));
}

- (void)setMobileNumberDidCompleted:(void (^)(UITextField *, NSString *))mobileNumberDidCompleted {
    objc_setAssociatedObject(self, @selector(mobileNumberDidCompleted), mobileNumberDidCompleted, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)(UITextField *, NSString *))mobileNumberDidCompleted {
    return objc_getAssociatedObject(self, @selector(mobileNumberDidCompleted));
}

- (void)setMobileNumberLength:(NSInteger)mobileNumberLength {
    objc_setAssociatedObject(self, @selector(mobileNumberLength), @(mobileNumberLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)mobileNumberLength {
    return [objc_getAssociatedObject(self, @selector(mobileNumberLength)) integerValue];
}

- (void)mobileNumberDidChanged:(UITextField *)textField {
    if (textField == self) {
        if (textField.text.length > self.mobileNumberLength) {
            // 输入
            [self.mobileNumberSeparator enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (textField.text.length == [key integerValue]) {
                    NSMutableString *str = [[NSMutableString alloc ] initWithString:textField.text];
                    [str insertString:obj atIndex:(textField.text.length - 1)];
                    textField.text = str;
                }
            }];
            // 长度
            [self setMobileNumberLength:textField.text.length];
            // 完成
            if (textField.text.length >= self.mobileNumberFormat.length) {
                if (self.mobileNumberDidCompleted) {
                    NSArray *keys = [[self.mobileNumberSeparator allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [obj2 compare:obj1];
                    }];
                    NSString *str = [textField.text substringToIndex:self.mobileNumberFormat.length];
                    for (id key in keys) {
                        NSInteger idx = [key integerValue] - 1;
                        NSString *obj = self.mobileNumberSeparator[key];
                        str = [str stringByReplacingCharactersInRange:NSMakeRange(idx, obj.length) withString:@""];
                    }
                    self.mobileNumberDidCompleted(self, str);
                }
            }
        } else if (textField.text.length < self.mobileNumberLength) {
            // 删除
            [self.mobileNumberSeparator enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if (textField.text.length == [key integerValue]) {
                    textField.text = [NSString stringWithFormat:@"%@", textField.text];
                    textField.text = [textField.text substringToIndex:(textField.text.length - [obj length])];
                }
            }];
            // 长度
            [self setMobileNumberLength:textField.text.length];
        }
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    objc_setAssociatedObject(self, @selector(placeholderColor), placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (placeholderColor == nil) {
        self.attributedPlaceholder = nil;
    } else if (self.placeholder) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor}];
    }
}

- (UIColor *)placeholderColor {
    return objc_getAssociatedObject(self, @selector(placeholderColor));
}

- (void)setPlaceholderText:(NSString *)text {
    [self setPlaceholderText:text];
    //
    if (text && self.placeholderColor) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:self.placeholderColor}];
    }
}

@end
