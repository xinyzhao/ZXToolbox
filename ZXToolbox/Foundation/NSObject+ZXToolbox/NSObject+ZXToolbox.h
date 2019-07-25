//
// NSObject+ZXToolbox.h
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

/**
 NSObject (ZXToolbox)
 */
@interface NSObject (ZXToolbox)

/**
 替换类方法

 @param originalSelector 原始方法
 @param swizzledSelector 替换方法
 */
+ (void)swizzleClassMethod:(SEL)originalSelector with:(SEL)swizzledSelector;

/**
 替换实例方法

 @param originalSelector 原始方法
 @param swizzledSelector 替换方法
 */
+ (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector;

/**
 替换代理方法，这里需要注意两点
 1.如果代理实现了originalSelector，直接使用swizzledSelector进行替换，
   需要在swizzledSelector内再次调用swizzledSelector方法；
 2.如果代理没有实现originalSelector，则需要self实现originalSelector方法，
   originalSelector内部不需要调用originalSelector方法。

 @param originalSelector 原始方法
 @param swizzledSelector 替换方法
 @param originalClass 原始Class
 */
- (void)swizzleMethod:(SEL)originalSelector with:(SEL)swizzledSelector class:(Class)originalClass;

/**
 类同 respondsToSelector

 @param selector 方法选择器
 @return BOOL
 */
- (BOOL)respondsToMethod:(SEL)selector;

/**
 执行指定的方法

 @param selector 选择器
 */
- (void)performMethod:(SEL)selector;
/**
 执行指定的方法

 @param selector 选择器
 @param object 对象
 */
- (void)performMethod:(SEL)selector withObject:(id)object;
/**
 执行指定的方法

 @param selector 选择器
 @param object1 对象1
 @param object2 对象2
 */
- (void)performMethod:(SEL)selector withObject:(id)object1 withObject:(id)object2;

@end
